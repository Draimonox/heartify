// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Heartify is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721PausableUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable,
    ReentrancyGuard
{
    address payable public wallet;
    uint256 public mintingFee;
    uint256 public artistRoyaltyPercentage;
    uint256 public devRoyaltyPercentage;
    address payable public artist;
    address payable public developer;
    uint256 private currentTokenId;

    event MintingFeeUpdated(uint256 newFee);
    event BatchMinted(address indexed to, uint256[] tokenIds);
    event NFTSold(address seller, uint256 tokenId, uint256 price);
    event NFTListed(address seller, uint256 tokenId, uint256 price);
    event NFTBought(address buyer, uint256 tokenId, uint256 price);

    mapping(uint256 => uint256) private _tokenPrices;
    mapping(uint256 => bool) private _listedTokens;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(
        address payable _wallet,
        address payable _artist,
        address payable _developer
    ) {
        wallet = _wallet;
        artist = _artist;
        developer = _developer;
        mintingFee = 15 * 10 ** 18; // 15 MATIC
        artistRoyaltyPercentage = 300; // 3%
        devRoyaltyPercentage = 300; // 3%
        currentTokenId = 0;
        _disableInitializers();
    }

    function initialize(address defaultAdmin) public initializer {
        __ERC721_init("Heartify", "HEART");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function safeMint(
        address to,
        uint256 tokenId,
        string memory uri
    ) public payable {
        require(msg.value >= mintingFee, "Insufficient funds to mint");
        require(!_exists(tokenId), "Token ID already exists");

        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        wallet.transfer(msg.value);
    }

    function updateMintFee(uint256 newFee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        mintingFee = newFee;
        emit MintingFeeUpdated(newFee);
    }

    function getTokenPrice(uint256 tokenId) public view returns (uint256) {
        return _tokenPrices[tokenId];
    }

    function batchMint(
        address to,
        uint256 numberOfTokens,
        string memory uri
    ) public payable {
        require(
            msg.value >= mintingFee * numberOfTokens,
            "Insufficient funds to batch mint"
        );
        require(numberOfTokens > 0, "Must mint at least one token");

        uint256[] memory tokenIds = new uint256[](numberOfTokens);

        for (uint256 i = 0; i < numberOfTokens; i++) {
            currentTokenId++;
            uint256 newTokenId = currentTokenId;
            _safeMint(to, newTokenId);
            _setTokenURI(newTokenId, uri);
            tokenIds[i] = newTokenId;
        }

        emit BatchMinted(to, tokenIds); // Emit event after minting
        wallet.transfer(msg.value); // Transfer funds
    }

    function listNFT(uint256 tokenId, uint256 price) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "Caller is not owner nor approved"
        );
        require(price > 0, "Price must be greater than zero");

        _tokenPrices[tokenId] = price;
        _listedTokens[tokenId] = true;

        emit NFTListed(_msgSender(), tokenId, price);
    }

    function buyNFT(uint256 tokenId) public payable nonReentrant {
        require(_listedTokens[tokenId], "Token is not listed for sale");
        uint256 price = _tokenPrices[tokenId];
        require(msg.value >= price, "Insufficient funds to buy");

        address seller = ownerOf(tokenId);

        uint256 artistRoyalty = (price * artistRoyaltyPercentage) / 10000;
        uint256 devRoyalty = (price * devRoyaltyPercentage) / 10000;
        uint256 sellerAmount = price - (artistRoyalty + devRoyalty);

        // Transfer the NFT to the buyer
        _transfer(seller, msg.sender, tokenId);

        // Transfer royalties
        artist.transfer(artistRoyalty);
        developer.transfer(devRoyalty);

        // Transfer the remaining funds to the seller
        payable(seller).transfer(sellerAmount);

        // Clear listing
        _listedTokens[tokenId] = false;
        _tokenPrices[tokenId] = 0;

        emit NFTBought(msg.sender, tokenId, price);
    }

    function withdrawFunds() public onlyRole(DEFAULT_ADMIN_ROLE) {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        wallet.transfer(balance);
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            ERC721PausableUpgradeable
        )
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
