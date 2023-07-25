// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {SafeMintHookMock} from "../utils/hooks/SafeMintHookMock.sol";

contract SafeMintHook is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_BUYER_ADDRESS = address(0x111);
    ERC721ACHMock erc721Mock;
    SafeMintHookMock hookMock;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new SafeMintHookMock();
    }

    function test_mintHook() public {
        assertEq(address(0), address(erc721Mock.safeMintHook()));
    }

    function test_setSafeMintHook() public {
        assertEq(address(0), address(erc721Mock.safeMintHook()));
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setSafeMintHook(hookMock);
        assertEq(address(hookMock), address(erc721Mock.safeMintHook()));
    }

    function test_mint(
        uint256 _mintQuantity,
    ) public {
        vm.assume(_mintQuantity > 0);
        
        
        // Verify normal functionality
        uint256 preTotalSupply = erc721Mock.totalSupply();
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, _mintQuantity);
        uint256 totalSupply = erc721Mock.totalSupply();
        assertEq(preTotalSupply + _mintQuantity, totalSupply);
        
        // Verify hook override
        test_setSafeMintHook();
        hookMock.setSafeMintEnabled(true);
        uint256 preTotalSupply = erc721Mock.totalSupply();
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, _mintQuantity);
        uint256 totalSupply = erc721Mock.totalSupply();
        assertEq(preTotalSupply + _mintQuantity, totalSupply);
        
    }
}
