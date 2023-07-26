// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IBeforeTokenTransfersHook} from "../../../src/interfaces/IBeforeTokenTransfersHook.sol";

contract BeforeTokenTransfersHookMock is IBeforeTokenTransfersHook {
    /// @notice error to safeTransferFrom approve hook was executed
    error BeforeTokenTransfersHook_Executed();

    bool public hooksEnabled;

    /// @notice toggle balanceOf hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the beforeTokenTransfer function should use hook.
    /// @dev Returns whether or not to use the hook for beforeTokenTransfers function
    function useBeforeTokenTransfersFrom(
        address,
        address,
        uint256,
        uint256
    ) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice balanceOf Hook for custom implementation.
    /// @dev Returns the balance of the specified address
    function beforeTokenTransfersOverrideHook(
        address,
        address,
        uint256,
        uint256
    ) external pure override {
        revert BeforeTokenTransfersHook_Executed();
    }
}
