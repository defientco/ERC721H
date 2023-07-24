// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IIsApprovedForAllHook {
    /// @notice Check if the isApprovedForAll function should use hook.
    /// @param owner The address that owns the NFTs
    /// @param operator The address that acts on behalf of the owner
    /// @dev Returns whether or not to use the hook for isApprovedForAll function
    function useIsApprovedForAllHook(
        address owner,
        address operator
    ) external view returns (bool);

    /// @notice isApprovedForAll Hook for custom implementation.
    /// @param owner The address that owns the NFTs
    /// @param operator The address that acts on behalf of the owner
    /// @dev Returns whether an operator is approved by a given owner
    function isApprovedForAllOverrideHook(
        address owner,
        address operator
    ) external view returns (bool);
}
