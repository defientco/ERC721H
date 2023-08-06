// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {DSTest} from "ds-test/test.sol";
import {ERC721ACHMock} from "../utils/ERC721ACHMock.sol";
import {IERC721A} from "lib/ERC721A/contracts/IERC721A.sol";
import {OwnerOfHookMock} from "../utils/hooks/OwnerOfHookMock.sol";
import {IERC721ACH} from "../../src/interfaces/IERC721ACH.sol";
import {HookUtils} from "../utils/HookUtils.sol";

contract OwnerOfHookTest is DSTest, HookUtils {
    ERC721ACHMock erc721Mock;
    OwnerOfHookMock hookMock;

    IERC721ACH.HookType constant OwnerOf = IERC721ACH.HookType.OwnerOf;

    function setUp() public {
        erc721Mock = new ERC721ACHMock(DEFAULT_OWNER_ADDRESS);
        hookMock = new OwnerOfHookMock();
    }

    function test_ownerOfHook() public {
        assertEq(address(0), address(erc721Mock.getHook(OwnerOf)));
    }

    function test_setOwnerOfHook() public {
        assertEq(address(0), address(erc721Mock.getHook(OwnerOf)));

        // calling an admin function without being the contract owner should revert
        vm.expectRevert();
        erc721Mock.setHook(OwnerOf, address(hookMock));

        // set hook
        _setHook(address(erc721Mock), OwnerOf, address(hookMock));
    }

    function test_ownerOfHook(address _buyer, uint256 tokenId) public {
        vm.assume(tokenId > 0);
        vm.assume(tokenId < 10);
        _assumeNotNull(_buyer);

        test_setOwnerOfHook();
        erc721Mock.mint(_buyer, tokenId);
        _assertOwner(address(erc721Mock), _buyer, tokenId);

        // override
        hookMock.setHooksEnabled(true);
        _assertOwner(address(erc721Mock), address(0), tokenId);
    }

    function test_turn_off_hook(address _buyer, uint256 tokenId) public {
        test_ownerOfHook(_buyer, tokenId);

        // turn off hook
        hookMock.setHooksEnabled(false);
        _assertOwner(address(erc721Mock), _buyer, tokenId);
    }
}
