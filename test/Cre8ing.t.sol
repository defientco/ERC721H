// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {Cre8ing} from "../src/Cre8ing.sol";
import {Cre8ors} from "../src/Cre8ors.sol";
import {DummyMetadataRenderer} from "./utils/DummyMetadataRenderer.sol";
import {IERC721Drop} from "../src/interfaces/IERC721Drop.sol";

contract CounterTest is Test {
    Cre8ing public cre8ingBase;
    Cre8ors public cre8orsNFTBase;
    DummyMetadataRenderer public dummyRenderer = new DummyMetadataRenderer();

    address public constant DEFAULT_OWNER_ADDRESS = address(0x23499);
    address public constant DEFAULT_CRE8OR_ADDRESS = address(456);

    function setUp() public {
        cre8ingBase = new Cre8ing(DEFAULT_OWNER_ADDRESS);
    }

    modifier setupCre8orsNFTBase() {
        cre8orsNFTBase = new Cre8ors({
            _contractName: "CRE8ORS",
            _contractSymbol: "CRE8",
            _initialOwner: DEFAULT_OWNER_ADDRESS,
            _fundsRecipient: payable(DEFAULT_OWNER_ADDRESS),
            _editionSize: 10_000,
            _royaltyBPS: 808,
            _metadataRenderer: dummyRenderer,
            _metadataURIBase: "",
            _metadataContractURI: "",
            _salesConfig: IERC721Drop.SalesConfiguration({
                publicSaleStart: 0,
                publicSaleEnd: uint64(block.timestamp + 1000),
                presaleStart: 0,
                presaleEnd: 0,
                publicSalePrice: 0,
                maxSalePurchasePerAddress: 0,
                presaleMerkleRoot: bytes32(0)
            })
        });

        _;
    }

    function test_cre8ingPeriod(uint256 _tokenId) public {
        (bool cre8ing, uint256 current, uint256 total) = cre8ingBase
            .cre8ingPeriod(_tokenId);
        assertEq(cre8ing, false);
        assertEq(current, 0);
        assertEq(total, 0);
    }

    function test_cre8ingOpen() public {
        assertEq(cre8ingBase.cre8ingOpen(), false);
    }

    function test_setCre8ingOpenRevertsNonSALES_MANAGER_ROLE(bool _isOpen)
        public
    {
        assertEq(cre8ingBase.cre8ingOpen(), false);
        vm.expectRevert();
        cre8ingBase.setCre8ingOpen(_isOpen);
        assertEq(cre8ingBase.cre8ingOpen(), false);
    }

    function test_setCre8ingOpen(bool _isOpen) public {
        assertEq(cre8ingBase.cre8ingOpen(), false);
        vm.prank(DEFAULT_OWNER_ADDRESS);
        cre8ingBase.setCre8ingOpen(_isOpen);
        assertEq(cre8ingBase.cre8ingOpen(), _isOpen);
    }

    function test_toggleCre8ingRevertOwnerQueryForNonexistentToken(
        uint256 _tokenId
    ) public setupCre8orsNFTBase {
        (bool cre8ing, uint256 current, uint256 total) = cre8orsNFTBase
            .cre8ingPeriod(_tokenId);
        assertEq(cre8ing, false);
        assertEq(current, 0);
        assertEq(total, 0);
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = _tokenId;
        vm.expectRevert();
        cre8orsNFTBase.toggleCre8ing(tokenIds);
    }

    function test_toggleCre8ingRevertCre8ing_Cre8ingClosed()
        public
        setupCre8orsNFTBase
    {
        uint256 _tokenId = 1;
        (bool cre8ing, uint256 current, uint256 total) = cre8orsNFTBase
            .cre8ingPeriod(_tokenId);
        assertEq(cre8ing, false);
        assertEq(current, 0);
        assertEq(total, 0);
        cre8orsNFTBase.purchase(1);
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = _tokenId;
        vm.expectRevert();
        cre8orsNFTBase.toggleCre8ing(tokenIds);
    }

    function test_toggleCre8ing() public setupCre8orsNFTBase {
        uint256 _tokenId = 1;
        (bool cre8ing, uint256 current, uint256 total) = cre8orsNFTBase
            .cre8ingPeriod(_tokenId);
        assertEq(cre8ing, false);
        assertEq(current, 0);
        assertEq(total, 0);
        cre8orsNFTBase.purchase(1);

        vm.prank(DEFAULT_OWNER_ADDRESS);
        cre8orsNFTBase.setCre8ingOpen(true);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = _tokenId;
        cre8orsNFTBase.toggleCre8ing(tokenIds);
        (cre8ing, current, total) = cre8orsNFTBase.cre8ingPeriod(_tokenId);
        assertEq(cre8ing, true);
        assertEq(current, 0);
        assertEq(total, 0);
    }

    function test_blockCre8ingTransfer() public setupCre8orsNFTBase {
        uint256 _tokenId = 1;
        vm.prank(DEFAULT_CRE8OR_ADDRESS);
        cre8orsNFTBase.purchase(1);

        vm.prank(DEFAULT_OWNER_ADDRESS);
        cre8orsNFTBase.setCre8ingOpen(true);

        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = _tokenId;
        vm.startPrank(DEFAULT_CRE8OR_ADDRESS);
        cre8orsNFTBase.toggleCre8ing(tokenIds);
        vm.expectRevert();
        cre8orsNFTBase.safeTransferFrom(
            DEFAULT_CRE8OR_ADDRESS,
            DEFAULT_OWNER_ADDRESS,
            _tokenId
        );
    }
}
