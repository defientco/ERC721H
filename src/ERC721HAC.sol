// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IERC721HAC} from "./interfaces/IERC721HAC.sol";
import {ERC721AC} from "ERC721C/erc721c/ERC721AC.sol";

/**
 * @title ERC721HAC
 * @author Cre8ors Inc.
 * @notice Extends Limit Break's ERC721-AC implementation with Hook functionality, which
 *         allows the contract owner to override hooks associated with core ERC721 functions.
 */
contract ERC721HAC is IERC721HAC, ERC721AC {
    constructor(
        string memory _contractName,
        string memory _contractSymbol
    ) ERC721AC(_contractName, _contractSymbol) {}

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function balanceOf(
        address owner
    ) public view virtual override returns (uint256) {
        if (_useBalanceOfHook()) {
            return _overrideBalanceOf();
        }
        return super.balanceOf(owner);
    }

    function _requireCallerIsContractOwner() internal view virtual override {}

    function _overrideBalanceOf() internal view virtual returns (uint256) {}

    function _useBalanceOfHook() internal view virtual returns (bool) {}
}
