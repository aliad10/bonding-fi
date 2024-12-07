// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ImagineToken} from "../../src/token/ImagineToken.sol"; // Replace with the correct path
import {IImagineToken} from "../../src/token/IImagineToken.sol"; // Import interface if needed
import {MockUniswapV2Router} from "../../src/utils/external/MockUniswapV2Router.sol"; // Import the Mock Uniswap Router

contract ImagineTokenTest is Test {
    ImagineToken public token;
    MockUniswapV2Router public mockUniswapV2Router;

    // Import the ConstructorParams struct directly from IImagineToken interface
    // You don't need to redefine it in the test anymore

    string private constant TOKEN_NAME = "ImagineToken";
    string private constant TOKEN_SYMBOL = "IMT";
    string private constant TOKEN_URI = "https://initial-token-uri.com";
    uint256 private constant INITIAL_SUPPLY = 1000000000 * 10 ** 18;
    uint private constant VIRTUAL_TOKEN_RESERVES = 1060000000 * 10 ** 18;
    uint private constant VIRTUAL_COLLATERAL_RESERVES = 16 * 10 ** 17;
    address private constant TREASURY =
        0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;

    address private constant DEXTREASURY =
        0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    uint256 private constant FEE_BASIS_POINTS = 100; // Example fee
    uint256 private constant DEX_FEE_BASIS_POINTS = 6000;
    uint256 private constant MIGRATION_FEE = 1 * 10 ** 17;
    uint256 private constant POOL_CREATION_FEE = 5 * 10 ** 16;
    uint256 private constant MC_LOWER_LIMIT = 25 ether;
    uint256 private constant MC_UPPER_LIMIT = 27 ether;
    uint256 private constant TOKENS_MIGRATION_THRESHOLD =
        799538870462404697804703491;

    string private constant INITIAL_URI = "https://initial-uri.com";
    string private constant UPDATED_URI = "https://updated-uri.com";

    address private factory = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    address private WETH = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a; // WETH mainnet address (example)

    function setUp() public {
        // Deploy Mock Uniswap Router contract with the factory and WETH address
        mockUniswapV2Router = new MockUniswapV2Router();

        // // Setup the token contract, passing the address of the mock router
        IImagineToken.ConstructorParams memory params = IImagineToken
            .ConstructorParams({
                name: TOKEN_NAME,
                symbol: TOKEN_SYMBOL,
                tokenURI: TOKEN_URI,
                creator: address(this),
                totalSupply: INITIAL_SUPPLY,
                virtualTokenReserves: VIRTUAL_TOKEN_RESERVES,
                virtualCollateralReserves: VIRTUAL_COLLATERAL_RESERVES,
                feeBasisPoints: FEE_BASIS_POINTS,
                dexFeeBasisPoints: DEX_FEE_BASIS_POINTS,
                migrationFeeFixed: MIGRATION_FEE,
                poolCreationFee: POOL_CREATION_FEE,
                mcLowerLimit: MC_LOWER_LIMIT,
                mcUpperLimit: MC_UPPER_LIMIT,
                tokensMigrationThreshold: TOKENS_MIGRATION_THRESHOLD,
                treasury: TREASURY,
                uniV2Router: address(mockUniswapV2Router),
                dexTreasury: DEXTREASURY
            });

        token = new ImagineToken(params);
    }

    function test_deployment() public view {
        assertEq(token.name(), TOKEN_NAME, "Token name mismatch");
        assertEq(token.symbol(), TOKEN_SYMBOL, "Token symbol mismatch");
        assertEq(token.getTokenURI(), TOKEN_URI, "Token URI mismatch");
        assertEq(token.creator(), address(this), "Creator address mismatch");
        assertEq(
            token.initalTokenSupply(),
            INITIAL_SUPPLY,
            "Initial token supply mismatch"
        );

        assertEq(
            token.virtualTokenReserves(),
            VIRTUAL_TOKEN_RESERVES,
            "Virtual token reserves mismatch"
        );
        assertEq(
            token.virtualCollateralReserves(),
            VIRTUAL_COLLATERAL_RESERVES,
            "Virtual collateral reserves mismatch"
        );

        assertEq(token.feeBPS(), FEE_BASIS_POINTS, "Fee basis points mismatch");
        assertEq(
            token.dexFeeBPS(),
            DEX_FEE_BASIS_POINTS,
            "DEX fee basis points mismatch"
        );
        assertEq(
            token.fixedMigrationFee(),
            MIGRATION_FEE,
            "Fixed migration fee mismatch"
        );
        assertEq(
            token.poolCreationFee(),
            POOL_CREATION_FEE,
            "Pool creation fee mismatch"
        );

        assertEq(
            token.mcLowerLimit(),
            MC_LOWER_LIMIT,
            "Market cap lower limit mismatch"
        );
        assertEq(
            token.mcUpperLimit(),
            MC_UPPER_LIMIT,
            "Market cap upper limit mismatch"
        );

        assertEq(
            token.tokensMigrationThreshold(),
            TOKENS_MIGRATION_THRESHOLD,
            "Tokens migration threshold mismatch"
        );
        assertEq(token.treasury(), TREASURY, "Treasury address mismatch");
        assertEq(
            address(token.uniswapV2Router()),
            address(mockUniswapV2Router),
            "Uniswap V2 Router address mismatch"
        );
        assertEq(
            token.dexTreasury(),
            DEXTREASURY,
            "DEX treasury address mismatch"
        );

        assertEq(token.totalSupply(), INITIAL_SUPPLY, "total supply mismatch");
        assertEq(
            token.balanceOf(address(token)),
            INITIAL_SUPPLY,
            "contract balance mismatch"
        );
        assertEq(token.factory(), address(this), "factory address mismatch");
    }
    function test_setTokenURI() public {
        string memory newTokenURI = "https://updated-uri.com";
        address factoryAddress = address(this);
        address nonFactory = address(
            0xAf37C2Fd7F625A490a6352B852ECc1E09fDC8388
        );

        // Check initial token URI
        assertEq(token.getTokenURI(), TOKEN_URI, "Initial token URI mismatch");

        vm.startPrank(nonFactory);

        vm.expectRevert(IImagineToken.OnlyFactory.selector);
        // // Try setting the URI as a non-factory address (should fail)
        token.setTokenURI(newTokenURI);

        // Ensure we are calling from the factory address
        vm.startPrank(factoryAddress); // Starts the impersonation as the factory

        // // Try setting the URI as the factory (should succeed)

        token.setTokenURI(newTokenURI);

        // // Verify the token URI was updated
        assertEq(token.getTokenURI(), newTokenURI, "Token URI update failed");
    }

    function test_fail_buyExactOut() public {
        address factoryAddress = address(this);
        address nonFactory = address(
            0xAf37C2Fd7F625A490a6352B852ECc1E09fDC8388
        );
        uint tokenAmount = 60000000 * 10 ** 18;
        uint maxCollateralAmount = 9697 * 10 ** 13;

        uint invalidMaxCollateralAmount = 96 * 10 ** 15;

        uint moreThanContractBalanceAmount = INITIAL_SUPPLY * 2;

        vm.startPrank(nonFactory);

        vm.expectRevert(IImagineToken.OnlyFactory.selector);
        // Try call buyExactOut as a non-factory address (should fail)
        token.buyExactOut(tokenAmount, maxCollateralAmount);

        vm.startPrank(factoryAddress);

        vm.expectRevert(IImagineToken.InsufficientTokenReserves.selector);
        // Try call buyExactOut with buyAmount more than balance (should fail)
        token.buyExactOut(moreThanContractBalanceAmount, maxCollateralAmount);

        vm.expectRevert(IImagineToken.SlippageCheckFailed.selector);
        // Try call buyExactOut with less collateral amount (should fail)
        token.buyExactOut(tokenAmount, invalidMaxCollateralAmount);
    }
}
