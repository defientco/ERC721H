// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IBeforeTransferFromHook {
    /// @notice Emitted when beforeTansferFrom hook is used
    /// @param from The current owner of the token
    /// @param to The receiver of the token
    /// @param tokenId The ID of the token
    event BeforeTransferFromHookUsed(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );

    /// @notice beforeTransferFrom Hook for custom implementation.
    /// @param from The current owner of the NFT
    /// @param to The new owner
    /// @param tokenId The NFT to transfer
    function beforeTransferFromOverrideHook(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /// @notice Check if the beforeTansferFrom function should use hook.
    /// @param from The current owner of the NFT
    /// @param to The new owner
    /// @param tokenId The NFT to transfer
    /// @dev Returns whether or not to use the hook for transferFrom function
    function useBeforeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external view returns (bool);
}
