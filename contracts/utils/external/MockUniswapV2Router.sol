// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IUniswapV2Router02} from "../IUniswapV2Router02.sol";

contract MockFactory {
    function createPair(address _addr, address _addr2) external returns (address) {
        return address(0);
    }
}

contract MockUniswapV2Router {
    MockFactory mockFactory = new MockFactory();

    constructor() {}

    function factory() external view returns (address) {
        return address(mockFactory); // Example factory address
    }

    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // WETH address (mainnet example)
    }

    function addLiquidityETH(
        address _addr,
        uint256 _uintMock1,
        uint256 _uintMock2,
        uint256 _collateralAmount,
        address _addr2,
        uint256 _timeStamp
    ) external payable returns (uint256, uint256, uint256) {
        return (0, 0, 10 * 10 ** 18);
    }
}
