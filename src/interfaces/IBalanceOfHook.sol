// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IBalanceOfHook {
    /// @notice Check if the balanceOf function should use hook.
    /// @param owner The address to query the balance of
    /// @dev Returns whether or not to use the hook for balanceOf function
    function useBalanceOfHook(address owner) external view returns (bool);

    /// @notice balanceOf Hook for custom implementation.
    /// @param owner The address to query the balance of
    /// @dev Returns the balance of the specified address
    function balanceOfOverrideHook(
        address owner
    ) external view returns (uint256);
}
