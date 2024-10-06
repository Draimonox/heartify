// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Heartify is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    ERC721PausableUpgradeable,
    AccessControlUpgradeable,
    ERC721BurnableUpgradeable
{
    address payable public wallet;
    uint256 public mintingFee;
    event MintingFeeUpdated(uint256 newFee);
    address public artist;
    address payable public developer;
    uint256 public artistRoyaltyPercentage;
    uint256 public devRoyaltyPercentage;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address payable _wallet) {
        wallet = _wallet;
        _disableInitializers();
    }

    function initialize(
        address defaultAdmin,
        address payable _artist,
        address payable _developer,
        uint256 _artistRoyaltyPercentage,
        uint256 _devRoyaltyPercentage
        
    ) public initializer {
        __ERC721_init("Heartify", "HEART");
        __ERC721Enumerable_init();
        __ERC721URIStorage_init();
        __ERC721Pausable_init();
        __AccessControl_init();
        __ERC721Burnable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);


        artist = _artist;
        developer = _developer;
        artistRoyaltyPercentage = _artistRoyaltyPercentage;
        devRoyaltyPercentage = _devRoyaltyPercentage;
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function safeMint(address to, uint256 tokenId) public payable {
        require(msg.value >= mintingFee, "Insufficient funds to mint");

        _safeMint(to, tokenId);
        
        // URI will be set from the frontend after fetching from the API
        // _setTokenURI(tokenId, uri);

        
        wallet.transfer(msg.value);
    }

    function updateMintFee(uint256 newFee) public onlyRole(DEFAULT_ADMIN_ROLE) {
        mintingFee = newFee;
        emit MintingFeeUpdated(newFee);
    }

    function batchMint(address to, uint256[] memory tokenIds) public payable {
        require(msg.value >= mintingFee * tokenIds.length, "Insufficient funds to batch mint");
        require(tokenIds.length > 0, "Token IDs array cannot be empty");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _safeMint(to, tokenIds[i]);
            // _setTokenURI(tokenIds[i], uris[i]); // URI will be set from the frontend after fetching from the API
        }

        wallet.transfer(msg.value); 
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
