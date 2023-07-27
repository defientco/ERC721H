// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IBalanceOfHook} from "./IBalanceOfHook.sol";
import {IOwnerOfHook} from "./IOwnerOfHook.sol";
import {ISafeTransferFromHook} from "./ISafeTransferFromHook.sol";
import {ITransferFromHook} from "./ITransferFromHook.sol";
import {IApproveHook} from "./IApproveHook.sol";
import {ISetApprovalForAllHook} from "./ISetApprovalForAllHook.sol";
import {IGetApprovedHook} from "./IGetApprovedHook.sol";
import {IIsApprovedForAllHook} from "./IIsApprovedForAllHook.sol";

interface IERC721ACH {
    /// @notice error onlyOwner
    error Access_OnlyOwner();


    /// TODO
    function setBalanceOfHook(IBalanceOfHook _hook) external;

    /// TODO
    function setOwnerOfHook(IOwnerOfHook _hook) external;

    /// TODO
    function setSafeTransferFromHook(ISafeTransferFromHook _hook) external;

    /// TODO
    function setTransferFromHook(ITransferFromHook _hook) external;

    /// TODO
    function setApproveHook(IApproveHook _hook) external;

    /// TODO
    function setSetApprovalForAllHook(ISetApprovalForAllHook _hook) external;

    /// TODO
    function setGetApprovedHook(IGetApprovedHook _hook) external;

    /// TODO
    function setIsApprovedForAllHook(IIsApprovedForAllHook _hook) external;
}
