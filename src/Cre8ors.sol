// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ERC721AC} from "ERC721C/erc721c/ERC721AC.sol";
import {IERC721A} from "erc721a/contracts/IERC721A.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IERC2981, IERC165} from "@openzeppelin/contracts/interfaces/IERC2981.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {IERC721Drop} from "./interfaces/IERC721Drop.sol";
import {IMetadataRenderer} from "./interfaces/IMetadataRenderer.sol";
import {ILockup} from "./interfaces/ILockup.sol";
import {ERC721DropStorageV1} from "./storage/ERC721DropStorageV1.sol";
import {OwnableSkeleton} from "./utils/OwnableSkeleton.sol";
import {IOwnable} from "./interfaces/IOwnable.sol";
import {Cre8ing} from "./Cre8ing.sol";
import {Cre8orsERC6551} from "./utils/Cre8orsERC6551.sol";

/**
 ██████╗██████╗ ███████╗ █████╗  ██████╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██╔══██╗██╔═══██╗██╔══██╗██╔════╝
██║     ██████╔╝█████╗  ╚█████╔╝██║   ██║██████╔╝███████╗
██║     ██╔══██╗██╔══╝  ██╔══██╗██║   ██║██╔══██╗╚════██║
╚██████╗██║  ██║███████╗╚█████╔╝╚██████╔╝██║  ██║███████║
 ╚═════╝╚═╝  ╚═╝╚══════╝ ╚════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝                                                       
 */
/// @dev inspiration: https://github.com/ourzora/zora-drops-contracts
contract Cre8ors is
    ERC721AC,
    Cre8ing,
    IERC2981,
    ReentrancyGuard,
    IERC721Drop,
    OwnableSkeleton,
    ERC721DropStorageV1,
    Cre8orsERC6551
{
    /// @dev This is the max mint batch size for the optimized ERC721AC mint contract
    uint256 internal constant MAX_MINT_BATCH_SIZE = 8;

    /// @dev Gas limit to send funds
    uint256 internal constant FUNDS_SEND_GAS_LIMIT = 210_000;

    /// @dev Lockup Contract
    ILockup public lockup;

    constructor(
        string memory _contractName,
        string memory _contractSymbol,
        address _initialOwner,
        address payable _fundsRecipient,
        uint64 _editionSize,
        uint16 _royaltyBPS,
        SalesConfiguration memory _salesConfig,
        IMetadataRenderer _metadataRenderer
    )
        ERC721AC(_contractName, _contractSymbol)
        ReentrancyGuard()
        Cre8ing(_initialOwner)
    {
        // Set ownership to original sender of contract call
        _setOwner(_initialOwner);
        // Update salesConfig
        salesConfig = _salesConfig;
        // Setup config variables
        config.editionSize = _editionSize;
        config.metadataRenderer = _metadataRenderer;
        config.royaltyBPS = _royaltyBPS;
        config.fundsRecipient = _fundsRecipient;
    }

    /// @dev Getter for admin role associated with the contract to handle metadata
    /// @return boolean if address is admin
    function isAdmin(address user) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, user);
    }

    /// @notice mint function
    /// @dev This allows the user to purchase an edition
    /// @dev at the given price in the contract.
    function purchase(
        uint256 quantity
    )
        external
        payable
        nonReentrant
        canMintTokens(quantity)
        onlyPublicSaleActive
        returns (uint256)
    {
        uint256 salePrice = salesConfig.publicSalePrice;

        if (msg.value != salePrice * quantity) {
            revert Purchase_WrongPrice(salePrice * quantity);
        }

        // If max purchase per address == 0 there is no limit.
        // Any other number, the per address mint limit is that.
        if (
            salesConfig.maxSalePurchasePerAddress != 0 &&
            _numberMinted(_msgSender()) +
                quantity -
                presaleMintsByAddress[_msgSender()] >
            salesConfig.maxSalePurchasePerAddress
        ) {
            revert Purchase_TooManyForAddress();
        }

        _mintNFTs(_msgSender(), quantity);
        uint256 firstMintedTokenId = _lastMintedTokenId() - quantity;

        emit IERC721Drop.Sale({
            to: _msgSender(),
            quantity: quantity,
            pricePerToken: salePrice,
            firstPurchasedTokenId: firstMintedTokenId
        });
        return firstMintedTokenId;
    }

    /// @notice Merkle-tree based presale purchase function
    /// @param quantity quantity to purchase
    /// @param maxQuantity max quantity that can be purchased via merkle proof #
    /// @param pricePerToken price that each token is purchased at
    /// @param merkleProof proof for presale mint
    function purchasePresale(
        uint256 quantity,
        uint256 maxQuantity,
        uint256 pricePerToken,
        bytes32[] calldata merkleProof
    )
        external
        payable
        nonReentrant
        canMintTokens(quantity)
        onlyPresaleActive
        returns (uint256)
    {
        if (
            !MerkleProof.verify(
                merkleProof,
                salesConfig.presaleMerkleRoot,
                keccak256(
                    // address, uint256, uint256
                    abi.encode(msg.sender, maxQuantity, pricePerToken)
                )
            )
        ) {
            revert Presale_MerkleNotApproved();
        }

        if (msg.value != pricePerToken * quantity) {
            revert Purchase_WrongPrice(pricePerToken * quantity);
        }

        presaleMintsByAddress[_msgSender()] += quantity;
        if (presaleMintsByAddress[_msgSender()] > maxQuantity) {
            revert Presale_TooManyForAddress();
        }

        _mintNFTs(_msgSender(), quantity);
        uint256 firstMintedTokenId = _lastMintedTokenId() - quantity;

        emit IERC721Drop.Sale({
            to: _msgSender(),
            quantity: quantity,
            pricePerToken: pricePerToken,
            firstPurchasedTokenId: firstMintedTokenId
        });

        return firstMintedTokenId;
    }

    /// @notice Mint admin
    /// @param recipient recipient to mint to
    /// @param quantity quantity to mint
    function adminMint(
        address recipient,
        uint256 quantity
    )
        external
        onlyRoleOrAdmin(MINTER_ROLE)
        canMintTokens(quantity)
        returns (uint256)
    {
        _mintNFTs(recipient, quantity);

        return _lastMintedTokenId();
    }

    /// @dev This mints multiple editions to the given list of addresses.
    /// @param recipients list of addresses to send the newly minted editions to
    function adminMintAirdrop(
        address[] calldata recipients
    )
        external
        override
        onlyRoleOrAdmin(MINTER_ROLE)
        canMintTokens(recipients.length)
        returns (uint256)
    {
        uint256 atId = _nextTokenId();
        uint256 startAt = atId;

        unchecked {
            for (
                uint256 endAt = atId + recipients.length;
                atId < endAt;
                atId++
            ) {
                _mintNFTs(recipients[atId - startAt], 1);
            }
        }
        return _lastMintedTokenId();
    }

    /// @dev ERC2981 - Get royalty information for token
    /// @param _salePrice Sale price for the token
    function royaltyInfo(
        uint256,
        uint256 _salePrice
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        if (config.fundsRecipient == address(0)) {
            return (config.fundsRecipient, 0);
        }
        return (
            config.fundsRecipient,
            (_salePrice * config.royaltyBPS) / 10_000
        );
    }

    /// @notice Function to mint NFTs
    /// @dev (important: Does not enforce max supply limit, enforce that limit earlier)
    /// @dev This batches in size of 8 as per recommended by ERC721AC creators
    /// @param to address to mint NFTs to
    /// @param quantity number of NFTs to mint
    function _mintNFTs(address to, uint256 quantity) internal {
        do {
            uint256 toMint = quantity > MAX_MINT_BATCH_SIZE
                ? MAX_MINT_BATCH_SIZE
                : quantity;
            _mint({to: to, quantity: toMint});
            quantity -= toMint;
        } while (quantity > 0);
    }

    /// @param tokenId Token ID to burn
    /// @notice User burn function for token id
    function burn(uint256 tokenId) public {
        _burn(tokenId, true);
    }

    /// @notice Sale details
    /// @return IERC721Drop.SaleDetails sale information details
    function saleDetails()
        external
        view
        returns (IERC721Drop.ERC20SaleDetails memory)
    {
        return
            IERC721Drop.ERC20SaleDetails({
                erc20PaymentToken: salesConfig.erc20PaymentToken,
                publicSaleActive: _publicSaleActive(),
                presaleActive: _presaleActive(),
                publicSalePrice: salesConfig.publicSalePrice,
                publicSaleStart: salesConfig.publicSaleStart,
                publicSaleEnd: salesConfig.publicSaleEnd,
                presaleStart: salesConfig.presaleStart,
                presaleEnd: salesConfig.presaleEnd,
                presaleMerkleRoot: salesConfig.presaleMerkleRoot,
                totalMinted: _totalMinted(),
                maxSupply: config.editionSize,
                maxSalePurchasePerAddress: salesConfig.maxSalePurchasePerAddress
            });
    }

    /// @dev Number of NFTs the user has minted per address
    /// @param minter to get counts for
    function mintedPerAddress(
        address minter
    ) external view override returns (IERC721Drop.AddressMintDetails memory) {
        return
            IERC721Drop.AddressMintDetails({
                presaleMints: presaleMintsByAddress[minter],
                publicMints: _numberMinted(minter) -
                    presaleMintsByAddress[minter],
                totalMints: _numberMinted(minter)
            });
    }

    /////////////////////////////////////////////////
    /// ADMIN
    /////////////////////////////////////////////////

    /// @dev Set new owner for royalties / opensea
    /// @param newOwner new owner to set
    function setOwner(address newOwner) public onlyAdmin {
        _setOwner(newOwner);
    }

    /// @notice Set a different funds recipient
    /// @param newRecipientAddress new funds recipient address
    function setFundsRecipient(
        address payable newRecipientAddress
    ) external onlyRoleOrAdmin(SALES_MANAGER_ROLE) {
        // TODO(iain): funds recipient cannot be 0?
        config.fundsRecipient = newRecipientAddress;
        emit FundsRecipientChanged(newRecipientAddress, _msgSender());
    }

    /// @dev This sets the sales configuration
    // / @param publicSalePrice New public sale price
    function setSaleConfiguration(
        address erc20PaymentToken,
        uint104 publicSalePrice,
        uint32 maxSalePurchasePerAddress,
        uint64 publicSaleStart,
        uint64 publicSaleEnd,
        uint64 presaleStart,
        uint64 presaleEnd,
        bytes32 presaleMerkleRoot
    ) external onlyAdmin onlyRoleOrAdmin(SALES_MANAGER_ROLE) {
        salesConfig.erc20PaymentToken = erc20PaymentToken;
        salesConfig.publicSalePrice = publicSalePrice;
        salesConfig.maxSalePurchasePerAddress = maxSalePurchasePerAddress;
        salesConfig.publicSaleStart = publicSaleStart;
        salesConfig.publicSaleEnd = publicSaleEnd;
        salesConfig.presaleStart = presaleStart;
        salesConfig.presaleEnd = presaleEnd;
        salesConfig.presaleMerkleRoot = presaleMerkleRoot;

        emit SalesConfigChanged(_msgSender());
    }

    /// @notice Set a new metadata renderer
    /// @param newRenderer new renderer address to use
    /// @param setupRenderer data to setup new renderer with
    function setMetadataRenderer(
        IMetadataRenderer newRenderer,
        bytes memory setupRenderer
    ) external onlyAdmin {
        config.metadataRenderer = newRenderer;

        if (setupRenderer.length > 0) {
            newRenderer.initializeWithData(setupRenderer);
        }

        emit UpdatedMetadataRenderer({
            sender: msg.sender,
            renderer: newRenderer
        });
    }

    /// @notice Set a new lockup contract
    /// @param newLockup new lockup address to use
    function setLockup(ILockup newLockup) external onlyAdmin {
        lockup = newLockup;
    }

    /// @notice This withdraws ETH from the contract to the contract owner.
    function withdraw() external nonReentrant {
        address sender = _msgSender();

        // Get fee amount
        uint256 funds = address(this).balance;

        if (
            !hasRole(DEFAULT_ADMIN_ROLE, sender) &&
            !hasRole(SALES_MANAGER_ROLE, sender) &&
            sender != config.fundsRecipient
        ) {
            revert Access_WithdrawNotAllowed();
        }

        // Payout recipient
        (bool successFunds, ) = config.fundsRecipient.call{
            value: funds,
            gas: FUNDS_SEND_GAS_LIMIT
        }("");
        if (!successFunds) {
            revert Withdraw_FundsSendFailure();
        }
    }

    /////////////////////////////////////////////////
    /// CRE8ING
    /////////////////////////////////////////////////

    /// @notice Changes the CRE8ORs' cre8ing statuss (what's the plural of status?
    ///     statii? statuses? status? The plural of sheep is sheep; maybe it's also the
    ///     plural of status).
    /// @dev Changes the CRE8ORs' cre8ing sheep (see @notice).
    function toggleCre8ing(uint256[] calldata tokenIds) external {
        uint256 n = tokenIds.length;
        for (uint256 i = 0; i < n; ++i) {
            toggleCre8ing(tokenIds[i]);
        }
    }

    /// @notice Changes the CRE8OR's cre8ing status.
    function toggleCre8ing(
        uint256 tokenId
    ) internal onlyApprovedOrOwner(tokenId) {
        uint256 start = cre8ingStarted[tokenId];
        if (start == 0) {
            enterWarehouse(tokenId);
        } else {
            leaveWarehouse(tokenId);
        }
    }

    /// @notice Transfer a token between addresses while the CRE8OR is cre8ing,
    ///     thus not resetting the cre8ing period.
    function safeTransferWhileCre8ing(
        address from,
        address to,
        uint256 tokenId
    ) external {
        if (ownerOf(tokenId) != _msgSender()) {
            revert Access_OnlyOwner();
        }
        cre8ingTransfer = 2;
        safeTransferFrom(from, to, tokenId);
        cre8ingTransfer = 1;
    }

    /// @dev Optional validation hook that fires before an exit from cre8ing
    function _beforeCre8ingExit(uint256 tokenId) internal override {
        if (lockup.isLocked(address(this), tokenId)) {
            revert ILockup.Lockup_Locked();
        }
    }

    /////////////////////////////////////////////////
    /// ERC6551 - token bound accounts
    /////////////////////////////////////////////////

    /// @dev Register ERC6551 token bound account onMint.
    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal override {
        if (from == address(0) && erc6551Registry != address(0)) {
            createTokenBoundAccounts(startTokenId, quantity);
        }
        ERC721AC._afterTokenTransfers(from, to, startTokenId, quantity);
    }

    /// @notice Set ERC6551 registry
    /// @param _registry ERC6551 registry
    function setErc6551Registry(address _registry) public onlyAdmin {
        erc6551Registry = _registry;
    }

    /// @notice Set ERC6551 account implementation
    /// @param _implementation ERC6551 account implementation
    function setErc6551Implementation(
        address _implementation
    ) public onlyAdmin {
        erc6551AccountImplementation = _implementation;
    }

    /////////////////////////////////////////////////
    /// ERC721C - cre8or royalties
    /////////////////////////////////////////////////

    /// @notice ERC721C required override
    function _requireCallerIsContractOwner() internal view override {
        if (msg.sender != owner()) {
            revert Access_OnlyAdmin();
        }
    }

    /////////////////////////////////////////////////
    /// UTILITY FUNCTIONS
    /////////////////////////////////////////////////

    /// @notice Getter for last minted token ID (gets next token id and subtracts 1)
    function _lastMintedTokenId() internal view returns (uint256) {
        return _nextTokenId() - 1;
    }

    /// @notice time between start - end
    function _publicSaleActive() internal view returns (bool) {
        return
            salesConfig.publicSaleStart <= block.timestamp &&
            salesConfig.publicSaleEnd > block.timestamp;
    }

    /// @notice time between presaleStart - presaleEnd
    function _presaleActive() internal view returns (bool) {
        return
            salesConfig.presaleStart <= block.timestamp &&
            salesConfig.presaleEnd > block.timestamp;
    }

    /// @dev Block transfers while cre8ing.
    function _beforeTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal override {
        uint256 tokenId = startTokenId;
        for (uint256 end = tokenId + quantity; tokenId < end; ++tokenId) {
            if (cre8ingStarted[tokenId] != 0 && cre8ingTransfer != 2) {
                revert Cre8ing_Cre8ing();
            }
        }
        ERC721AC._beforeTokenTransfers(from, to, startTokenId, quantity);
    }

    /// @notice array of staked tokenIDs
    /// @dev used in cre8ors ui to quickly get list of staked NFTs.
    function cre8ingTokens()
        external
        view
        returns (uint256[] memory stakedTokens)
    {
        uint256 size = _lastMintedTokenId();
        stakedTokens = new uint256[](size);
        for (uint256 i = 1; i < size + 1; ++i) {
            uint256 start = cre8ingStarted[i];
            if (start != 0) {
                stakedTokens[i - 1] = i;
            }
        }
    }

    /////////////////////////////////////////////////
    /// MODIFIERS
    /////////////////////////////////////////////////

    /// @notice Only allow for users with admin access
    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert Access_OnlyAdmin();
        }

        _;
    }

    /// @notice Requires that msg.sender owns or is approved for the token.
    modifier onlyApprovedOrOwner(uint256 tokenId) {
        if (
            _ownershipOf(tokenId).addr != _msgSender() &&
            getApproved(tokenId) != _msgSender()
        ) {
            revert Access_MissingOwnerOrApproved();
        }

        _;
    }

    /// @notice Allows user to mint tokens at a quantity
    modifier canMintTokens(uint256 quantity) {
        if (quantity + _totalMinted() > config.editionSize) {
            revert Mint_SoldOut();
        }

        _;
    }

    /// @notice Public sale active
    modifier onlyPublicSaleActive() {
        if (!_publicSaleActive()) {
            revert Sale_Inactive();
        }

        _;
    }

    /// @notice Presale active
    modifier onlyPresaleActive() {
        if (!_presaleActive()) {
            revert Presale_Inactive();
        }

        _;
    }

    /////////////////////////////////////////////////
    /// OVERRIDES
    /////////////////////////////////////////////////

    /// @notice ERC165 supports interface
    /// @param interfaceId interface id to check if supported
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(IERC165, ERC721AC, AccessControl) returns (bool) {
        return
            super.supportsInterface(interfaceId) ||
            type(IOwnable).interfaceId == interfaceId ||
            type(IERC2981).interfaceId == interfaceId ||
            type(IERC721Drop).interfaceId == interfaceId ||
            type(ERC721AC).interfaceId == interfaceId;
    }

    /// @notice Simple override for owner interface.
    /// @return user owner address
    function owner()
        public
        view
        override(OwnableSkeleton, IERC721Drop)
        returns (address)
    {
        return super.owner();
    }

    /// @notice Start token ID for minting (1-100 vs 0-99)
    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    /// @notice Token URI Getter, proxies to metadataRenderer
    /// @param tokenId id of token to get URI for
    /// @return Token URI
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (!_exists(tokenId)) {
            revert IERC721A.URIQueryForNonexistentToken();
        }

        return config.metadataRenderer.tokenURI(tokenId);
    }
}
