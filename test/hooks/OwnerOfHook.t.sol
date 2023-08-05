// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {OwnerOfHookMock} from "../utils/hooks/OwnerOfHookMock.sol";
import {IERC721ACH} from "../../src/interfaces/IERC721ACH.sol";

contract OwnerOfHookTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0xC0FFEE);
    address public constant DEFAULT_BUYER_ADDRESS = address(0xBABE);
    ERC721ACHMock erc721Mock;
    OwnerOfHookMock hookMock;

    IERC721ACH.HookType constant OwnerOf = IERC721ACH.HookType.OwnerOf;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new OwnerOfHookMock();
    }

    function test_ownerOfHook() public {
        assertEq(address(0), address(erc721Mock.getHook(OwnerOf)));
    }

    function test_setOwnerOfHook() public {
        assertEq(address(0), address(erc721Mock.getHook(OwnerOf)));

        // calling an admin function without being the contract owner should revert       
        vm.expectRevert();
        erc721Mock.setHook(OwnerOf, address(hookMock));
        
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setHook(OwnerOf, address(hookMock));
        assertEq(address(hookMock), address(erc721Mock.getHook(OwnerOf)));
    }

    function test_ownerOfHook(uint256 tokenId) public {
        vm.assume(tokenId > 0);
        vm.assume(tokenId < 10);

        test_setOwnerOfHook();
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, tokenId);

        assertEq(DEFAULT_BUYER_ADDRESS, erc721Mock.ownerOf(tokenId));

        hookMock.setHooksEnabled(true);
        vm.expectRevert(OwnerOfHookMock.OwnerOfHook_Executed.selector);
        erc721Mock.ownerOf(tokenId);
    }
}
