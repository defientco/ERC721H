// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IGetApprovedHook {
    /// @notice Check if the getApproved function should use hook.
    /// @param tokenId The token ID to query the approval of
    /// @dev Returns whether or not to use the hook for getApproved function
    function useGetApprovedHook(uint256 tokenId) external view returns (bool);

    /// @notice getApproved Hook for custom implementation.
    /// @param tokenId The token ID to query the approval of
    /// @dev Returns the approved address for a token ID, or zero if no address set
    function getApprovedOverrideHook(
        uint256 tokenId
    ) external view returns (address);
}
