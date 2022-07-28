// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// Match a player with the next player who joins by staking an NFT
// Scalable for matchin with many unresolved matches
// Winner of a match is determined by _winner() function
// NFT can be unstaked if nobody joins or a pair is found
contract NFTPair is Ownable {

    IERC721 public nft;

    // player an address is paired with
    mapping(address => address) public pair;

    // next player to pair with
    address public nextPair;

    // should always emit the first joined player as player1
    event PairFound(address indexed player1, address indexed player2);

    // true if player1 wins, false if player2 wins
    // player1 is the player account passed into the resolve() function
    event PairResolved(address indexed player1, address indexed player2, address outcome);

    constructor(IERC721 _nft) {
        nft = _nft;
        Ownable(msg.sender);
    }

    // join the next index and stake NFT
    function join() external {
        _join();
        // stake NFT
        // should be able to unstake if never resolved
    }

    function _join() internal {
        require(msg.sender != nextPair, "Sender is already waiting for a pair.");
        require(pair[msg.sender] == address(0), "Sender is already paired.");
        if (nextPair == address(0)) {
            nextPair = msg.sender;
        }
        else {
            // pair with next
            pair[msg.sender] = nextPair;
            pair[nextPair] = msg.sender;
            emit PairFound(nextPair, msg.sender);
            nextPair = address(0);
            // can resolve immediatley upon pairing or have block delay
        }
    }

    // resolve an index and allow players to unstake their NFTs
    // can improve this to use a random number and 3rd party call
    function resolve(address player) external {
        _resolve(player);

        // unstake NFTs
        // can transfer both back or mark them for claiming
    }

    function _resolve(address player) internal {
        require(pair[player] != address(0), "Sender is not paired.");

        // determine winner and emit event
        address winner = _winner(player, pair[player]);
        emit PairResolved(player, pair[player], winner);

        // delete mappings
        delete pair[pair[player]];
        delete pair[player];
    }

    // return winner between 2 players
    function _winner(address player1, address /*player2*/) internal pure returns (address) {
        // always return player 1 for testing
        return player1;
    }


}