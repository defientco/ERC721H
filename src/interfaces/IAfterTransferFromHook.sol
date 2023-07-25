// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

<<<<<<< HEAD
interface IAfterTransferFrom {
=======
interface IAfterTransferFromHook {
>>>>>>> ac1aa85ec99aa5c52d853c6a3dd74e1f32777c8f
    /// @notice Emitted when afterTansferFrom hook is used
    /// @param from The current owner of the token
    /// @param to The receiver of the token
    /// @param tokenId The ID of the token
    event AfterTransferFromHookUsed(
        address indexed from,
        address indexed to,
        uint256 tokenId
    );

    /// @notice afterTransferFrom Hook for custom implementation.
    /// @param from The current owner of the NFT
    /// @param to The new owner
    /// @param tokenId The NFT to transfer
    function afterTransferFromOverrideHook(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /// @notice Check if the AfterTansferFrom function should use hook.
    /// @param from The current owner of the NFT
    /// @param to The new owner
    /// @param tokenId The NFT to transfer
    /// @dev Returns whether or not to use the hook for transferFrom function
    function useAfterTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external view returns (bool);
}
