// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

// Match a player with the next player who joins
// Scalable efficient matching algorithm
// Winner of a match is determined by _winner() function
// NFT can be unstaked if nobody joins or a pair is found
contract Pair {

    // player an address is paired with
    mapping(address => address) public pair;

    // next player to pair with
    address public nextPair;

    // should always emit the first joined player as player1
    event PairFound(address indexed player1, address indexed player2);

    // true if player1 wins, false if player2 wins
    // player1 is the player account passed into the resolve() function
    event PairResolved(address indexed player1, address indexed player2, address outcome);

    constructor() {
    }

    /**
     * @dev Match msg.sender with the next account that joins
     */
    function join() external {
        _join();
    }

    /// @dev internal join logic
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

    /**
     * @dev Resolve player match. Anyone can call this function.
     */
    function resolve(address player) external {
        _resolve(player);
    }

    /// Internal match resolution logic
    function _resolve(address player) internal {
        require(pair[player] != address(0), "Sender is not paired.");

        // determine winner and emit event
        address winner = _winner(player, pair[player]);
        emit PairResolved(player, pair[player], winner);

        // delete mappings
        delete pair[pair[player]];
        delete pair[player];
    }

    /// Determine winner between 2 players
    function _winner(address player1, address /*player2*/) internal pure returns (address) {
        // always return player 1 for testing
        return player1;
    }
}