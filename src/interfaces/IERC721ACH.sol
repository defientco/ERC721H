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

    enum HookType {
        BalanceOf,
        OwnerOf,
        SafeTransferFrom,
        TransferFrom,
        Approve,
        SetApprovalForAll,
        GetApproved,
        IsApprovedForAll,
        BeforeTokenTransfers,
        AfterTokenTransfers,
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
