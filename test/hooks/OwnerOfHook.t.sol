// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {OwnerOfHookMock} from "../utils/Hooks/OwnerOfHookMock.sol";

contract OwnerOfHookTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_BUYER_ADDRESS = address(0x111);
    ERC721ACHMock erc721Mock;
    OwnerOfHookMock hookMock;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new OwnerOfHookMock();
    }

    function test_ownerOfHook() public {
        assertEq(address(0), address(erc721Mock.ownerOfHook()));
    }

    function test_setOwnerOfHook() public {
        assertEq(address(0), address(erc721Mock.ownerOfHook()));
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setOwnerOfHook(hookMock);
        assertEq(address(hookMock), address(erc721Mock.ownerOfHook()));
    }

    function test_ownerOf(uint256 _mintQuantity, address buyer) public {
        vm.assume(_mintQuantity > 0);
        vm.assume(_mintQuantity < 10_000);
        vm.assume(buyer != address(0));

        // Verify normal functionality
        vm.expectRevert();
        assertEq(address(0), erc721Mock.ownerOf(_mintQuantity));
        erc721Mock.mint(buyer, _mintQuantity);
        assertEq(address(buyer), erc721Mock.ownerOf(_mintQuantity));

        // Verify hook override
        test_setOwnerOfHook();
        hookMock.setHooksEnabled(true);
        assertEq(address(0), erc721Mock.ownerOf(_mintQuantity));
    }
}
