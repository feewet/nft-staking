// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import {Pair, NFTSingleStaking} from "./";

// TODO: make contracts abstract
// TODO: add mocks
contract NFTPair is NFTSingleStaking, Pair {

    constructor() {
    }
}