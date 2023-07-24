// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ISetApprovalForAllHook} from "../../../src/interfaces/ISetApprovalForAllHook.sol";

contract SetApprovalForAllHookMock is ISetApprovalForAllHook {
    /// @notice hook was executed
    error SetApprovalForAllHook_Executed();

    bool public hooksEnabled;

    /// @notice toggle approve hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the function should use hook.
    /// @dev Returns whether or not to use the hook for approve function
    function useSetApprovalForAllHook(
        address,
        address,
        bool
    ) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice approve Hook for custom implementation.
    function setApprovalForAllOverrideHook(
        address,
        address,
        bool
    ) external pure override {
        revert SetApprovalForAllHook_Executed();
    }
}
