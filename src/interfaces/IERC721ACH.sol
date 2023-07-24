// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IBalanceOfHook} from "./IBalanceOfHook.sol";
import {IOwnerOfHook} from "./IOwnerOfHook.sol";
import {ISafeTransferFromHook} from "./ISafeTransferFromHook.sol";

interface IERC721ACH {
    /// @notice error onlyOwner
    error Access_OnlyOwner();

    /// @notice Emitted when balanceOf hook is used
    /// @param caller The caller
    /// @param hook The new hook
    event UpdatedHookBalanceOf(address indexed caller, address indexed hook);

    /// @notice Emitted when ownerOf hook is set
    /// @param caller The caller
    /// @param hook The new hook
    event UpdatedHookOwnerOf(address indexed caller, address indexed hook);

    /// @notice Emitted when safeTransferFrom hook is set
    /// @param caller The caller
    /// @param hook The new hook
    event UpdatedHookSafeTransferFrom(
        address indexed caller,
        address indexed hook
    );

    function setBalanceOfHook(IBalanceOfHook _hook) external;

    function setOwnerOfHook(IOwnerOfHook _hook) external;

    function setSafeTransferFromHook(ISafeTransferFromHook _hook) external;
}
