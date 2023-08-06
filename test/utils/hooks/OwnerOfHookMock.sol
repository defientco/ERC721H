// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IOwnerOfHook} from "../../../src/interfaces/IOwnerOfHook.sol";

contract OwnerOfHookMock is IOwnerOfHook {
    /// @notice hook was executed
    error OwnerOfHook_Executed();

    bool public hooksEnabled;
    address public fixedOwner;

    /// @notice toggle ownerOf hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice set fixed owner returned by the hook.
    function setFixedOwner(address _fixedOwner) public {
        fixedOwner = _fixedOwner;
    }

    /// @notice Check if the ownerOf function should use hook.
    /// @dev Returns whether or not to use the hook for ownerOf function
    function useOwnerOfHook(uint256) external view override returns (bool) {
        return hooksEnabled;
    }

    /// @notice custom implementation for ownerOf Hook.
    function ownerOfHook(uint256) external pure override returns (address) {
        revert OwnerOfHook_Executed();
    }
}
