// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title IOwnerOfHook
/// @dev Interface that defines hooks for retrieving the owner of a token.
interface IOwnerOfHook {

    /**
        @notice Emitted when the owner of hook is used.
        @param tokenId The ID of the token whose owner is being retrieved.
        @param owner The address of the owner of the token.
     */
    event OwnerOfHookUsed(
        uint256 tokenId,
        address owner
    );

    /**
        @notice Checks if the owner retrieval function should use the custom hook.
        @param tokenId The ID of the token whose owner is being retrieved.
        @return A boolean indicating whether or not to use the custom hook for the owner retrieval function.
     */
    function useOwnerOfHook(
        uint256 tokenId
    ) external view returns (bool);

    /**
        @notice Provides a custom implementation for the owner retrieval process.
        @param tokenId The ID of the token whose owner is being retrieved.
        @return The address of the owner of the token.
     */
    function ownerOfOverrideHook(
        uint256 tokenId
    ) external view returns (address);
}