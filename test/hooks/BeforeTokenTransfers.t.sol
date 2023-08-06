// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {BeforeTokenTransfersHookMock} from "../utils/hooks/BeforeTokenTransfersHookMock.sol";
import {IERC721ACH} from "../../src/interfaces/IERC721ACH.sol";

contract BeforeTokenTransfersHookTest is DSTest {
    Vm public constant vm = Vm(HEVM_ADDRESS);
    address public constant DEFAULT_OWNER_ADDRESS = address(0xC0FFEE);
    address public constant DEFAULT_BUYER_ADDRESS = address(0xBABE);
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
        vm.assume(quantity > 0);
        vm.assume(startTokenId > 0);
        vm.assume(quantity < 10_000);
        vm.assume(quantity >= startTokenId);
        _assumeNotBurn(_firstOwner);

        // Mint some tokens first
        erc721Mock.mint(_firstOwner, quantity);
        _assertNormalTransfer(_firstOwner, _secondOwner, startTokenId);

        // Verify hook override
        test_setBeforeTokenTransfersHook();
        _assertHookRevert(_secondOwner, _firstOwner, startTokenId);
    }

    function _assumeNotBurn(address _wallet) internal pure {
        vm.assume(_wallet != address(0));
    }

    function _assertNormalTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        vm.prank(_from);
        erc721Mock.transferFrom(_from, _to, _tokenId);

        _assertOwner(_to, _tokenId);
    }

    function _assertOwner(address _owner, uint256 _token) internal {
        assertEq(_owner, erc721Mock.ownerOf(_token));
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
