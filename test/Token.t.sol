// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ImagineToken} from "../src/token/ImagineToken.sol"; // Replace with the correct path
import {IImagineToken} from "../src/token/IImagineToken.sol"; // Import interface if needed
import {MockUniswapV2Router} from "../src/utils/external/MockUniswapV2Router.sol"; // Import the Mock Uniswap Router
import {IERC20Errors} from "@openzeppelin-contracts-5.1.0/interfaces/draft-IERC6093.sol";
contract ImagineTokenTest is Test, IERC20Errors {
    ImagineToken public token;
    MockUniswapV2Router public mockUniswapV2Router;

    string private constant INITIAL_URI = "https://initial-uri.com";
    string private constant UPDATED_URI = "https://updated-uri.com";

    string private constant TOKEN_NAME = "ImagineToken";
    string private constant TOKEN_SYMBOL = "IMT";
    string private constant TOKEN_URI = "https://initial-token-uri.com";
    uint256 private constant INITIAL_SUPPLY = 1000000000 * 10 ** 18;
    uint private constant VIRTUAL_TOKEN_RESERVES = 1060000000 * 10 ** 18;
    uint private constant VIRTUAL_COLLATERAL_RESERVES = 16 * 10 ** 17;
    address private TREASURY;
    address private DEXTREASURY;
    uint256 private constant FEE_BASIS_POINTS = 100; // Example fee
    uint256 private constant DEX_FEE_BASIS_POINTS = 6000;
    uint256 private constant MIGRATION_FEE = 1 * 10 ** 17;
    uint256 private constant POOL_CREATION_FEE = 5 * 10 ** 16;
    uint256 private constant MC_LOWER_LIMIT = 25 ether;
    uint256 private constant MC_UPPER_LIMIT = 27 ether;
    uint256 private constant TOKENS_MIGRATION_THRESHOLD =
        799538870462404697804703491;

    address private factory = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a;
    address private WETH = 0xc02aAA39a2A6d2B5321D1101c1b0C92a2b342F9a; // WETH mainnet address (example)

    function setUp() public {
        address TREASURY = vm.addr(
            uint256(keccak256(abi.encodePacked(block.timestamp, "randomSeed1")))
        );

        address DEXTREASURY = vm.addr(
            uint256(keccak256(abi.encodePacked(block.timestamp, "randomSeed2")))
        );

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

        // Try call buyExactOut with msg.value=0 (should fail)
        vm.expectRevert(IImagineToken.FailedToSendETH.selector);
        token.buyExactOut(tokenAmount, maxCollateralAmount);

        // Try call buyExactOut with msg.value less than collateralToPayWithFee (should fail)
        vm.expectRevert(IImagineToken.NotEnoughtETHToBuyTokens.selector);
        token.buyExactOut{value: invalidMaxCollateralAmount}(
            tokenAmount,
            maxCollateralAmount
        );
    }

    function test_buyExactOut() public {
        address factoryAddress = address(this);

        uint tokenAmount = 60000000 * 10 ** 18;
        uint maxCollateralAmount = 9697 * 10 ** 13;
        uint tokenPriceInEth = 96 * 10 ** 15;
        uint totalAmountToSpendInEth = 9696 * 10 ** 13;
        uint totalFee = (tokenPriceInEth * token.feeBPS()) / token.MAX_BPS();
        uint dexTreasuryShare = (totalFee * token.dexFeeBPS()) /
            token.MAX_BPS();
        uint treasuryShare = totalFee - dexTreasuryShare;

        uint prevTokenReserve = token.virtualTokenReserves();
        uint prevCollateralReserve = token.virtualCollateralReserves();
        uint treasuryBalanceBefore = address(token.treasury()).balance;
        uint dexTreasuryBalanceBefore = address(token.dexTreasury()).balance;
        uint buyerBalanceBeforePurchase = address(this).balance;

        token.buyExactOut{value: maxCollateralAmount}(
            tokenAmount,
            maxCollateralAmount
        );

        assertEq(
            tokenAmount,
            token.balanceOf(address(this)),
            "purchased token mismatch"
        );

        assertEq(
            prevTokenReserve - tokenAmount,
            token.virtualTokenReserves(),
            "token reserve mismatch"
        );
        assertEq(
            prevCollateralReserve + tokenPriceInEth,
            token.virtualCollateralReserves(),
            "collateral reserve mismatch"
        );

        assertEq(
            address(token.treasury()).balance,
            treasuryBalanceBefore + treasuryShare,
            "treasury fee balance mismatch"
        );
        assertEq(
            address(token.dexTreasury()).balance,
            dexTreasuryBalanceBefore + dexTreasuryShare,
            "dex treasury fee balance mismatch"
        );
        assertEq(
            buyerBalanceBeforePurchase,
            address(this).balance + totalAmountToSpendInEth,
            "buyer balance mismatch"
        );

        assertEq(
            tokenPriceInEth,
            address(token).balance,
            "token contract eth balance mismatch"
        );
    }

    function test_buyExactOut_max() public {
        address factoryAddress = address(this);

        uint tokenAmount = 600000000 * 10 ** 18;

        uint tokenAmount2 = 200000000 * 10 ** 18;
        uint maxCollateralAmount = 30 * 10 ** 18;

        token.buyExactOut{value: maxCollateralAmount}(
            tokenAmount,
            maxCollateralAmount
        );

        assertEq(token.tradingStopped(), false, "tradingStop mismatch value");

        token.buyExactOut{value: maxCollateralAmount}(
            tokenAmount2,
            maxCollateralAmount
        );

        assertEq(token.tradingStopped(), true, "tradingStop mismatch value");
    }

    function test_buyExactOut_max_upper_limit() public {
        address factoryAddress = address(this);

        uint tokenAmount = 600000000 * 10 ** 18;

        uint tokenAmount2 = 300000000 * 10 ** 18;
        uint maxCollateralAmount = 30 * 10 ** 18;

        token.buyExactOut{value: maxCollateralAmount}(
            tokenAmount,
            maxCollateralAmount
        );

        vm.expectRevert(IImagineToken.MarketcapThresholdReached.selector);

        token.buyExactOut{value: maxCollateralAmount}(
            tokenAmount2,
            maxCollateralAmount
        );
    }

    function test_fail_buyExactIn() public {
        address factoryAddress = address(this);
        address nonFactory = address(
            0xAf37C2Fd7F625A490a6352B852ECc1E09fDC8388
        );
        uint tokenAmountOutMin = 1;
        uint invalidMinTokenAmount = 100000000 * 10 ** 18;

        // uint invalidMaxCollateralAmount = 96 * 10 ** 15;
        uint moreThanContractBalanceAmount = INITIAL_SUPPLY * 2;
        vm.startPrank(nonFactory);
        vm.expectRevert(IImagineToken.OnlyFactory.selector);
        // Try call buyExactIn as a non-factory address (should fail)
        token.buyExactIn(tokenAmountOutMin);

        vm.startPrank(factoryAddress);
        vm.expectRevert(IImagineToken.InsufficientTokenReserves.selector);
        // Try call buyExactOut with buyAmount more than balance (should fail)
        token.buyExactIn(moreThanContractBalanceAmount);

        vm.expectRevert(IImagineToken.SlippageCheckFailed.selector);
        // Try call buyExactIn with small msg.value expecting more token (should fail)
        token.buyExactIn{value: 1}(invalidMinTokenAmount);
    }

    function test_buyExactIn() public {
        address factoryAddress = address(this);
        address nonFactory = address(
            0xAf37C2Fd7F625A490a6352B852ECc1E09fDC8388
        );
        uint exactEthAmountToSpend = 1 * 10 ** 16;
        uint totalFee = (exactEthAmountToSpend * token.feeBPS()) /
            token.MAX_BPS();
        uint ethIn = exactEthAmountToSpend - totalFee;
        uint dexTreasuryFeeShare = (totalFee * token.dexFeeBPS()) /
            token.MAX_BPS();

        uint treasuryFeeShare = totalFee - dexTreasuryFeeShare;
        uint tokenAmountOutMin = 1;
        uint invalidMinTokenAmount = 100000000 * 10 ** 18;
        (uint tokenOutAmount, ) = token.getAmountOutAndFee(
            ethIn,
            token.virtualCollateralReserves(),
            token.virtualTokenReserves(),
            true
        );

        uint buyerBalanceBeforePurchase = address(this).balance;
        uint treasuryBalanceBefore = address(token.treasury()).balance;
        uint dexTreasuryBalanceBefore = address(token.dexTreasury()).balance;

        uint prevTokenReserve = token.virtualTokenReserves();
        uint prevCollateralReserve = token.virtualCollateralReserves();

        vm.startPrank(factoryAddress);
        token.buyExactIn{value: exactEthAmountToSpend}(tokenAmountOutMin);

        assertEq(
            token.balanceOf(address(this)),
            tokenOutAmount,
            "token out amount mismatch"
        );

        assertEq(
            prevTokenReserve - tokenOutAmount,
            token.virtualTokenReserves(),
            "token reserve mismatch"
        );
        assertEq(
            prevCollateralReserve + ethIn,
            token.virtualCollateralReserves(),
            "collateral reserve mismatch"
        );

        assertEq(
            address(token.treasury()).balance,
            treasuryBalanceBefore + treasuryFeeShare,
            "treasury fee balance mismatch"
        );
        assertEq(
            address(token.dexTreasury()).balance,
            dexTreasuryBalanceBefore + dexTreasuryFeeShare,
            "dex treasury fee balance mismatch"
        );

        assertEq(
            buyerBalanceBeforePurchase,
            address(this).balance + exactEthAmountToSpend,
            "buyer balance mismatch"
        );

        assertEq(
            ethIn,
            address(token).balance,
            "token contract eth balance mismatch"
        );
    }

    function test_fail_sellExactIn() public {
        address factoryAddress = address(this);
        address nonFactory = address(
            0xAf37C2Fd7F625A490a6352B852ECc1E09fDC8388
        );

        uint tokenAmount = 60000000 * 10 ** 18;
        uint minCollateralAmount = 9697 * 10 ** 13;
        uint maxCollateralAmount = 9697 * 10 ** 13;

        uint invalidMinCollateralAmount = 1 ether;

        // uint moreThanContractBalanceAmount = INITIAL_SUPPLY * 2;

        vm.startPrank(nonFactory);

        vm.expectRevert(IImagineToken.OnlyFactory.selector);
        // Try call sellExactIn as a non-factory address (should fail)
        token.sellExactIn(tokenAmount, minCollateralAmount);

        vm.startPrank(factoryAddress);

        vm.expectRevert(IImagineToken.SlippageCheckFailed.selector);
        // Try call buyExactOut with less collateral amount (should fail)
        token.sellExactIn(tokenAmount, minCollateralAmount);

        //try to buy some token
        token.buyExactOut{value: maxCollateralAmount}(
            tokenAmount,
            maxCollateralAmount
        );

        // Try call sellExactIn with ERC20InsufficientBalance (should fail)
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector,
                address(this),
                tokenAmount,
                tokenAmount + 1
            )
        );
        token.sellExactIn(tokenAmount + 1, 10);
    }

    function test_sellExactIn() public {
        address factoryAddress = address(this);

        uint tokenAmount = 60000000 * 10 ** 18;
        uint maxCollateralAmount = 9697 * 10 ** 13;
        uint minCollateralAmount = 9 * 10 ** 15;
        uint totalCollateralToSpend = 9696 * 10 ** 13;
        uint totalEthToReceive = 96 * 10 ** 15;
        uint totalFee = (totalEthToReceive * token.feeBPS()) / token.MAX_BPS();
        uint finalTotalEthToReceive = totalEthToReceive - totalFee;
        uint dexTreasuryFeeShare = (totalFee * token.dexFeeBPS()) /
            token.MAX_BPS();
        uint treasuryFeeShare = totalFee - dexTreasuryFeeShare;

        //try to buy some token
        token.buyExactOut{value: maxCollateralAmount}(
            tokenAmount,
            maxCollateralAmount
        );

        uint contractTokenAmountBefore = token.balanceOf(address(token));

        uint treasuryBalanceBeforeSell = address(token.treasury()).balance;
        uint dexTreasuryBalanceBeforeSell = address(token.dexTreasury())
            .balance;

        uint prevTokenReserve = token.virtualTokenReserves();
        uint prevCollateralReserve = token.virtualCollateralReserves();

        uint factoryBalanceBeforeSell = address(this).balance;

        token.sellExactIn(tokenAmount, minCollateralAmount);

        assertEq(
            address(token.treasury()).balance,
            treasuryBalanceBeforeSell + treasuryFeeShare,
            "treasury fee balance mismatch"
        );

        assertEq(
            address(token.dexTreasury()).balance,
            dexTreasuryBalanceBeforeSell + dexTreasuryFeeShare,
            "dex treasury fee balance mismatch"
        );

        assertEq(
            prevTokenReserve + tokenAmount,
            token.virtualTokenReserves(),
            "token reserve mismatch"
        );
        assertEq(
            prevCollateralReserve - totalEthToReceive,
            token.virtualCollateralReserves(),
            "collateral reserve mismatch"
        );

        assertEq(
            factoryBalanceBeforeSell + finalTotalEthToReceive,
            address(this).balance,
            "factory eth balance mismatch"
        );

        assertEq(
            contractTokenAmountBefore + tokenAmount,
            token.balanceOf(address(token)),
            "token contract balance mismatch"
        );

        assertEq(
            0,
            token.balanceOf(address(this)),
            "buyer token balance mismatch"
        );
    }

    function test_fail_sellExactOut() public {
        address factoryAddress = address(this);
        address nonFactory = address(
            0xAf37C2Fd7F625A490a6352B852ECc1E09fDC8388
        );

        uint tokenAmount = 60000000 * 10 ** 18;

        uint tokenAmountMax = 70000000 * 10 ** 18;

        uint invalidTokenAmountMax = tokenAmount - 1;

        uint collateralAmount = 96 * 10 ** 15;
        uint invalidCollateralAmount = collateralAmount + 1;
        uint collateralAmountMinusFee = collateralAmount -
            ((collateralAmount * token.feeBPS()) / token.MAX_BPS());
        uint maxCollateralAmount = 9697 * 10 ** 13;

        // uint invalidMinCollateralAmount = 1 ether;

        vm.startPrank(nonFactory);

        vm.expectRevert(IImagineToken.OnlyFactory.selector);
        // Try call sellExactOut as a non-factory address (should fail)
        token.sellExactOut(tokenAmountMax, collateralAmount);

        vm.startPrank(factoryAddress);

        vm.expectRevert(IImagineToken.FailedToSendETH.selector);
        // Try call sellExactOut with zero contract eth balance (should fail)
        token.sellExactOut(tokenAmountMax, collateralAmount);

        //try to buy some token
        token.buyExactOut{value: maxCollateralAmount}(
            tokenAmount,
            maxCollateralAmount
        );

        vm.expectRevert(IImagineToken.SlippageCheckFailed.selector);
        // Try call buyExactOut with less collateral amount (should fail)
        token.sellExactOut(invalidTokenAmountMax, collateralAmount);

        (uint tokensOut, ) = token.getAmountInAndFee(
            invalidCollateralAmount,
            token.virtualTokenReserves(),
            token.virtualCollateralReserves(),
            true
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector,
                address(this),
                tokenAmount,
                tokensOut
            )
        );

        // Try call sellExactOut with collateral amount that its value is more than token holding (should fail)
        token.sellExactOut(tokenAmountMax, invalidCollateralAmount);
    }

    function test_sellExactOut() public {
        address factoryAddress = address(this);

        uint tokenAmount = 60000000 * 10 ** 18;

        uint tokenAmountMax = 70000000 * 10 ** 18;

        uint collateralAmount = 96 * 10 ** 15;
        uint totalFee = (collateralAmount * token.feeBPS()) / token.MAX_BPS();
        uint collateralAmountMinusFee = collateralAmount - totalFee;
        uint maxCollateralAmount = 9697 * 10 ** 13;

        uint dexTreasuryFeeShare = (totalFee * token.dexFeeBPS()) /
            token.MAX_BPS();
        uint treasuryFeeShare = totalFee - dexTreasuryFeeShare;

        //try to buy some token
        token.buyExactOut{value: maxCollateralAmount}(
            tokenAmount,
            maxCollateralAmount
        );

        uint treasuryBalanceBeforeSell = address(token.treasury()).balance;
        uint dexTreasuryBalanceBeforeSell = address(token.dexTreasury())
            .balance;

        uint prevTokenReserve = token.virtualTokenReserves();
        uint prevCollateralReserve = token.virtualCollateralReserves();

        uint factoryBalanceBeforeSell = address(this).balance;

        uint contractTokenAmountBefore = token.balanceOf(address(token));

        token.sellExactOut(tokenAmount, collateralAmount);

        assertEq(
            address(token.treasury()).balance,
            treasuryBalanceBeforeSell + treasuryFeeShare,
            "treasury fee balance mismatch"
        );

        assertEq(
            address(token.dexTreasury()).balance,
            dexTreasuryBalanceBeforeSell + dexTreasuryFeeShare,
            "dex treasury fee balance mismatch"
        );

        assertEq(
            prevTokenReserve + tokenAmount,
            token.virtualTokenReserves(),
            "token reserve mismatch"
        );
        assertEq(
            prevCollateralReserve - collateralAmount,
            token.virtualCollateralReserves(),
            "collateral reserve mismatch"
        );

        assertEq(
            factoryBalanceBeforeSell + collateralAmountMinusFee,
            address(this).balance,
            "factory eth balance mismatch"
        );

        assertEq(
            contractTokenAmountBefore + tokenAmount,
            token.balanceOf(address(token)),
            "token contract balance mismatch"
        );

        assertEq(
            0,
            token.balanceOf(address(this)),
            "buyer token balance mismatch"
        );
    }

    receive() external payable {}
}
