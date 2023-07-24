// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IOwnerOfHook {
    /// @notice ownerOf Hook for custom implementation.
    /// @param tokenId The token ID to query the owner of
    /// @dev Returns the owner of the specified token ID
    function ownerOfOverrideHook(
        uint256 tokenId
    ) external view returns (address);

    /// @notice Check if the ownerOf function should use hook.
    /// @param tokenId The token ID to query the owner of
    /// @dev Returns whether or not to use the hook for ownerOf function
    function useOwnerOfHook(uint256 tokenId) external view returns (bool);
}
