// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


// Basic NFT with ownership
// First ID is 0
contract BasicNFT is ERC721, Ownable {

    // Track IDs
    uint256 internal nextId;

    constructor() ERC721("BasicNFT", "NFT") {
        Ownable(msg.sender);
    }

    /// Mint NFT for account and increment ID
    function mint(address account) external onlyOwner {
        _safeMint(account, nextId);
        nextId++;
    }

    // Check if tokenId exists
    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }
}