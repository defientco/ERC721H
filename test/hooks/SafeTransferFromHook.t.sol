// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {SafeTransferFromHookMock} from "../utils/Hooks/SafeTransferFromHookMock.sol";

contract SafeTransferFromTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_BUYER_ADDRESS = address(0x111);
    ERC721ACHMock erc721Mock;
    SafeTransferFromHookMock hookMock;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new SafeTransferFromHookMock();
    }

    function test_safeTransferFromHook() public {
        assertEq(address(0), address(erc721Mock.safeTransferFromHook()));
    }

    function test_setSafeTransferFromHook() public {
        assertEq(address(0), address(erc721Mock.safeTransferFromHook()));
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setSafeTransferFromHook(hookMock);
        assertEq(address(hookMock), address(erc721Mock.safeTransferFromHook()));
    }

    function test_safeTransferFrom_WithData(
        uint256 _mintQuantity,
        uint256 _tokenId,
        bytes memory data,
        address buyer
    ) public {
        vm.assume(_mintQuantity > 0);
        vm.assume(_tokenId > 0);
        vm.assume(_mintQuantity < 10_000);
        vm.assume(_mintQuantity >= _tokenId);
        vm.assume(buyer != address(0));

        // Mint some tokens first
        test_setSafeTransferFromHook();
        erc721Mock.mint(buyer, _mintQuantity);

        // Verify normal functionality
        vm.prank(buyer);
        erc721Mock.safeTransferFrom(
            buyer,
            DEFAULT_OWNER_ADDRESS,
            _tokenId,
            data
        );
        assertEq(DEFAULT_OWNER_ADDRESS, erc721Mock.ownerOf(_tokenId));

        // Verify hook override
        hookMock.setHooksEnabled(true);
        vm.expectRevert(
            SafeTransferFromHookMock.SafeTransferFromHook_Executed.selector
        );
        vm.prank(buyer);
        erc721Mock.safeTransferFrom(
            buyer,
            DEFAULT_OWNER_ADDRESS,
            _tokenId,
            data
        );
    }

    function test_safeTransferFrom_WithoutData(
        uint256 _mintQuantity,
        uint256 _tokenId
    ) public {
        vm.assume(_tokenId > 0);
        vm.assume(_mintQuantity > 0);
        vm.assume(_mintQuantity < 10_000);
        vm.assume(_mintQuantity >= _tokenId);

        // Mint some tokens first
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, _mintQuantity);

        // Verify normal functionality
        vm.prank(DEFAULT_BUYER_ADDRESS);
        erc721Mock.safeTransferFrom(
            DEFAULT_BUYER_ADDRESS,
            DEFAULT_OWNER_ADDRESS,
            _tokenId
        );
        assertEq(DEFAULT_OWNER_ADDRESS, erc721Mock.ownerOf(_tokenId));

        // Verify hook override
        hookMock.setHooksEnabled(true);
        test_setSafeTransferFromHook();
        vm.expectRevert(
            SafeTransferFromHookMock.SafeTransferFromHook_Executed.selector
        );
        vm.prank(DEFAULT_BUYER_ADDRESS);
        erc721Mock.safeTransferFrom(
            DEFAULT_BUYER_ADDRESS,
            DEFAULT_OWNER_ADDRESS,
            _tokenId
        );
    }
}
