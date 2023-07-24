// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC721ACH {
    /// @notice error onlyOwner
    error Access_OnlyOwner();

    /// @notice Emitted when balanceOf hook is used
    /// @param caller The caller
    /// @param hook The new hook
    event UpdatedHook_BalanceOf(address indexed caller, address indexed hook);

    /// @notice Emitted when ownerOf hook is set
    /// @param caller The caller
    /// @param hook The new hook
    event UpdatedHook_OwnerOf(address indexed caller, address indexed hook);

    /// @notice Emitted when safeTransferFrom hook is set
    /// @param caller The caller
    /// @param hook The new hook
    event UpdatedHook_SafeTransferFrom(
        address indexed caller,
        address indexed hook
    );
}
