// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "./utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {BalanceOfHookTest} from "./hooks/BalanceOfHook.t.sol";
import {IBalanceOfHook} from "../src/interfaces/IBalanceOfHook.sol";
import {IOwnerOfHook} from "../src/interfaces/IOwnerOfHook.sol";
import {ISafeTransferFromHook} from "../src/interfaces/ISafeTransferFromHook.sol";
import {ITransferFromHook} from "../src/interfaces/ITransferFromHook.sol";
import {IApproveHook} from "../src/interfaces/IApproveHook.sol";
import {ISetApprovalForAllHook} from "../src/interfaces/ISetApprovalForAllHook.sol";
import {IGetApprovedHook} from "../src/interfaces/IGetApprovedHook.sol";
import {IIsApprovedForAllHook} from "../src/interfaces/IIsApprovedForAllHook.sol";
import {IERC721ACH} from "../src/interfaces/IERC721ACH.sol";

contract ERC721ACHTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_BUYER_ADDRESS = address(0x111);
    ERC721ACHMock erc721Mock;

    function setUp() public {
        vm.startPrank(DEFAULT_OWNER_ADDRESS);
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        vm.stopPrank();
    }

    function test_Erc721() public {
        assertEq("ERC-721ACH Mock", erc721Mock.name());
        assertEq("MOCK", erc721Mock.symbol());
    }

    function test_balanceOfHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.getHook(IERC721ACH.HookType.BalanceOf)));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setHook(IERC721ACH.HookType.BalanceOf, hook);
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.getHook(IERC721ACH.HookType.BalanceOf))
        );
    }

    function test_ownerOfHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.getHook(IERC721ACH.HookType.OwnerOf)));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setHook(IERC721ACH.HookType.OwnerOf, hook);
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.getHook(IERC721ACH.HookType.OwnerOf))
        );
    }

    function test_safeTransferFromHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.getHook(IERC721ACH.HookType.SafeTransferFrom)));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setHook(IERC721ACH.HookType.SafeTransferFrom, hook);
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.getHook(IERC721ACH.HookType.SafeTransferFrom))
        );
    }

    function test_transferFromHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.getHook(IERC721ACH.HookType.TransferFrom)));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setHook(IERC721ACH.HookType.TransferFrom, hook);
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.getHook(IERC721ACH.HookType.TransferFrom))
        );
    }

    function test_approveHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.getHook(IERC721ACH.HookType.Approve)));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setHook(IERC721ACH.HookType.Approve, hook);
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.getHook(IERC721ACH.HookType.Approve))
        );
    }

    function test_setApprovalForAllHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.getHook(IERC721ACH.HookType.SetApprovalForAll)));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setHook(IERC721ACH.HookType.SetApprovalForAll, hook);
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.getHook(IERC721ACH.HookType.SetApprovalForAll))
        );
    }

    function test_getApprovedHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.getHook(IERC721ACH.HookType.GetApproved)));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setHook(IERC721ACH.HookType.GetApproved, hook);
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.getHook(IERC721ACH.HookType.GetApproved))
        );
    }

    function test_isApprovedForAllHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.getHook(IERC721ACH.HookType.IsApprovedForAll)));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setHook(IERC721ACH.HookType.IsApprovedForAll, hook);
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.getHook(IERC721ACH.HookType.IsApprovedForAll))
        );
    }
}
