# ERC721H

- extends [ERC721A](https://www.azuki.com/erc721a)
- extends [ERC721C](https://github.com/limitbreakinc/creator-token-contracts)
- implemented in [CRE8ORS](https://twitter.com/Cre8orsNFT)

### Getting Started

- install [forge](https://mirror.xyz/crisgarner.eth/BhQzl33tthkJJ3Oh2ehAD_2FXGGlMupKlrUUcDk0ALA)
- run `forge test`

### Features

- ERC721AH (TODO): supports ERC721A
- ERC721CH (TODO): supports ERC721C
- ERC721ACH: supports both ERC721A & ERC721C.

### Admin capabilities

- owner can manage hooks
- `_requireCallerIsContractOwner` - override to set custom rules for ownership.

### TODO

- finish setting up `IMethodHooks.sol`
- calculate gas costs (Minting / Contract Deployment / Transfers) compared to ERC721A
- Migrate Staking to Hooks
- Subscription for Hooks ([ERC5643](https://eips.ethereum.org/EIPS/eip-5643))
- NATSPEC docs (TODOs)
- ERC721AH
- ERC721CH
- update README
