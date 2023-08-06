// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IAfterTokenTransfersHook} from "../../../src/interfaces/IAfterTokenTransfersHook.sol";

contract AfterTokenTransfersHookMock is IAfterTokenTransfersHook {
    /// @notice hook was executed
    error AfterTokenTransfersHook_Executed();

    bool public hooksEnabled;

    /// @notice toggle balanceOf hook.
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    /// @notice custom implementation for AfterTokenTransfers Hook.
    function afterTokenTransfersHook(
        address,
        address,
        uint256,
        uint256
    ) external pure override {
        revert AfterTokenTransfersHook_Executed();
    }
}
