// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721ACH} from "../../src/ERC721ACH.sol";

contract ERC721ACHMock is ERC721ACH {
    constructor() ERC721ACH("ERC-721ACH Mock", "MOCK") {}

    bool hooksEnabled;

    /// @notice error to verify hook was executed
    error Hook_Executed();
    error SetApprovalForAllHook_Executed();
    error TransferFromHook_Executed();
    error SafeTransferFromHook_Executed();

    function mint(address to, uint256 quantity) external {
        _mint(to, quantity);
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function _requireCallerIsContractOwner() internal view override(ERC721ACH) {
        // Derived contract's implementation here
    }

    /////////////////////////////////////////////////
    /// Hooks
    /////////////////////////////////////////////////

    function _approveHook(address, uint256) internal virtual override {
        revert Hook_Executed();
    }

    function _setApprovalForAllHook(
        address,
        address,
        bool
    ) internal virtual override {
        revert SetApprovalForAllHook_Executed();
    }

    function _transferFromHook(
        address,
        address,
        uint256
    ) internal virtual override {
        revert TransferFromHook_Executed();
    }

    function _safeTransferFromHook(
        address,
        address,
        address,
        uint256,
        bytes memory
    ) internal virtual override {
        revert SafeTransferFromHook_Executed();
    }

    /////////////////////////////////////////////////
    /// Enable Hooks
    /////////////////////////////////////////////////
    function setHooksEnabled(bool _enabled) public {
        hooksEnabled = _enabled;
    }

    function _useBalanceOfHook(
        address
    ) internal view virtual override returns (bool) {
        return hooksEnabled;
    }

    function _useOwnerOfHook(
        uint256
    ) internal view virtual override returns (bool) {
        return hooksEnabled;
    }

    function _useApproveHook(
        address,
        uint256
    ) internal view virtual override returns (bool) {
        return hooksEnabled;
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

    function _useTransferFromHook(
        address,
        address,
        uint256
    ) internal view virtual override returns (bool) {
        return hooksEnabled;
    }

    function _useSafeTransferFromHook(
        address,
        address,
        address,
        uint256,
        bytes memory
    ) internal view virtual override returns (bool) {
        return hooksEnabled;
    }
}
