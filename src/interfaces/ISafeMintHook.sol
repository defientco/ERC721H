// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface ISafeMintHook {

    /// @notice Emitted when approve hook is used
    /// @param to The address to hold the minted token
    /// @param quantity The token quantity to be minted
    event SafeMintHookUsed(address indexed to, uint256 indexed quantity);

    /// @notice Check if the safeMint function should use hook.
    /// @param to The address to hold the minted token
    /// @param quantity The token quantity to be minted
    function useSafeMintHook(address to, uint256 quantity) public ;

    /// @notice safeMint Hook for custom implementation.
    /// @param to The address to hold the minted token
    /// @param quantity The token quantity to be minted
    function safeMintOverrideHook(
        address to,
        uint256 quantity
    ) external view returns (uint256);
}
