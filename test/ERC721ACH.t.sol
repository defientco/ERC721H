// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "./utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";

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

}
