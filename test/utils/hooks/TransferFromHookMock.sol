// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ITransferFromHook} from "../../../src/interfaces/ITransferFromHook.sol";

contract TransferFromHookMock is ITransferFromHook {
    /// @notice error to safeTransferFrom approve hook was executed
    error TransferFromHook_Executed();

    bool public hooksEnabled;

    /// @notice toggle balanceOf hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the balanceOf function should use hook.
    /// @dev Returns whether or not to use the hook for balanceOf function
    function useTransferFromHook(
        address,
        address,
        uint256
    ) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice balanceOf Hook for custom implementation.
    /// @dev Returns the balance of the specified address
    function transferFromOverrideHook(
        address,
        address,
        uint256
    ) external pure override {
        revert TransferFromHook_Executed();
    }
}
