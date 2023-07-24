// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IApproveHook} from "../../../src/interfaces/IApproveHook.sol";

contract ApproveHookMock is IApproveHook {
    bool public hooksEnabled;

    /// @notice toggle approve hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the approve function should use hook.
    /// @dev Returns whether or not to use the hook for approve function
    function useApproveHook(
        address,
        uint256
    ) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice approve Hook for custom implementation.
    function approveOverrideHook(
        address,
        uint256
    ) external view override returns (uint256) {}
}
