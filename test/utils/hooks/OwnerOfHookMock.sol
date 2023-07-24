// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IOwnerOfHook} from "../../../src/interfaces/IOwnerOfHook.sol";

contract OwnerOfHookMock is IOwnerOfHook {
    bool hooksEnabled;

    /// @notice toggle balanceOf hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the balanceOf function should use hook.
    /// @dev Returns whether or not to use the hook for balanceOf function
    function useOwnerOfHook(uint256) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice balanceOf Hook for custom implementation.
    /// @dev Returns the balance of the specified address
    function ownerOfOverrideHook(
        uint256
    ) external view override returns (address) {}
}
