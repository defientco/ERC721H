// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ISetApprovalForAllHook {
    /// @notice Emitted when setApprovalForAll hook is used
    /// @param owner The owner of the tokens
    /// @param operator The operator that got (dis)approved
    /// @param approved The approval status
    event SetApprovalForAllHookUsed(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /// @notice Check if the setApprovalForAll function should use hook.
    /// @param owner The address to extend operators for
    /// @param operator The address to add to the set of authorized operators
    /// @param approved True if the operator is approved, false to revoke approval
    /// @dev Returns whether or not to use the hook for setApprovalForAll function
    function useSetApprovalForAllHook(
        address owner,
        address operator,
        bool approved
    ) external view returns (bool);

    /// @notice setApprovalForAll Hook for custom implementation.
    /// @param owner The address to extend operators for
    /// @param operator The address to add to the set of authorized operators
    /// @param approved True if the operator is approved, false to revoke approval
    function setApprovalForAllOverrideHook(
        address owner,
        address operator,
        bool approved
    ) external;
}
