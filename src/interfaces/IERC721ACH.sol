// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IBalanceOfHook} from "./IBalanceOfHook.sol";
import {IOwnerOfHook} from "./IOwnerOfHook.sol";
import {ISafeTransferFromHook} from "./ISafeTransferFromHook.sol";
import {ITransferFromHook} from "./ITransferFromHook.sol";
import {IApproveHook} from "./IApproveHook.sol";
import {ISetApprovalForAllHook} from "./ISetApprovalForAllHook.sol";
import {IGetApprovedHook} from "./IGetApprovedHook.sol";
import {IIsApprovedForAllHook} from "./IIsApprovedForAllHook.sol";

interface IERC721ACH {
    /// @notice error onlyOwner
    error Access_OnlyOwner();

    /// think do we also need events here 🤔

    /**
        * @dev Enumerated list of all available hook types for the ERC721ACH contract.
    */
    enum HookType {
        /// @notice Hook for custom logic when querying the balance of an address.
        BalanceOf,
        /// @notice Hook for custom logic when querying the owner of a token.
        OwnerOf,
        /// @notice Hook for custom logic during a safe transfer.
        SafeTransferFrom,
        /// @notice Hook for custom logic during a transfer.
        TransferFrom,
        /// @notice Hook for custom logic when approving a token.
        Approve,
        /// @notice Hook for custom logic when setting approval for all tokens of an address.
        SetApprovalForAll,
        /// @notice Hook for custom logic when getting the approved address for a token.
        GetApproved,
        /// @notice Hook for custom logic when checking if an address is approved for all tokens of another address.
        IsApprovedForAll,
        /// @notice Hook for custom logic before a token transfer occurs.
        BeforeTokenTransfers,
        /// @notice Hook for custom logic after a token transfer occurs.
        AfterTokenTransfers,
        /// @notice Hook for custom logic during token minting.
        Mint
    }


    /**
     * @notice Sets the contract address for a specified hook type.
     * @param hookType The type of hook to set, as defined in the HookType enum.
     * @param hookAddress The address of the contract implementing the hook interface.
     */
    function setHook(HookType hookType, address hookAddress) external;

    /**
     * @notice Returns the contract address for a specified hook type.
     * @param hookType The type of hook to set, as defined in the HookType enum.
     * @return The address of the contract implementing the hook interface.
     */
    function getHook(HookType hookType) external view returns (address);

}
