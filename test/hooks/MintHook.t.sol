// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {MintHookMock} from "../utils/hooks/MintHookMock.sol";

import {IERC721ACH} from "../../src/interfaces/IERC721ACH.sol";


contract MintHookTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0xC0FFEE);
    address public constant DEFAULT_BUYER_ADDRESS = address(0xBABE);
    ERC721ACHMock erc721Mock;
    MintHookMock hookMock;

    IERC721ACH.HookType constant Mint = IERC721ACH.HookType.Mint;    

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new MintHookMock();
    }

    function test_mintHook() public {
        assertEq(address(0), address(erc721Mock.getHook(Mint)));
    }

    

}
