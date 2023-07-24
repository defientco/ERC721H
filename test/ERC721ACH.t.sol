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
        assertEq(address(0), address(erc721Mock.balanceOfHook()));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setBalanceOfHook(IBalanceOfHook(hook));
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.balanceOfHook())
        );
    }

    function test_ownerOfHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.ownerOfHook()));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setOwnerOfHook(IOwnerOfHook(hook));
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.ownerOfHook())
        );
    }

    function test_safeTransferFromHook(address hook, address caller) public {
        assertEq(address(0), address(erc721Mock.safeTransferFromHook()));
        bool isOwner = caller == DEFAULT_OWNER_ADDRESS;
        vm.prank(caller);
        if (!isOwner) {
            vm.expectRevert(IERC721ACH.Access_OnlyOwner.selector);
        }
        erc721Mock.setSafeTransferFromHook(ISafeTransferFromHook(hook));
        assertEq(
            isOwner ? hook : address(0),
            address(erc721Mock.safeTransferFromHook())
        );
    }

    function test_approve(
        uint256 _mintQuantity,
        uint256 _tokenToApprove
    ) public {
        vm.assume(_mintQuantity > 0);
        vm.assume(_tokenToApprove > 0);
        vm.assume(_mintQuantity < 10_000);
        vm.assume(_tokenToApprove <= _mintQuantity);

        // Mint some tokens first
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, _mintQuantity);

        // Verify normal functionality
        assertEq(address(0), erc721Mock.getApproved(_tokenToApprove));
        vm.prank(DEFAULT_BUYER_ADDRESS);
        erc721Mock.approve(DEFAULT_OWNER_ADDRESS, _tokenToApprove);
        assertEq(
            DEFAULT_OWNER_ADDRESS,
            erc721Mock.getApproved(_tokenToApprove)
        );

        // Verify hook override
        erc721Mock.setHooksEnabled(true);
        vm.expectRevert(ERC721ACHMock.ApproveHook_Executed.selector);
        vm.prank(DEFAULT_BUYER_ADDRESS);
        erc721Mock.approve(DEFAULT_OWNER_ADDRESS, _tokenToApprove);
    }

    function test_setApprovalForAll(uint256 _mintQuantity) public {
        vm.assume(_mintQuantity > 0);
        vm.assume(_mintQuantity < 10_000);

        // Mint some tokens first
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, _mintQuantity);

        // Verify normal functionality
        assertTrue(
            !erc721Mock.isApprovedForAll(
                DEFAULT_BUYER_ADDRESS,
                DEFAULT_OWNER_ADDRESS
            )
        );
        vm.prank(DEFAULT_BUYER_ADDRESS);
        erc721Mock.setApprovalForAll(DEFAULT_OWNER_ADDRESS, true);
        assertTrue(
            erc721Mock.isApprovedForAll(
                DEFAULT_BUYER_ADDRESS,
                DEFAULT_OWNER_ADDRESS
            )
        );

        // Verify hook override
        erc721Mock.setHooksEnabled(true);
        vm.expectRevert(ERC721ACHMock.SetApprovalForAllHook_Executed.selector);
        vm.prank(DEFAULT_BUYER_ADDRESS);
        erc721Mock.setApprovalForAll(DEFAULT_OWNER_ADDRESS, true);
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
        erc721Mock.setHooksEnabled(true);
        vm.prank(DEFAULT_BUYER_ADDRESS);
        assertEq(address(0), erc721Mock.getApproved(_tokenId));
    }

    function test_isApprovedForAll(uint256 _mintQuantity) public {
        vm.assume(_mintQuantity > 0);
        vm.assume(_mintQuantity < 10_000);

        // Mint some tokens first
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, _mintQuantity);

        // Verify normal functionality
        assertTrue(
            !erc721Mock.isApprovedForAll(
                DEFAULT_BUYER_ADDRESS,
                DEFAULT_OWNER_ADDRESS
            )
        );
        vm.prank(DEFAULT_BUYER_ADDRESS);
        erc721Mock.setApprovalForAll(DEFAULT_OWNER_ADDRESS, true);
        assertTrue(
            erc721Mock.isApprovedForAll(
                DEFAULT_BUYER_ADDRESS,
                DEFAULT_OWNER_ADDRESS
            )
        );

        // Verify hook override
        erc721Mock.setHooksEnabled(true);
        assertTrue(
            !erc721Mock.isApprovedForAll(
                DEFAULT_BUYER_ADDRESS,
                DEFAULT_OWNER_ADDRESS
            )
        );
    }

    function test_transferFrom(uint256 _mintQuantity, uint256 _tokenId) public {
        vm.assume(_tokenId > 0);
        vm.assume(_mintQuantity > 0);
        vm.assume(_mintQuantity < 10_000);
        vm.assume(_mintQuantity >= _tokenId);

        // Mint some tokens first
        erc721Mock.mint(DEFAULT_BUYER_ADDRESS, _mintQuantity);

        // Verify normal functionality
        assertEq(DEFAULT_BUYER_ADDRESS, erc721Mock.ownerOf(_tokenId));
        vm.prank(DEFAULT_BUYER_ADDRESS);
        erc721Mock.transferFrom(
            DEFAULT_BUYER_ADDRESS,
            DEFAULT_OWNER_ADDRESS,
            _tokenId
        );
        assertEq(DEFAULT_OWNER_ADDRESS, erc721Mock.ownerOf(_tokenId));

        // Verify hook override
        erc721Mock.setHooksEnabled(true);
        vm.expectRevert(ERC721ACHMock.TransferFromHook_Executed.selector);
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.transferFrom(
            DEFAULT_OWNER_ADDRESS,
            DEFAULT_BUYER_ADDRESS,
            _tokenId
        );
    }
}
