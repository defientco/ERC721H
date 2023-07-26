// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {BeforeTokenTransfersHookMock} from "../utils/hooks/BeforeTokenTransfersHookMock.sol";

contract TransferFromTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_BUYER_ADDRESS = address(0x111);
    ERC721ACHMock erc721Mock;
    BeforeTokenTransfersHookMock hookMock;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new BeforeTokenTransfersHookMock();
    }

    function test_beforeTokenTansfersHook() public {
        assertEq(address(0), address(erc721Mock.beforeTokenTransfersHook()));
    }

    function test_setBeforeTokenTransfersHook() public {
        assertEq(address(0), address(erc721Mock.beforeTokenTransfersHook()));
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setBeforeTokenTransfersHook(hookMock);
        assertEq(address(hookMock), address(erc721Mock.beforeTokenTransfersHook()));
    }

    function test_beforeTokenTransfersHook(uint256 _mintQuantity, uint256 _tokenId) public {
        vm.assume(_tokenId > 0);
        vm.assume(_mintQuantity > 0);
        vm.assume(_mintQuantity < 10_000);
        vm.assume(_mintQuantity >= _tokenId);
        test_setBeforeTokenTransfersHook();

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
        hookMock.setHooksEnabled(true);
        vm.expectRevert(
            BeforeTokenTransfersHookMock.BeforeTokenTransfersHook_Executed.selector
        );
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.transferFrom(
            DEFAULT_OWNER_ADDRESS,
            DEFAULT_BUYER_ADDRESS,
            _tokenId
        );
    }
}
