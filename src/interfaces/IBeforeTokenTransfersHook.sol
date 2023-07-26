// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IBeforeTokenTransfersHook {
    /// @notice Emitted when beforeTokenTransfers hook is used
    /// @param from The current owner of the token
    /// @param to The receiver of the token
    /// @param startTokenId The ID of the first token
    /// @param quantity The quantity to transfer
    event BeforeTokenTransfersHookUsed(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    );

    /// @notice beforeTokenTransfers hook for custom implementation
    /// @param from The current owner of the token
    /// @param to The receiver of the token
    /// @param startTokenId The ID of the first token
    /// @param quantity The quantity to transfer
    function beforeTokenTransfersOverrideHook(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) external;

    /// @notice Check if the beforeTokenTransfers hook function should use hook.
    /// @param from The current owner of the token
    /// @param to The receiver of the token
    /// @param startTokenId The ID of the first token
    /// @param quantity The quantity to transfer
    function useBeforeTokenTransfersFrom(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) external view returns (bool);
}
