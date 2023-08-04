// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721AC} from "ERC721C/erc721c/ERC721AC.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";
import {IBeforeTokenTransfersHook} from "./interfaces/IBeforeTokenTransfersHook.sol";
import {IAfterTokenTransfersHook} from "./interfaces/IAfterTokenTransfersHook.sol";
import {IERC721ACH} from "./interfaces/IERC721ACH.sol";

/**
 * @title ERC721ACH
 * @author Cre8ors Inc.
 * @notice Extends Limit Break's ERC721-AC implementation with Hook functionality, which
 *  allows the contract owner to override hooks associated with core ERC721 functions.
 */
contract ERC721ACH is ERC721AC, IERC721ACH {
    

    /**
    * @dev Mapping of hook types to their respective contract addresses.
    * Each hook type can be associated with a contract that implements the hook's logic.
    * Only the contract owner can set or update these hooks.
    */
    mapping(HookType => address) public hooks;


    event UpdatedHook(address indexed setter, HookType hookType, address indexed hookAddress);


    /// @notice Contract constructor
    /// @param _contractName The name for the token contract
    /// @param _contractSymbol The symbol for the token contract
    constructor(
        string memory _contractName,
        string memory _contractSymbol
    ) ERC721AC(_contractName, _contractSymbol) {}

    /// @inheritdoc IERC721A
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /////////////////////////////////////////////////
    /// ERC721 overrides
    /////////////////////////////////////////////////



    /// TODO
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        super._beforeTokenTransfers(from, to, startTokenId, quantity);
        IBeforeTokenTransfersHook beforeTokenTransfersHook = IBeforeTokenTransfersHook(hooks[HookType.BeforeTokenTransfers]);
        if (
            address(beforeTokenTransfersHook) != address(0) &&
            beforeTokenTransfersHook.useBeforeTokenTransfersHook(from, to, startTokenId, quantity)
        ) {
            beforeTokenTransfersHook.beforeTokenTransfersOverrideHook(
                from,
                to,
                startTokenId,
                quantity
            );
        } else {
            super._beforeTokenTransfers(from, to, startTokenId, quantity);
        }
    }

    /// TODO
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {

        super._afterTokenTransfers(from, to, startTokenId, quantity);
        IAfterTokenTransfersHook afterTokenTransfersHook = IAfterTokenTransfersHook(hooks[HookType.AfterTokenTransfers]);
        if (
            address(afterTokenTransfersHook) != address(0) &&
            afterTokenTransfersHook.useAfterTokenTransfersHook(from, to, startTokenId, quantity)
        ) {
            afterTokenTransfersHook.afterTokenTransfersOverrideHook(
                from,
                to,
                startTokenId,
                quantity
            );
        } else {
            super._afterTokenTransfers(from, to, startTokenId, quantity);
        }
    }


    /**
        * @notice Returns the contract address for a specified hook type.
        * @param hookType The type of hook to retrieve, as defined in the HookType enum.
        * @return The address of the contract implementing the hook interface.
    */
    function getHook(HookType hookType) external view returns (address) {
        return hooks[hookType];
    }

    /////////////////////////////////////////////////
    /// ERC721C Override
    /////////////////////////////////////////////////

    /// @notice Override the function to throw if caller is not contract owner
    function _requireCallerIsContractOwner() internal view virtual override {}

    /////////////////////////////////////////////////
    /// ERC721H Admin Controls
    /////////////////////////////////////////////////

    /**
        * @notice Sets the contract address for a specified hook type.
        * @param hookType The type of hook to set, as defined in the HookType enum.
        * @param hookAddress The address of the contract implementing the hook interface.
    */
    function setHook(HookType hookType, address hookAddress) external virtual onlyOwner {
        hooks[hookType] = hookAddress;
        emit UpdatedHook(msg.sender, hookType, hookAddress);
    }



    /// TODO
    modifier onlyOwner() {
        _requireCallerIsContractOwner();

        _;
    }
}
