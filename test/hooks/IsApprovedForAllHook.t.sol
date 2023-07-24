// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {IsApprovedForAllHookMock} from "../utils/Hooks/IsApprovedForAllHookMock.sol";

contract IsApprovedForAllHookTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_BUYER_ADDRESS = address(0x111);
    ERC721ACHMock erc721Mock;
    IsApprovedForAllHookMock hookMock;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new IsApprovedForAllHookMock();
    }

    function test_isApprovedForAllHook() public {
        assertEq(address(0), address(erc721Mock.isApprovedForAllHook()));
    }

    function test_setIsApprovedForAllHook() public {
        assertEq(address(0), address(erc721Mock.isApprovedForAllHook()));
        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setIsApprovedForAllHook(hookMock);
        assertEq(address(hookMock), address(erc721Mock.isApprovedForAllHook()));
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
        test_setIsApprovedForAllHook();
        hookMock.setHooksEnabled(true);
        assertTrue(
            !erc721Mock.isApprovedForAll(
                DEFAULT_BUYER_ADDRESS,
                DEFAULT_OWNER_ADDRESS
            )
        );
    }
}
