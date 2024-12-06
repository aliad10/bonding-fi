// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IUniswapV2Router02} from "../IUniswapV2Router02.sol";

contract MockUniswapV2Router {
    constructor() {}

    function factory() external pure returns (address) {
        return address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f); // Example factory address
    }

    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH address (mainnet example)
    }
}
