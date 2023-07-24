// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IIsApprovedForAllHook} from "../../../src/interfaces/IIsApprovedForAllHook.sol";

contract IsApprovedForAllHookMock is IIsApprovedForAllHook {
    bool public hooksEnabled;

    /// @notice toggle hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the function should use hook.
    /// @dev Returns whether or not to use the hook
    function useIsApprovedForAllHook(
        address,
        address
    ) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice Hook for custom implementation.
    /// @dev Returns the balance of the specified address
    function isApprovedForAllOverrideHook(
        address,
        address
    ) external view override returns (bool) {}
}
