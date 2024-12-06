// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ImagineToken} from "../src/token/ImagineToken.sol"; // Replace with the correct path
import {IImagineToken} from "../src/token/IImagineToken.sol"; // Import interface if needed
import {MockUniswapV2Router} from "../src/utils/external/MockUniswapV2Router.sol"; // Import the Mock Uniswap Router

contract ImagineTokenTest is Test {
    ImagineToken public token;
    MockUniswapV2Router public mockUniswapV2Router;

    string private constant INITIAL_URI = "https://initial-uri.com";
    string private constant UPDATED_URI = "https://updated-uri.com";

    address private treasury = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    address private dexTreasury = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    address private factory = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    address private WETH = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a; // WETH mainnet address (example)

    function setUp() public {
        // Deploy Mock Uniswap Router contract with the factory and WETH address
        mockUniswapV2Router = new MockUniswapV2Router();

        // // Setup the token contract, passing the address of the mock router
        IImagineToken.ConstructorParams memory params = IImagineToken
            .ConstructorParams({
                name: "ImagineToken",
                symbol: "IMT",
                tokenURI: INITIAL_URI,
                creator: address(this),
                totalSupply: 1000000 * 10 ** 18,
                virtualTokenReserves: 0,
                virtualCollateralReserves: 0,
                feeBasisPoints: 100,
                dexFeeBasisPoints: 100,
                migrationFeeFixed: 10,
                poolCreationFee: 50,
                mcLowerLimit: 1,
                mcUpperLimit: 100,
                tokensMigrationThreshold: 1000,
                treasury: treasury,
                uniV2Router: address(mockUniswapV2Router), // Pass address of the mock router
                dexTreasury: dexTreasury
            });

        token = new ImagineToken(params);
    }

    function test_SetTokenURI() public {
        token.setTokenURI(UPDATED_URI);
        assertEq(token.getTokenURI(), UPDATED_URI);
    }
}
