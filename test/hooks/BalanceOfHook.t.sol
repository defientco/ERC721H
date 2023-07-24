// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {BalanceOfHookMock} from "../utils/Hooks/BalanceOfHookMock.sol";

contract BalanceOfHookTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_BUYER_ADDRESS = address(0x111);
    ERC721ACHMock erc721Mock;
    BalanceOfHookMock hookMock;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new BalanceOfHookMock();
    }

    function test_balanceOfHook() public {
        assertEq(address(0), address(erc721Mock.balanceOfHook()));
    }

    function test_setBalanceOfHook() public {
        assertEq(address(0), address(erc721Mock.balanceOfHook()));
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setBalanceOfHook(hookMock);
        assertEq(address(hookMock), address(erc721Mock.balanceOfHook()));
    }

    function test_balanceOf(uint256 _mintQuantity) public {
        vm.assume(_mintQuantity > 0);
        vm.assume(_mintQuantity < 10_000);

        // Verify normal functionality
        assertEq(0, erc721Mock.balanceOf(DEFAULT_BUYER_ADDRESS));
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, _mintQuantity);
        assertEq(_mintQuantity, erc721Mock.balanceOf(DEFAULT_BUYER_ADDRESS));

        // Verify hook override
        test_setBalanceOfHook();
        hookMock.setHooksEnabled(true);
        assertEq(0, erc721Mock.balanceOf(DEFAULT_BUYER_ADDRESS));
    }
}
