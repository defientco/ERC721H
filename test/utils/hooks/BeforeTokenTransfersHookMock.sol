// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IBeforeTokenTransfersHook} from "../../../src/interfaces/IBeforeTokenTransfersHook.sol";

contract BeforeTokenTransfersHookMock is IBeforeTokenTransfersHook {
    /// @notice hook was executed
    error BeforeTokenTransfersHook_Executed();

    /// @notice custom implementation for beforeTokenTransfers Hook.
    function beforeTokenTransfersHook(
        address,
        address,
        uint256,
        uint256
    ) external pure override {
        revert BeforeTokenTransfersHook_Executed();
    }
}
