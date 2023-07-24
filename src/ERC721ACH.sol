// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721AC} from "ERC721C/erc721c/ERC721AC.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";
import {IBalanceOfHook} from "./interfaces/IBalanceOfHook.sol";
import {IOwnerOfHook} from "./interfaces/IOwnerOfHook.sol";
import {ISafeTransferFromHook} from "./interfaces/ISafeTransferFromHook.sol";
import {ITransferFromHook} from "./interfaces/ITransferFromHook.sol";
import {IERC721ACH} from "./interfaces/IERC721ACH.sol";

/**
 * @title ERC721ACH
 * @author Cre8ors Inc.
 * @notice Extends Limit Break's ERC721-AC implementation with Hook functionality, which
 *         allows the contract owner to override hooks associated with core ERC721 functions.
 */
contract ERC721ACH is ERC721AC, IERC721ACH {
    /// @notice Emitted when approve hook is used
    /// @param approved The address that got approved
    /// @param tokenId The token ID that got approved
    event ApproveHookUsed(address indexed approved, uint256 indexed tokenId);

    /// @notice Emitted when setApprovalForAll hook is used
    /// @param owner The owner of the tokens
    /// @param operator The operator that got (dis)approved
    /// @param approved The approval status
    event SetApprovalForAllHookUsed(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /// @notice Emitted when transferFrom hook is used
    /// @param from The sender of the token
    /// @param to The receiver of the token
    /// @param tokenId The ID of the token
    event TransferFromHookUsed(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    IBalanceOfHook public balanceOfHook;
    IOwnerOfHook public ownerOfHook;
    ISafeTransferFromHook public safeTransferFromHook;
    ITransferFromHook public transferFromHook;

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
        if (_useApproveHook(approved, tokenId)) {
            emit ApproveHookUsed(approved, tokenId);
            _approveHook(approved, tokenId);
        } else {
            super.approve(approved, tokenId);
        }
    }

    /// @inheritdoc IERC721A
    function setApprovalForAll(
        address operator,
        bool approved
    ) public virtual override {
        if (_useSetApprovalForAllHook(msg.sender, operator, approved)) {
            emit SetApprovalForAllHookUsed(msg.sender, operator, approved);
            _setApprovalForAllHook(msg.sender, operator, approved);
        } else {
            super.setApprovalForAll(operator, approved);
        }
    }

    /// @inheritdoc IERC721A
    function getApproved(
        uint256 tokenId
    ) public view virtual override returns (address) {
        if (_useGetApprovedHook(tokenId)) {
            return _getApprovedHook(tokenId);
        }
        return super.getApproved(tokenId);
    }

    /// @inheritdoc IERC721A
    function isApprovedForAll(
        address owner,
        address operator
    ) public view virtual override returns (bool) {
        if (_useIsApprovedForAllHook(owner, operator)) {
            return _isApprovedForAllHook(owner, operator);
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

    /// @notice approve Hook for custom implementation.
    /// @param approved The address to be approved for the given token ID
    /// @param tokenId The token ID to be approved
    function _approveHook(address approved, uint256 tokenId) internal virtual {}

    /// @notice Check if the approve function should use hook.
    /// @param approved The address to be approved for the given token ID
    /// @param tokenId The token ID to be approved
    /// @dev Returns whether or not to use the hook for approve function
    function _useApproveHook(
        address approved,
        uint256 tokenId
    ) internal view virtual returns (bool) {}

    /// @notice setApprovalForAll Hook for custom implementation.
    /// @param owner The address to extend operators for
    /// @param operator The address to add to the set of authorized operators
    /// @param approved True if the operator is approved, false to revoke approval
    function _setApprovalForAllHook(
        address owner,
        address operator,
        bool approved
    ) internal virtual {}

    /// @notice Check if the setApprovalForAll function should use hook.
    /// @param owner The address to extend operators for
    /// @param operator The address to add to the set of authorized operators
    /// @param approved True if the operator is approved, false to revoke approval
    /// @dev Returns whether or not to use the hook for setApprovalForAll function
    function _useSetApprovalForAllHook(
        address owner,
        address operator,
        bool approved
    ) internal view virtual returns (bool) {}

    /// @notice getApproved Hook for custom implementation.
    /// @param tokenId The token ID to query the approval of
    /// @dev Returns the approved address for a token ID, or zero if no address set
    function _getApprovedHook(
        uint256 tokenId
    ) internal view virtual returns (address) {}

    /// @notice Check if the getApproved function should use hook.
    /// @param tokenId The token ID to query the approval of
    /// @dev Returns whether or not to use the hook for getApproved function
    function _useGetApprovedHook(
        uint256 tokenId
    ) internal view virtual returns (bool) {}

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
    modifier onlyOwner() {
        _requireCallerIsContractOwner();

        _;
    }
}
