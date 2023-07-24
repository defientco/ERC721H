// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ISafeTransferFromHook {
    /// @notice Emitted when safeTransferFrom hook is used
    /// @param sender The sender of the token
    /// @param from The current owner of the token
    /// @param to The receiver of the token
    /// @param tokenId The ID of the token
    /// @param data Additional data
    event SafeTransferFromHookUsed(
        address indexed sender,
        address indexed from,
        address indexed to,
        uint256 tokenId,
        bytes data
    );

    /// @notice safeTransferFrom Hook for custom implementation.
    /// @param sender The address which calls `safeTransferFrom`
    /// @param from The current owner of the NFT
    /// @param to The new owner
    /// @param tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `to`
    function safeTransferFromOverrideHook(
        address sender,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external;

    /// @notice Check if the safeTransferFrom function should use hook.
    /// @param sender The address which calls `safeTransferFrom`
    /// @param from The current owner of the NFT
    /// @param to The new owner
    /// @param tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `to`
    /// @dev Returns whether or not to use the hook for safeTransferFrom function
    function useSafeTransferFromHook(
        address sender,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external view returns (bool);
}
