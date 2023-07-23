// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IBalanceOfHook} from "../../../src/interfaces/IBalanceOfHook.sol";

contract BalanceOfHookMock is IBalanceOfHook {
    bool hooksEnabled;

    /// @notice toggle balanceOf hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the balanceOf function should use hook.
    /// @dev Returns whether or not to use the hook for balanceOf function
    function useBalanceOfHook(address) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice balanceOf Hook for custom implementation.
    /// @param owner The address to query the balance of
    /// @dev Returns the balance of the specified address
    function balanceOfOverrideHook(
        address owner
    ) external view override returns (uint256) {}
}
