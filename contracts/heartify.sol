// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Heartify is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Pausable,
    Ownable,
    ERC721Burnable
{
    uint256 public mintingFee;
    uint256 public artistRoyaltyPercentage;
    uint256 public devRoyaltyPercentage;
    uint256 private currentTokenId;
    address payable public dev =
        payable(0x4f2503fC63066E69C2f72537927Bf24eaebc55AA);

    event MintingFeeUpdated(uint256 newFee);
    event BatchMinted(address indexed to, uint256[] tokenIds);
    event NFTSold(address seller, uint256 tokenId, uint256 price);
    event NFTListed(address seller, uint256 tokenId, uint256 price);
    event NFTBought(address buyer, uint256 tokenId, uint256 price);

    mapping(uint256 => uint256) private _tokenPrices;
    mapping(uint256 => bool) private _listedTokens;
    mapping(uint256 => address) private _tokenArtists;

    constructor(
        address initialOwner
    ) ERC721("Heartify", "ART") Ownable(initialOwner) {
        mintingFee = 15 * 10 ** 18; // 15 MATIC
        artistRoyaltyPercentage = 300; // 3%
        devRoyaltyPercentage = 300; // 3%
        currentTokenId = 0;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function getArtist(uint256 tokenId) public view returns (address) {
        return _tokenArtists[tokenId];
    }

    function safeMint(
        address to,
        address artist // string memory uri
    ) public payable {
        require(msg.value >= mintingFee, "Insufficient funds to mint");
        require(msg.value >= mintingFee, "Insufficient funds to mint");
        require(to != address(0), "Cannot mint to zero address");
        currentTokenId += 1;
        uint256 tokenId = currentTokenId;
        // _setTokenURI(tokenId, uri); will set uri from front end
        _safeMint(to, tokenId);
        _tokenArtists[tokenId] = artist;
        dev.transfer(msg.value);
    }

    function updateMintFee(uint256 newFee) public onlyOwner {
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
            currentTokenId += 1;
            uint256 newTokenId = currentTokenId;
            _safeMint(to, newTokenId);
            // _setTokenURI(newTokenId, uri) has to be done front end
            tokenIds[i] = newTokenId;
        }

        emit BatchMinted(to, tokenIds); // Emit event after minting
        dev.transfer(msg.value); // Transfer funds
    }

    function listNFT(uint256 tokenId, uint256 price) public {
        require(price > 0, "Price must be greater than zero");

        _tokenPrices[tokenId] = price;
        _listedTokens[tokenId] = true;

        emit NFTListed(_msgSender(), tokenId, price);
    }

    function buyNFT(uint256 tokenId, address payable artist) public payable {
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
        dev.transfer(devRoyalty);

        // Transfer the remaining funds to the seller
        payable(seller).transfer(sellerAmount);

        // Clear listing
        _listedTokens[tokenId] = false;
        _tokenPrices[tokenId] = 0;

        emit NFTBought(msg.sender, tokenId, price);
    }

    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        dev.transfer(balance);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(
        address account,
        uint128 value
    ) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
