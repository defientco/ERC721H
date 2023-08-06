// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {AfterTokenTransfersHookMock} from "../utils/hooks/AfterTokenTransfersHookMock.sol";
import {HookUtils} from "../utils/HookUtils.sol";

import {IERC721ACH} from "../../src/interfaces/IERC721ACH.sol";

contract AfterTokenTransfersHookTest is DSTest, HookUtils {
    ERC721ACHMock erc721Mock;
    AfterTokenTransfersHookMock hookMock;

    IERC721ACH.HookType constant AfterTokenTransfers =
        IERC721ACH.HookType.AfterTokenTransfers;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new AfterTokenTransfersHookMock();
    }

    function test_afterTokenTransfersHook() public {
        assertEq(address(0), address(erc721Mock.getHook(AfterTokenTransfers)));
    }

    function test_setAfterTokenTransfersHook() public {
        assertEq(address(0), address(erc721Mock.getHook(AfterTokenTransfers)));

        // calling an admin function without being the contract owner should revert
        vm.expectRevert();
        erc721Mock.setHook(AfterTokenTransfers, address(hookMock));

        //  Verify Success
        _setHook(address(erc721Mock), AfterTokenTransfers, address(hookMock));
    }

    function test_afterTokenTransfersHook(
        address _firstOwner,
        address _secondOwner,
        uint256 startTokenId,
        uint256 quantity
    ) public {
        _assumeGtZero(quantity);
        _assumeGtZero(startTokenId);
        vm.assume(quantity < 10_000);
        vm.assume(quantity >= startTokenId);
        _assumeNotNull(_firstOwner);
        _assumeNotNull(_secondOwner);

        // Mint some tokens first
        erc721Mock.mint(_firstOwner, quantity);
        _assertNormalTransfer(
            address(erc721Mock),
            _firstOwner,
            _secondOwner,
            startTokenId
        );

        // Verify hook override
        test_setAfterTokenTransfersHook();
        _assertTransferRevert(
            address(erc721Mock),
            _secondOwner,
            _firstOwner,
            startTokenId,
            AfterTokenTransfersHookMock
                .AfterTokenTransfersHook_Executed
                .selector
        );
    }

    function test_turn_off_hook(
        address _firstOwner,
        address _secondOwner,
        uint256 startTokenId,
        uint256 quantity
    ) public {
        test_afterTokenTransfersHook(
            _firstOwner,
            _secondOwner,
            startTokenId,
            quantity
        );

        _setHook(address(erc721Mock), AfterTokenTransfers, address(0));
        _assertNormalTransfer(
            address(erc721Mock),
            _secondOwner,
            _firstOwner,
            startTokenId
        );
    }
}
