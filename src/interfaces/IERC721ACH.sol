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

    /// @notice Emitted when transferFrom hook is set
    /// @param caller The caller
    /// @param hook The new hook
    event UpdatedHookTransferFrom(address indexed caller, address indexed hook);

    /// TODO
    function setBalanceOfHook(IBalanceOfHook _hook) external;

    /// TODO
    function setOwnerOfHook(IOwnerOfHook _hook) external;

    /// TODO
    function setSafeTransferFromHook(ISafeTransferFromHook _hook) external;
}
