// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// Basic NFT staking contract
// Each account can only stake one NFT at a time
contract NFTSingleStaking is IERC721Receiver {

    // NFT used for staking
    IERC721 public nft;

    // Lookup staked tokenId based on account
    mapping(address => uint256) public stakers;

    // Lookup account based on tokenId
    mapping(uint256 => address) public stakedTokens;

    // Amount staked for each account
    mapping(address => bool) public isStaked;

    // Total amount staked
    uint256 totalStaked;

    constructor(IERC721 _nft) {
        nft = _nft;
    }

    /// Emitted when an account stakes
    event Staked(address indexed account, uint256 tokenId);

    /// Emitted when an account unstakes
    event Unstaked(address indexed account, uint256 tokenId);

    /// Stake NFT with `tokenId` and tranfer to this contract
    /// Sender must approve transfer before calling this function
    function stake(uint256 tokenId) external  {
        _stake(tokenId);
    }

    /// Internal staking logic
    function _stake(uint256 tokenId) internal {
        require(!isStaked[msg.sender], "Sender is already staked.");
        require(nft.ownerOf(tokenId) == msg.sender, "Sender is not owner of token.");

        // store user data
        stakers[msg.sender] = tokenId;
        stakedTokens[tokenId] = msg.sender;
        isStaked[msg.sender] = true;

        // transfer token and emit event
        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        emit Staked(msg.sender, tokenId);
    }

    /// Unstake NFT and transfer back to sender
    function unstake() external {
        _unstake();
    }

    /// Unstake logic
    function _unstake() internal {
        require(isStaked[msg.sender], "Sender is not staked");

        // get token ID
        uint256 tokenId = stakers[msg.sender];

        // delete staking data
        delete stakers[msg.sender];
        delete stakedTokens[tokenId];
        isStaked[msg.sender] = false;

        // transfer and emit event
        nft.safeTransferFrom(address(this), msg.sender, tokenId);
        emit Unstaked(msg.sender, tokenId);
    }

    /// Can only recieve NFTs from the nft contract
    /// https://docs.openzeppelin.com/contracts/2.x/api/token/erc721#IERC721Receiver
    function onERC721Received(address, address, uint256, bytes calldata) 
    public override view returns (bytes4) {
        require(address(nft) == msg.sender);
        return IERC721Receiver.onERC721Received.selector;
    }
}