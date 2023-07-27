// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {TransferFromHookMock} from "../utils/hooks/TransferFromHookMock.sol";
import {IERC721ACH} from "../../src/interfaces/IERC721ACH.sol";


contract TransferFromTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_BUYER_ADDRESS = address(0x111);
    ERC721ACHMock erc721Mock;
    TransferFromHookMock hookMock;

    // this is to simplify the long constant name
    IERC721ACH.HookType constant TransferFrom = IERC721ACH.HookType.TransferFrom;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new TransferFromHookMock();
    }

    function test_transferFromHook() public {
        assertEq(address(0), address(erc721Mock.getHook(TransferFrom)));
    }

    function test_setTransferFromHook() public {
        assertEq(address(0), address(erc721Mock.getHook(TransferFrom)));
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setHook(TransferFrom, address(hookMock));
        assertEq(address(hookMock), address(erc721Mock.getHook(TransferFrom)));
    }

    function test_transferFrom(uint256 _mintQuantity, uint256 _tokenId) public {
        vm.assume(_tokenId > 0);
        vm.assume(_mintQuantity > 0);
        vm.assume(_mintQuantity < 10_000);
        vm.assume(_mintQuantity >= _tokenId);
        test_setTransferFromHook();

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
            TransferFromHookMock.TransferFromHook_Executed.selector
        );
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.transferFrom(
            DEFAULT_OWNER_ADDRESS,
            DEFAULT_BUYER_ADDRESS,
            _tokenId
        );
    }
}
