// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title IMintHook
/// @dev Interface that defines hooks to be executed when minting.
interface IMintHook {

    /**
        @notice Emitted when the Mint hook is used.
        @param to Address to which the tokens are being transferred.
        @param quantity The number of tokens being transferred.
    
     */
    event MintHookUsed(
        address to,
        uint256 quantity
    );

    /**
        @notice Checks if the _mint function should use the custom hook.
        @param to Address to which the tokens are being transferred.
        @param quantity The number of tokens being transferred.
        @return A boolean indicating whether or not to use the custom hook for the _mint function.
        
     */
    function useMintHook(
        address to,
        uint256 quantity
    ) external view returns (bool);

    /**
        @notice Provides a custom implementation for the _mint process.
        @param to Address to which the tokens are being transferred.
        @param quantity The number of tokens being transferred.
            
     */
    function MintOverrideHook(
       address to,
        uint256 quantity
    ) external;
}
