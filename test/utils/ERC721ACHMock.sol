// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721ACH} from "../../src/ERC721ACH.sol";

contract ERC721ACHMock is ERC721ACH {
    bool public hooksEnabled;
    address public owner;

    constructor(address _owner) ERC721ACH("ERC-721ACH Mock", "MOCK") {
        owner = _owner;
    }

    /// @notice error to verify approve hook was executed
    error ApproveHook_Executed();
    /// @notice error to verify setApprovalForAll hook was executed
    error SetApprovalForAllHook_Executed();

    function mint(address to, uint256 quantity) external {
        _mint(to, quantity);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _requireCallerIsContractOwner() internal view override(ERC721ACH) {
        // Derived contract's implementation here
        if (msg.sender != owner) {
            revert Access_OnlyOwner();
        }
    }

    /////////////////////////////////////////////////
    /// Hooks
    /////////////////////////////////////////////////

    function _setApprovalForAllHook(
        address,
        address,
        bool
    ) internal virtual override {
        revert SetApprovalForAllHook_Executed();
    }

    /////////////////////////////////////////////////
    /// Enable Hooks
    /////////////////////////////////////////////////
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    function _useSetApprovalForAllHook(
        address,
        address,
        bool
    ) internal view virtual override returns (bool) {
        return hooksEnabled;
    }

    function _useGetApprovedHook(
        uint256
    ) internal view virtual override returns (bool) {
        return hooksEnabled;
    }

    function _useIsApprovedForAllHook(
        address,
        address
    ) internal view virtual override returns (bool) {
        return hooksEnabled;
    }
}
