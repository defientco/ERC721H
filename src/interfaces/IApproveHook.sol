// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IApproveHook {
    /// @notice Emitted when approve hook is used
    /// @param approved The address that got approved
    /// @param tokenId The token ID that got approved
    event ApproveHookUsed(address indexed approved, uint256 indexed tokenId);

    /// @notice Check if the approve function should use hook.
    /// @param approved The address to be approved for the given token ID
    /// @param tokenId The token ID to be approved
    /// @dev Returns whether or not to use the hook for approve function
    function useApproveHook(
        address approved,
        uint256 tokenId
    ) external view returns (bool);

    /// @notice approve Hook for custom implementation.
    /// @param approved The address to be approved for the given token ID
    /// @param tokenId The token ID to be approved
    function approveOverrideHook(
        address approved,
        uint256 tokenId
    ) external view returns (uint256);
}
