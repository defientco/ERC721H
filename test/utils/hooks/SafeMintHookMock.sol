// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ISafeMintHook} from "../../../src/interfaces/ISafeMintHook";

contract SafeMintHookMock is ISafeMintHook {
    /// @notice safeMint hook was executed
    error SafeMintHook_Executed();

    bool public hooksEnabled;

    /// @notice toggle safeMint hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the safeMint function should use hook.
    /// @dev Returns whether or not to use the hook for safeMint function
    function useSafeMintHook(
        address to,
        uint256 quantity
    ) external view override{
        require(quantity > 0, "SafeMintHook: Invalid Qualtity")
    }

     /// @notice safeMint Hook for custom implementation.
    function safeMintOverrideHook(
        address,
        uint256
    ) external pure override {
        revert SafeMintHook_Executed();
    }
}
