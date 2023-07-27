// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721AC} from "ERC721C/erc721c/ERC721AC.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";
import {IBalanceOfHook} from "./interfaces/IBalanceOfHook.sol";
import {IOwnerOfHook} from "./interfaces/IOwnerOfHook.sol";
import {ISafeTransferFromHook} from "./interfaces/ISafeTransferFromHook.sol";
import {ITransferFromHook} from "./interfaces/ITransferFromHook.sol";
import {IApproveHook} from "./interfaces/IApproveHook.sol";
import {ISetApprovalForAllHook} from "./interfaces/ISetApprovalForAllHook.sol";
import {IGetApprovedHook} from "./interfaces/IGetApprovedHook.sol";
import {IIsApprovedForAllHook} from "./interfaces/IIsApprovedForAllHook.sol";
import {IBeforeTokenTransfersHook} from "./interfaces/IBeforeTokenTransfersHook.sol";
import {IAfterTokenTransfersHook} from "./interfaces/IAfterTokenTransfersHook.sol";
import {IMintHook} from "./interfaces/IMintHook.sol";
import {IERC721ACH} from "./interfaces/IERC721ACH.sol";

/**
 * @title ERC721ACH
 * @author Cre8ors Inc.
 * @notice Extends Limit Break's ERC721-AC implementation with Hook functionality, which
 *  allows the contract owner to override hooks associated with core ERC721 functions.
 */
contract ERC721ACH is ERC721AC, IERC721ACH {
    // TODO: how can we store these in a more efficient way?
    
    /**
    * @dev Mapping of hook types to their respective contract addresses.
    * Each hook type can be associated with a contract that implements the hook's logic.
    * Only the contract owner can set or update these hooks.
    */
    mapping(HookType => address) public hooks;


    event UpdatedHook(address indexed setter, HookType hookType, address indexed hookAddress);


    /// @notice Contract constructor
    /// @param _contractName The name for the token contract
    /// @param _contractSymbol The symbol for the token contract
    constructor(
        string memory _contractName,
        string memory _contractSymbol
    ) ERC721AC(_contractName, _contractSymbol) {}

    /// @inheritdoc IERC721A
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /////////////////////////////////////////////////
    /// ERC721 overrides
    /////////////////////////////////////////////////

    /// @inheritdoc IERC721A
    function balanceOf(address owner) public view virtual override returns (uint256) {
    IBalanceOfHook balanceOfHookInstance = IBalanceOfHook(hooks[HookType.BalanceOf]);
    
    if (address(balanceOfHookInstance) != address(0) && balanceOfHookInstance.useBalanceOfHook(owner)) {
        return balanceOfHookInstance.balanceOfOverrideHook(owner);
    }
    return super.balanceOf(owner);
}


    /// @inheritdoc IERC721A
    function ownerOf(
        uint256 tokenId
    ) public view virtual override returns (address) {
        IOwnerOfHook ownerOfHook = IOwnerOfHook(hooks[HookType.OwnerOf]);
        if (
            address(ownerOfHook) != address(0) &&
            ownerOfHook.useOwnerOfHook(tokenId)
        ) {
            return ownerOfHook.ownerOfOverrideHook(tokenId);
        }
        return super.ownerOf(tokenId);
    }

    /// @inheritdoc IERC721A
    function approve(
        address approved,
        uint256 tokenId
    ) public payable virtual override {
        IApproveHook approveHook = IApproveHook(hooks[HookType.Approve]);
        if (
            address(approveHook) != address(0) &&
            approveHook.useApproveHook(approved, tokenId)
        ) {
            approveHook.approveOverrideHook(approved, tokenId);
        } else {
            super.approve(approved, tokenId);
        }
    }

    /// @inheritdoc IERC721A
    function setApprovalForAll(
        address operator,
        bool approved
    ) public virtual override {

        ISetApprovalForAllHook setApprovalForAllHook = ISetApprovalForAllHook(hooks[HookType.SetApprovalForAll]);

        if (
            address(setApprovalForAllHook) != address(0) &&
            setApprovalForAllHook.useSetApprovalForAllHook(
                msg.sender,
                operator,
                approved
            )
        ) {
            setApprovalForAllHook.setApprovalForAllOverrideHook(
                msg.sender,
                operator,
                approved
            );
        } else {
            super.setApprovalForAll(operator, approved);
        }
    }

    /// @inheritdoc IERC721A
    function getApproved(
        uint256 tokenId
    ) public view virtual override returns (address) {
        IGetApprovedHook getApprovedHook = IGetApprovedHook(hooks[HookType.GetApproved]);
        if (
            address(getApprovedHook) != address(0) &&
            getApprovedHook.useGetApprovedHook(tokenId)
        ) {
            return getApprovedHook.getApprovedOverrideHook(tokenId);
        }
        return super.getApproved(tokenId);
    }

    /// @inheritdoc IERC721A
    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual override returns (bool) {
        IIsApprovedForAllHook isApprovedForAllHook = IIsApprovedForAllHook(hooks[HookType.IsApprovedForAll]);
        if (
            address(isApprovedForAllHook) != address(0) &&
            isApprovedForAllHook.useIsApprovedForAllHook(owner, operator)
        ) {
            return
                isApprovedForAllHook.isApprovedForAllOverrideHook(
                    owner,
                    operator
                );
        }
        return super.isApprovedForAll(owner, operator);
    }

    /// @inheritdoc IERC721A
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        ITransferFromHook transferFromHook = ITransferFromHook(hooks[HookType.TransferFrom]);
        if (
            address(transferFromHook) != address(0) &&
            transferFromHook.useTransferFromHook(from, to, tokenId)
        ) {
            transferFromHook.transferFromOverrideHook(from, to, tokenId);
        } else {
            super.transferFrom(from, to, tokenId);
        }
    }

    /// @inheritdoc IERC721A
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public payable virtual override {
        _safeTransferFrom(from, to, tokenId, data);
    }

    /// @inheritdoc IERC721A
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public payable virtual override {
        _safeTransferFrom(from, to, tokenId, "");
    }

    /// TODO
    function _safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        ISafeTransferFromHook safeTransferFromHook = ISafeTransferFromHook(hooks[HookType.SafeTransferFrom]);
        if (
            address(safeTransferFromHook) != address(0) &&
            safeTransferFromHook.useSafeTransferFromHook(
                msg.sender,
                from,
                to,
                tokenId,
                data
            )
        ) {
            safeTransferFromHook.safeTransferFromOverrideHook(
                msg.sender,
                from,
                to,
                tokenId,
                data
            );
        } else {
            super.safeTransferFrom(from, to, tokenId, data);
        }
    }

    /// TODO
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        IBeforeTokenTransfersHook beforeTokenTransfersHook = IBeforeTokenTransfersHook(hooks[HookType.BeforeTokenTransfers]);
        if (
            address(beforeTokenTransfersHook) != address(0) &&
            beforeTokenTransfersHook.useBeforeTokenTransfersHook(from, to, startTokenId, quantity)
        ) {
            beforeTokenTransfersHook.beforeTokenTransfersOverrideHook(
                from,
                to,
                startTokenId,
                quantity
            );
        } else {
            super._beforeTokenTransfers(from, to, startTokenId, quantity);
        }
    }

    /// TODO
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        IAfterTokenTransfersHook afterTokenTransfersHook = IAfterTokenTransfersHook(hooks[HookType.AfterTokenTransfers]);
        if (
            address(afterTokenTransfersHook) != address(0) &&
            afterTokenTransfersHook.useAfterTokenTransfersHook(from, to, startTokenId, quantity)
        ) {
            afterTokenTransfersHook.afterTokenTransfersOverrideHook(
                from,
                to,
                startTokenId,
                quantity
            );
        } else {
            super._afterTokenTransfers(from, to, startTokenId, quantity);
        }
    }

    /// TODO
    function _mint(
        address to,
        uint256 tokenId
    ) internal virtual override {
        IMintHook mintHook = IMintHook(hooks[HookType.Mint]);
        if (
            address(mintHook) != address(0) &&
            mintHook.useMintHook(to, tokenId)
        ) {
            mintHook.mintOverrideHook(to, tokenId);
        } else {
            super._mint(to, tokenId);
        }
    }

    /////////////////////////////////////////////////
    /// ERC721 Hooks
    /////////////////////////////////////////////////

    /// @notice isApprovedForAll Hook for custom implementation.
    /// @param owner The address that owns the NFTs
    /// @param operator The address that acts on behalf of the owner
    /// @dev Returns whether an operator is approved by a given owner
    function _isApprovedForAllHook(
        address owner,
        address operator
    ) internal view virtual returns (bool) {}

    /// @notice Check if the isApprovedForAll function should use hook.
    /// @param owner The address that owns the NFTs
    /// @param operator The address that acts on behalf of the owner
    /// @dev Returns whether or not to use the hook for isApprovedForAll function
    function _useIsApprovedForAllHook(
        address owner,
        address operator
    ) internal view virtual returns (bool) {}


    /**
        * @notice Returns the contract address for a specified hook type.
        * @param hookType The type of hook to retrieve, as defined in the HookType enum.
        * @return The address of the contract implementing the hook interface.
    */
    function getHook(HookType hookType) external view returns (address) {
        return hooks[hookType];
    }

    /////////////////////////////////////////////////
    /// ERC721C Override
    /////////////////////////////////////////////////

    /// @notice Override the function to throw if caller is not contract owner
    function _requireCallerIsContractOwner() internal view virtual override {}

    /////////////////////////////////////////////////
    /// ERC721H Admin Controls
    /////////////////////////////////////////////////

    /**
        * @notice Sets the contract address for a specified hook type.
        * @param hookType The type of hook to set, as defined in the HookType enum.
        * @param hookAddress The address of the contract implementing the hook interface.
    */
    function setHook(HookType hookType, address hookAddress) external virtual onlyOwner {
        hooks[hookType] = hookAddress;
        emit UpdatedHook(msg.sender, hookType, hookAddress);
    }



    /// TODO
    modifier onlyOwner() {
        _requireCallerIsContractOwner();

        _;
    }
}
