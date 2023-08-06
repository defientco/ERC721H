// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {BeforeTokenTransfersHookMock} from "../utils/hooks/BeforeTokenTransfersHookMock.sol";
import {HookUtils} from "../utils/HookUtils.sol";
import {IERC721ACH} from "../../src/interfaces/IERC721ACH.sol";

contract BeforeTokenTransfersHookTest is DSTest, HookUtils {
    ERC721ACHMock erc721Mock;
    BeforeTokenTransfersHookMock hookMock;
    IERC721ACH.HookType constant BeforeTokenTransfers =
        IERC721ACH.HookType.BeforeTokenTransfers;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new BeforeTokenTransfersHookMock();
    }

    function test_getHook_BeforeTokenTransfers() public {
        assertEq(address(0), address(erc721Mock.getHook(BeforeTokenTransfers)));
    }

    function test_setBeforeTokenTransfersHook() public {
        assertEq(address(0), address(erc721Mock.getHook(BeforeTokenTransfers)));

        // calling an admin function without being the contract owner should revert
        vm.expectRevert();
        erc721Mock.setHook(BeforeTokenTransfers, address(hookMock));

        vm.prank(DEFAULT_OWNER_ADDRESS);
        erc721Mock.setHook(BeforeTokenTransfers, address(hookMock));
        assertEq(
            address(hookMock),
            address(erc721Mock.getHook(BeforeTokenTransfers))
        );
    }

    function test_beforeTokenTransfersHook(
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
        test_setBeforeTokenTransfersHook();
        _assertTransferRevert(
            address(erc721Mock),
            _secondOwner,
            _firstOwner,
            startTokenId,
            BeforeTokenTransfersHookMock
                .BeforeTokenTransfersHook_Executed
                .selector
        );
    }

    function _assertHookRevert(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        vm.prank(_from);
        vm.expectRevert(
            BeforeTokenTransfersHookMock
                .BeforeTokenTransfersHook_Executed
                .selector
        );
        erc721Mock.transferFrom(_from, _to, _tokenId);
    }
}
