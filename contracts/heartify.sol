// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
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
    ReentrancyGuard,
    ERC721URIStorageUpgradeable,
    ERC721PausableUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable
{
    bytes32 public constant PAUSER_ROLE = DEFAULT_ADMIN_ROLE;

    address payable public developer =
        payable(0x4f2503fC63066E69C2f72537927Bf24eaebc55AA);
    address payable public wallet = developer;
    uint256 public mintingFee;
    uint256 public artistRoyaltyPercentage;
    uint256 public devRoyaltyPercentage;
    uint256 private currentTokenId;

    event MintingFeeUpdated(uint256 newFee);
    event BatchMinted(address indexed to, uint256[] tokenIds);
    event NFTSold(address seller, uint256 tokenId, uint256 price);
    event NFTListed(address seller, uint256 tokenId, uint256 price);
    event NFTBought(address buyer, uint256 tokenId, uint256 price);

    mapping(uint256 => uint256) private _tokenPrices;
    mapping(uint256 => bool) private _listedTokens;
    mapping(uint256 => address) private _tokenArtists;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
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
        _grantRole(PAUSER_ROLE, defaultAdmin);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function getArtist(uint256 tokenId) public view returns (address) {
        return _tokenArtists[tokenId];
    }

    function safeMint(
        address to,
        uint256 tokenId,
        address artist
    ) public payable // string memory uri
    {
        require(msg.value >= mintingFee, "Insufficient funds to mint");
        _safeMint(to, tokenId);
        // _setTokenURI(tokenId, uri); will set uri from front end
        _tokenArtists[tokenId] = artist;
        wallet.transfer(msg.value);
    }

    function updateMintFee(uint256 newFee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        mintingFee = newFee;
        emit MintingFeeUpdated(newFee);
    }

    function getTokenPrice(uint256 tokenId) public view returns (uint256) {
        return _tokenPrices[tokenId];
    }

    function batchMint(address to, uint256 numberOfTokens) public payable {
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
            // _setTokenURI(newTokenId, uri) has to be done front end
            tokenIds[i] = newTokenId;
        }

        emit BatchMinted(to, tokenIds); // Emit event after minting
        wallet.transfer(msg.value); // Transfer funds
    }

    function listNFT(uint256 tokenId, uint256 price) public {
        require(price > 0, "Price must be greater than zero");

        _tokenPrices[tokenId] = price;
        _listedTokens[tokenId] = true;

        emit NFTListed(_msgSender(), tokenId, price);
    }

    function buyNFT(
        uint256 tokenId,
        address payable artist
    ) public payable nonReentrant {
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

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(
            ERC721Upgradeable,
            ERC721EnumerableUpgradeable,
            ERC721PausableUpgradeable
        )
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._increaseBalance(account, value);
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
            ERC721URIStorageUpgradeable,
            AccessControlUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
