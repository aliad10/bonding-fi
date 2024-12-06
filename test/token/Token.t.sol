// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ImagineToken} from "../../src/token/ImagineToken.sol"; // Replace with the correct path
import {IImagineToken} from "../../src/token/IImagineToken.sol"; // Import interface if needed
import {MockUniswapV2Router} from "../../src/utils/external/MockUniswapV2Router.sol"; // Import the Mock Uniswap Router

contract ImagineTokenTest is Test {
    ImagineToken public token;
    MockUniswapV2Router public mockUniswapV2Router;

    string private constant INITIAL_URI = "https://initial-uri.com";
    string private constant UPDATED_URI = "https://updated-uri.com";

    address private treasury = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    address private dexTreasury = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    address private factory = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    address private WETH = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a; // WETH mainnet address (example)
    uint private totalSupply = 1000000 * 10 ** 18;

    string private tokenName = "ImagineToken";
    string private tokenSymbol = "IMT";
    uint256 private initialTokenSupply = 1000000 * 10 ** 18;
    uint256 private initialCollateralReserves = 1000 ether;
    uint256 private initialVirtualTokenReserves = 1000000 * 10 ** 18;
    uint256 private feeBasisPoints = 200; // 2% fee
    uint256 private dexFeeBasisPoints = 50; // 0.5% dex fee
    address private creator = address(this);
    address private treasuryAddress =
        0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    address private dexTreasuryAddress =
        0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    uint256 private migrationFeeFixed = 10;
    uint256 private poolCreationFee = 10;
    uint256 private mcLowerLimit = 100;
    uint256 private mcUpperLimit = 500;
    uint256 private tokensMigrationThreshold = 1000000;
    function setUp() public {
        // Deploy Mock Uniswap Router contract with the factory and WETH address
        mockUniswapV2Router = new MockUniswapV2Router();

        // // Setup the token contract, passing the address of the mock router
        IImagineToken.ConstructorParams memory params = IImagineToken
            .ConstructorParams({
                name: tokenName,
                symbol: tokenSymbol,
                tokenURI: INITIAL_URI,
                creator: creator,
                totalSupply: initialTokenSupply,
                virtualCollateralReserves: initialCollateralReserves,
                virtualTokenReserves: initialVirtualTokenReserves,
                feeBasisPoints: feeBasisPoints,
                dexFeeBasisPoints: dexFeeBasisPoints,
                migrationFeeFixed: migrationFeeFixed,
                poolCreationFee: poolCreationFee,
                mcLowerLimit: mcLowerLimit,
                mcUpperLimit: mcUpperLimit,
                tokensMigrationThreshold: tokensMigrationThreshold,
                treasury: treasuryAddress,
                dexTreasury: dexTreasuryAddress,
                uniV2Router: address(mockUniswapV2Router)
            });

        token = new ImagineToken(params);
    }

    function test_checkConstructorData() public {
        assertEq(token.name(), tokenName);
        assertEq(token.symbol(), tokenSymbol);
        assertEq(token.getTokenURI(), INITIAL_URI);
        assertEq(token.creator(), creator);
        assertEq(token.totalSupply(), initialTokenSupply);
        assertEq(token.virtualCollateralReserves(), initialCollateralReserves);
        assertEq(token.virtualTokenReserves(), initialVirtualTokenReserves);
        assertEq(token.feeBPS(), feeBasisPoints);
        assertEq(token.dexFeeBPS(), dexFeeBasisPoints);
        assertEq(token.fixedMigrationFee(), migrationFeeFixed);
        assertEq(token.poolCreationFee(), poolCreationFee);
        assertEq(token.mcLowerLimit(), mcLowerLimit);
        assertEq(token.mcUpperLimit(), mcUpperLimit);
        assertEq(token.tokensMigrationThreshold(), tokensMigrationThreshold);
        assertEq(token.treasury(), treasuryAddress);
        assertEq(token.dexTreasury(), dexTreasuryAddress);

        console.log(address(mockUniswapV2Router));
        // console.log()
        // assertEq(token.uniswapV2Router(), address(mockUniswapV2Router)); // Check mock Uniswap router
    }

    function test_SetTokenURI() public {
        token.setTokenURI(UPDATED_URI);
        assertEq(token.getTokenURI(), UPDATED_URI);
    }
}
