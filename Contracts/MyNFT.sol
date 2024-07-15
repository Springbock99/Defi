// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title MyNFT
 * @dev A simple ERC721 token contract for creating and managing unique NFTs.
 */
contract MyNFT is ERC721, Ownable {
    uint256 private _tokenIdCounter;
    using Strings for uint256;

    /**
     * @dev Constructor that initializes the MyNFT contract.
     */
    constructor() ERC721("MyNFT", "MNFT") Ownable(msg.sender) {}

    /**
     * @dev Mint a new NFT to the specified address.
     * @param to The address to mint the NFT to.
     */
    function mint(address to) external {
        _safeMint(to, _tokenIdCounter);
        _tokenIdCounter++;
    }

    /**
     * @dev Get the token URI for a given tokenId.
     * @param tokenId The ID of the token to get the URI for.
     * @return The token URI.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireOwned(tokenId);
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string.concat(baseURI, tokenId.toString())
                : "";
    }

    /**
     * @dev Internal function to specify the base URI for token metadata.
     * @return The base URI for token metadata.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmYPdi5nLPCrEugAZoxaqhK1RyEyoz3w4pb6tLuKqf5Sd7/";
    }

    /**
     * @dev Internal function to ensure that the tokenId is owned by the contract.
     * @param tokenId The ID of the token to check ownership for.
     */
    function _requireOwned(uint256 tokenId) internal view override {
        require(ownerOf(tokenId) == address(this), "Token not owned by contract");
    }
}
