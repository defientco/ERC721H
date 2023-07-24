// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ITransferFromHook {
    /// @notice Emitted when transferFrom hook is used
    /// @param from The current owner of the token
    /// @param to The receiver of the token
    /// @param tokenId The ID of the token
    event TransferFromHookUsed(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );

    /// @notice transferFrom Hook for custom implementation.
    /// @param from The current owner of the NFT
    /// @param to The new owner
    /// @param tokenId The NFT to transfer
    function transferFromOverrideHook(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /// @notice Check if the transferFrom function should use hook.
    /// @param from The current owner of the NFT
    /// @param to The new owner
    /// @param tokenId The NFT to transfer
    /// @dev Returns whether or not to use the hook for transferFrom function
    function useTransferFromHook(
        address from,
        address to,
        uint256 tokenId
    ) external view returns (bool);
}
