// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {GetApprovedHookMock} from "../utils/Hooks/GetApprovedHookMock.sol";

contract GetApprovedHookTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_BUYER_ADDRESS = address(0x111);
    ERC721ACHMock erc721Mock;
    GetApprovedHookMock hookMock;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new GetApprovedHookMock();
    }

    function test_getApprovedHook() public {
        assertEq(address(0), address(erc721Mock.getApprovedHook()));
    }

    function test_setGetApprovedHook() public {
        assertEq(address(0), address(erc721Mock.getApprovedHook()));
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setGetApprovedHook(hookMock);
        assertEq(address(hookMock), address(erc721Mock.getApprovedHook()));
    }

    function test_getApproved(uint256 _mintQuantity, uint256 _tokenId) public {
        vm.assume(_tokenId > 0);
        vm.assume(_mintQuantity > 0);
        vm.assume(_mintQuantity < 10_000);
        vm.assume(_mintQuantity >= _tokenId);

        // Mint some tokens first
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, _mintQuantity);

        // Verify normal functionality
        assertEq(address(0), erc721Mock.getApproved(_tokenId));
        vm.prank(DEFAULT_BUYER_ADDRESS);
        erc721Mock.approve(DEFAULT_OWNER_ADDRESS, _tokenId);
        assertEq(DEFAULT_OWNER_ADDRESS, erc721Mock.getApproved(_tokenId));

        // Verify hook override
        test_setGetApprovedHook();
        hookMock.setHooksEnabled(true);
        vm.prank(DEFAULT_BUYER_ADDRESS);
        assertEq(address(0), erc721Mock.getApproved(_tokenId));
    }
}
