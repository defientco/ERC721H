// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IOwnerOfHook} from "../../../src/interfaces/IOwnerOfHook.sol";

contract OwnerOfHookMock is IOwnerOfHook {
    /// @notice hook was executed
    error OwnerOfHook_Executed();

    bool public revertOwnerOfOverrideHook;
    bool public hooksEnabled;
    address public fixedOwner;

    function setRevertOwnerOfOverrideHook(bool _enabled) public {
        revertOwnerOfOverrideHook = _enabled;
    }

    /// @notice toggle ownerOf hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice set fixed owner returned by the hook.
    function setFixedOwner(address _fixedOwner) public {
        fixedOwner = _fixedOwner;
    }

    /// @notice custom implementation for ownerOf Hook.
    function ownerOfHook(
        uint256
    ) external view override returns (address, bool) {
        if (revertOwnerOfOverrideHook) revert OwnerOfHook_Executed();
        return (fixedOwner, false); // run super
    }
}
