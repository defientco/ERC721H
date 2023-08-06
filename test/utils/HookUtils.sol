// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Vm} from "forge-std/Vm.sol";
import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "./ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {IERC721ACH} from "../../src/interfaces/IERC721ACH.sol";

contract HookUtils is DSTest {
    address public constant DEFAULT_OWNER_ADDRESS = address(0xC0FFEE);
    address public constant DEFAULT_BUYER_ADDRESS = address(0xBABE);

    Vm public constant vm = Vm(HEVM_ADDRESS);

    function _assumeNotNull(address _wallet) internal pure {
        vm.assume(_wallet != address(0));
    }

    function _assumeGtZero(uint256 _num) internal pure {
        vm.assume(_num > 0);
    }

    function _assertNormalTransfer(
        address _target,
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        vm.prank(_from);
        ERC721ACHMock(_target).transferFrom(_from, _to, _tokenId);

        _assertOwner(_target, _to, _tokenId);
    }

    function _assertOwner(
        address _target,
        address _owner,
        uint256 _token
    ) internal {
        assertEq(_owner, ERC721ACHMock(_target).ownerOf(_token));
    }

    function _assertTransferRevert(
        address _target,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes4 _err
    ) internal {
        vm.prank(_from);
        vm.expectRevert(_err);
        ERC721ACHMock(_target).transferFrom(_from, _to, _tokenId);
    }

    function _setHook(
        address _target,
        IERC721ACH.HookType _type,
        address _hook
    ) internal {
        vm.prank(DEFAULT_OWNER_ADDRESS);
        ERC721ACHMock(_target).setHook(_type, address(_hook));
        assertEq(
            address(_hook),
            address(ERC721ACHMock(_target).getHook(_type))
        );
    }
}
