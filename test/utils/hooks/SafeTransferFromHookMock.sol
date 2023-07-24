// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ISafeTransferFromHook} from "../../../src/interfaces/ISafeTransferFromHook.sol";

contract SafeTransferFromHookMock is ISafeTransferFromHook {
    /// @notice error to safeTransferFrom approve hook was executed
    error SafeTransferFromHook_Executed();

    bool public hooksEnabled;

    /// @notice toggle balanceOf hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the balanceOf function should use hook.
    /// @dev Returns whether or not to use the hook for balanceOf function
    function useSafeTransferFromHook(
        address,
        address,
        address,
        uint256,
        bytes memory
    ) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice balanceOf Hook for custom implementation.
    /// @dev Returns the balance of the specified address
    function safeTransferFromOverrideHook(
        address,
        address,
        address,
        uint256,
        bytes memory
    ) external pure override {
        revert SafeTransferFromHook_Executed();
    }
}
