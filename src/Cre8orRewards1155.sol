// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC1155} from "lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155PresetMinterPauser} from "lib/openzeppelin-contracts/contracts/token/ERC1155/presets/ERC1155PresetMinterPauser.sol";
import {ERC1155Supply} from "lib/openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

/**
 ██████╗██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝
██║     ██████╔╝█████╗  ╚█████╔╝██║   ██║██████╔╝███████╗
██║     ██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██╗╚════██║
╚██████╗██║  ██║███████╗╚█████╔╝╚██████╔╝██║  ██║███████║
 ╚═════╝╚═╝  ╚═╝╚══════╝ ╚════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝                                                       
 */
/// @dev inspiration: https://github.com/ourzora/zora-drops-contracts
contract Cre8orRewards1155 is ERC1155PresetMinterPauser, ERC1155Supply {
    constructor(string memory uri) ERC1155PresetMinterPauser(uri) {}

    /// @dev See {ERC1155-_beforeTokenTransfer}.
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Supply, ERC1155PresetMinterPauser) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC1155PresetMinterPauser, ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
