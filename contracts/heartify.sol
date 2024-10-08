// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

contract Heartify is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    ERC721Pausable,
    ERC721Burnable,
    ReentrancyGuard,
    Ownable
{
    uint256 public mintingFee;
    uint256 public artistRoyaltyPercentage;
    uint256 public devRoyaltyPercentage;
    uint256 private currentTokenId;
    address payable public dev =
        payable(0x4f2503fC63066E69C2f72537927Bf24eaebc55AA);

    event MintingFeeUpdated(uint256 newFee);
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
        address to // string memory uri
    ) public payable {
        require(msg.value >= mintingFee, "Insufficient funds to mint");
        require(to != address(0), "Cannot mint to zero address");
        currentTokenId += 1;
        uint256 tokenId = currentTokenId;
        // _setTokenURI(tokenId, uri); will set uri from front end
        _safeMint(to, tokenId);
        // can just use msg.sender
        _tokenArtists[tokenId] = msg.sender; // Use the minter's address as the artist.
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
        for (uint256 i = 0; i < numberOfTokens; i++) {
            currentTokenId += 1;
            uint256 newTokenId = currentTokenId;
            // should just use msg.sender instead of to
            _safeMint(to, newTokenId);
            // _setTokenURI(newTokenId, uri) has to be done front end
            _tokenArtists[newTokenId] = msg.sender;
        }
        dev.transfer(msg.value); // Transfer funds
    }

    function listNFT(uint256 tokenId, uint256 price) public {
        require(price > 0, "Price must be greater than zero");
        require(ownerOf(tokenId) == msg.sender, "You do not own this token");
        require(!_listedTokens[tokenId], "Token is already listed for sale");
        _tokenPrices[tokenId] = price;
        _listedTokens[tokenId] = true;

        emit NFTListed(_msgSender(), tokenId, price);
    }

    function buyNFT(uint256 tokenId) public payable nonReentrant {
        require(_listedTokens[tokenId], "Token is not listed for sale");
        uint256 price = _tokenPrices[tokenId];
        require(msg.value >= price, "Insufficient funds to buy");

        address seller = ownerOf(tokenId);
        address artist = _tokenArtists[tokenId]; // Get the artist associated with the token

        require(msg.sender != seller, "You cannot buy your own NFT");

        // Calculate royalties and seller's amount
        uint256 artistRoyalty = (price * artistRoyaltyPercentage) / 10000;
        uint256 devRoyalty = (price * devRoyaltyPercentage) / 10000;
        uint256 sellerAmount = price - (artistRoyalty + devRoyalty);

        // Refund excess ETH
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }

        // Transfer the NFT to the buyer
        _transfer(seller, msg.sender, tokenId);

        // Transfer royalties
        payable(artist).transfer(artistRoyalty);
        payable(dev).transfer(devRoyalty);

        // Transfer the remaining funds to the seller
        payable(seller).transfer(sellerAmount);

        // Clear listing
        _listedTokens[tokenId] = false;
        _tokenPrices[tokenId] = 0;

        emit NFTBought(msg.sender, tokenId, price);
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

// REVIEW: someone can pass their own address as the artist and get paid the artist royalties to themselves (should use _tokenArtists)
// also add re-entrancy guard
// also make sure msg.sender and seller aren't the same
// should refund the amount of ETH a user spends over the price (e.g. if it's price is 0.1 and someone sends 0.2, they should be refunded the 0.1 IMO)
// also (unless _transfer() handles this which i think it might, but youll haev to read contract) set the new owner of the token
