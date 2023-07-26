// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IMintHook} from "../../../src/interfaces/IMintHook.sol";

contract MintHookMock is IMintHook {
    error MintHook_Executed();

    bool public hooksEnabled;

    /// @notice toggle hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice Check if the function should use hook.
    /// @dev Returns whether or not to use the hook
    function useMintHook(
        address,
        uint256
    ) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice custom implementation for mint Hook.
    function mintOverrideHook(
        address,
        uint256
    ) external view override returns (bool) {
        revert MintHook_Executed();
    }
}
