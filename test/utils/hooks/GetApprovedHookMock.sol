// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IGetApprovedHook} from "../../../src/interfaces/IGetApprovedHook.sol";

contract GetApprovedHookMock is IGetApprovedHook {
    bool public hooksEnabled;

    /// @notice toggle hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the function should use hook.
    /// @dev Returns whether or not to use the hook
    function useGetApprovedHook(uint256) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice Hook for custom implementation.
    /// @dev Returns the balance of the specified address
    function getApprovedOverrideHook(
        uint256
    ) external view override returns (address) {}
}
