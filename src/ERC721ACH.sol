// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721AC} from "ERC721C/erc721c/ERC721AC.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";

/////////////////////////////////////////////////
/// Override Hook Interfaces
/////////////////////////////////////////////////
import {IBalanceOfHook} from "./interfaces/IBalanceOfHook.sol";
import {IOwnerOfHook} from "./interfaces/IOwnerOfHook.sol";
import {ISafeTransferFromHook} from "./interfaces/ISafeTransferFromHook.sol";
import {ITransferFromHook} from "./interfaces/ITransferFromHook.sol";
import {IApproveHook} from "./interfaces/IApproveHook.sol";
import {ISetApprovalForAllHook} from "./interfaces/ISetApprovalForAllHook.sol";
import {IGetApprovedHook} from "./interfaces/IGetApprovedHook.sol";
import {IIsApprovedForAllHook} from "./interfaces/IIsApprovedForAllHook.sol";
import {IERC721ACH} from "./interfaces/IERC721ACH.sol";

/////////////////////////////////////////////////
/// After & Before Hook Interfaces
/////////////////////////////////////////////////
import {IAFterTransferFromHook} from "./interfaces/IAfterTransferFromHook.sol";
import {IBeforeTransferFromHook} from "./interfaces/IBeforeTransferFromHook.sol";

/**
 * @title ERC721ACH
 * @author Cre8ors Inc.
 * @notice Extends Limit Break's ERC721-AC implementation with Hook functionality, which
 *         allows the contract owner to override hooks associated with core ERC721 functions.
 */
contract ERC721ACH is ERC721AC, IERC721ACH {
    // TODO: how can we store these in a more efficient way?
    IBalanceOfHook public balanceOfHook;
    IOwnerOfHook public ownerOfHook;
    ISafeTransferFromHook public safeTransferFromHook;
    ITransferFromHook public transferFromHook;
    IApproveHook public approveHook;
    ISetApprovalForAllHook public setApprovalForAllHook;
    IGetApprovedHook public getApprovedHook;
    IIsApprovedForAllHook public isApprovedForAllHook;

    IBeforeTransferFromHook public beforeTransferFromHook;
    IAfterTransferFromHook public afterTransferFromHook;

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
    function balanceOf(
        address owner
    ) public view virtual override returns (uint256) {
        if (
            address(balanceOfHook) != address(0) &&
            balanceOfHook.useBalanceOfHook(owner)
        ) {
            return balanceOfHook.balanceOfOverrideHook(owner);
        }
        return super.balanceOf(owner);
    }

    /// @inheritdoc IERC721A
    function ownerOf(
        uint256 tokenId
    ) public view virtual override returns (address) {
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
        if (
            address(beforeTransferFromHook) != address(0) &&
            beforeTransferFromHook.useBeforeTransferFrom(from, to, tokenId)
        ) {
            beforeTransferFromHook.beforeTransferFromOverrideHook(from, to, tokenId);
        }
        if (
            address(transferFromHook) != address(0) &&
            transferFromHook.useTransferFromHook(from, to, tokenId)
        ) {
            transferFromHook.transferFromOverrideHook(from, to, tokenId);
        } else {
            super.transferFrom(from, to, tokenId);
        }

        if (
            address(afterTransferFromHook) != address(0) &&
            afterTransferFromHook.useAfterTransferFrom(from, to, tokenId)
        ) {
            beforeTransferFromHook.afterTransferFromOverrideHook(from, to, tokenId);
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

    /////////////////////////////////////////////////
    /// ERC721C Override
    /////////////////////////////////////////////////

    /// @notice Override the function to throw if caller is not contract owner
    function _requireCallerIsContractOwner() internal view virtual override {}

    /////////////////////////////////////////////////
    /// ERC721H Admin Controls
    /////////////////////////////////////////////////

    /// TODO
    function setBalanceOfHook(IBalanceOfHook _hook) external virtual onlyOwner {
        balanceOfHook = _hook;
        emit UpdatedHookBalanceOf(msg.sender, address(_hook));
    }

    /// TODO
    function setOwnerOfHook(IOwnerOfHook _hook) external virtual onlyOwner {
        ownerOfHook = _hook;
        emit UpdatedHookOwnerOf(msg.sender, address(_hook));
    }

    /// TODO
    function setSafeTransferFromHook(
        ISafeTransferFromHook _hook
    ) external virtual onlyOwner {
        safeTransferFromHook = _hook;
        emit UpdatedHookSafeTransferFrom(msg.sender, address(_hook));
    }

    /// TODO
    function setTransferFromHook(
        ITransferFromHook _hook
    ) external virtual onlyOwner {
        transferFromHook = _hook;
        emit UpdatedHookTransferFrom(msg.sender, address(_hook));
    }

    /// TODO
    function setApproveHook(IApproveHook _hook) external virtual onlyOwner {
        approveHook = _hook;
        emit UpdatedHookApprove(msg.sender, address(_hook));
    }

    /// TODO
    function setSetApprovalForAllHook(
        ISetApprovalForAllHook _hook
    ) external virtual onlyOwner {
        setApprovalForAllHook = _hook;
        emit UpdatedHookSetApprovalForAll(msg.sender, address(_hook));
    }

    /// TODO
    function setGetApprovedHook(
        IGetApprovedHook _hook
    ) external virtual onlyOwner {
        getApprovedHook = _hook;
        emit UpdatedHookGetApproved(msg.sender, address(_hook));
    }

    /// TODO
    function setIsApprovedForAllHook(
        IIsApprovedForAllHook _hook
    ) external virtual onlyOwner {
        isApprovedForAllHook = _hook;
        emit UpdatedHookIsApprovedForAll(msg.sender, address(_hook));
    }

    /// TODO
    function setBeforeTransferFromHook (
        IBeforeTransferFromHook _hook
    ) external virtual onlyOwner {
        beforeTransferFromHook = _hook;
        emit UpdatedHookBeforeTransferFrom(msg.sender, address(_hook));
    }
 
    /// TODO
    function setAfterTransferFromHook (
        IAfterTransferFromHook _hook
    ) external virtual onlyOwner {
        beforeTransferFromHook = _hook;
        emit UpdatedHookAfterTransferFrom(msg.sender, address(_hook));
    }
    /// TODO
    modifier onlyOwner() {
        _requireCallerIsContractOwner();

        _;
    }
}
