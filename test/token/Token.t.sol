// Test file
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../../src/token/ImagineToken.sol"; // Import the contract
import "../../src/token/IImagineToken.sol"; // Import the interface

contract ImagineTokenTest is Test {
    ImagineToken public token;
    address private constant OWNER = address(1);
    address private constant NON_OWNER = address(2);

    // Import the ConstructorParams struct directly from IImagineToken interface
    // You don't need to redefine it in the test anymore

    string private constant TOKEN_NAME = "ImagineToken";
    string private constant TOKEN_SYMBOL = "IMT";
    string private constant TOKEN_URI = "https://initial-token-uri.com";
    uint256 private constant INITIAL_SUPPLY = 1000000 * 10 ** 18;
    address private constant TREASURY = address(3);
    address private constant UNIV2ROUTER = address(4);
    address private constant DEXTREASURY = address(5);
    uint256 private constant FEE_BASIS_POINTS = 100; // Example fee
    uint256 private constant DEX_FEE_BASIS_POINTS = 100;
    uint256 private constant MIGRATION_FEE = 10;
    uint256 private constant POOL_CREATION_FEE = 50;
    uint256 private constant MC_LOWER_LIMIT = 1;
    uint256 private constant MC_UPPER_LIMIT = 100;
    uint256 private constant TOKENS_MIGRATION_THRESHOLD = 1000;

    function setUp() public {
        // Use the ConstructorParams struct from the interface
        IImagineToken.ConstructorParams memory params = IImagineToken
            .ConstructorParams({
                name: TOKEN_NAME,
                symbol: TOKEN_SYMBOL,
                tokenURI: TOKEN_URI,
                creator: OWNER,
                totalSupply: INITIAL_SUPPLY,
                virtualTokenReserves: 0,
                virtualCollateralReserves: 0,
                feeBasisPoints: FEE_BASIS_POINTS,
                dexFeeBasisPoints: DEX_FEE_BASIS_POINTS,
                migrationFeeFixed: MIGRATION_FEE,
                poolCreationFee: POOL_CREATION_FEE,
                mcLowerLimit: MC_LOWER_LIMIT,
                mcUpperLimit: MC_UPPER_LIMIT,
                tokensMigrationThreshold: TOKENS_MIGRATION_THRESHOLD,
                treasury: TREASURY,
                uniV2Router: UNIV2ROUTER,
                dexTreasury: DEXTREASURY
            });

        // Deploy the contract with the ConstructorParams struct from the interface
        token = new ImagineToken(params);
    }

    // Test functions follow...
}
