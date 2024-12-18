// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Test.sol";

import "../src/tokenFactory/ImagineFactory.sol";

import "@openzeppelin-contracts-5.1.0/access/Ownable.sol";
import {Pausable} from "@openzeppelin-contracts-5.1.0/utils/Pausable.sol";

import {MockUniswapV2Router} from "../src/utils/external/MockUniswapV2Router.sol";

import {MockERC20} from "../src/utils/external/MockERC20.sol";

import "@openzeppelin-contracts-5.1.0/utils/cryptography/MessageHashUtils.sol";


contract TestImagineFactory is Test {
    
    ImagineFactory public factory;
    MockUniswapV2Router public mockUniswapV2Router;
    ImagineToken public tokenInstance;


    function setUp() public {
        uint256 totalSupply = 1_000_000_000 ether;
        uint256 virtualTokenReserves = 1_060_000_000 ether;
        uint256 virtualCollateralReserves = 1.6 ether;
        uint256 feeBasisPoints = 100; // 1%
        uint256 dexFeeBasisPoints = 50; // 0.5%
        uint256 migrationFeeFixed = 0.5 ether;
        uint256 poolCreationFee = 0.25 ether;
        uint256 mcUpperLimit = 27 ether;
        uint256 mcLowerLimit = 25 ether;
        uint256 tokensMigrationThreshold = 799_000_000 ether;
        address treasury = address(0x123);
        address dexTreasury = address(0x456);
        address signer = address(0xB71a4183035b75b89a65380C0E8965fbf5101341);

        mockUniswapV2Router = new MockUniswapV2Router();

        factory = new ImagineFactory(
            totalSupply,
            virtualTokenReserves,
            virtualCollateralReserves,
            feeBasisPoints,
            dexFeeBasisPoints,
            migrationFeeFixed,
            poolCreationFee,
            mcUpperLimit,
            mcLowerLimit,
            tokensMigrationThreshold,
            treasury,
            dexTreasury,
            address(mockUniswapV2Router),
            signer
        );

        tokenInstance = ImagineToken(CreateImagineTokenExample());


    }

    
    function testConstructorSuccess() public {

        ImagineFactory localFactory;


        uint256 totalSupply = 1_000_000_000 ether;
        uint256 virtualTokenReserves = 1_060_000_000 ether;
        uint256 virtualCollateralReserves = 1.6 ether;
        uint256 feeBasisPoints = 100; // 1%
        uint256 dexFeeBasisPoints = 50; // 0.5%
        uint256 migrationFeeFixed = 0.5 ether;
        uint256 poolCreationFee = 0.25 ether;
        uint256 mcUpperLimit = 27 ether;
        uint256 mcLowerLimit = 25 ether;
        uint256 tokensMigrationThreshold = 799_000_000 ether;
        address treasury = address(0x123);
        address dexTreasury = address(0x456);
        address uniswapV2Router = address(0x789);
        address signer = address(0xabc);

        localFactory = new ImagineFactory(
            totalSupply,
            virtualTokenReserves,
            virtualCollateralReserves,
            feeBasisPoints,
            dexFeeBasisPoints,
            migrationFeeFixed,
            poolCreationFee,
            mcUpperLimit,
            mcLowerLimit,
            tokensMigrationThreshold,
            treasury,
            dexTreasury,
            uniswapV2Router,
            signer
        );

        assertEq(localFactory.totalSupply(), 1_000_000_000 ether, "Total supply should be set correctly");
        assertEq(localFactory.virtualTokenReserves(), 1_060_000_000 ether, "Virtual token reserves should be set correctly");
        assertEq(localFactory.virtualCollateralReserves(), 1.6 ether, "Virtual collateral reserves should be set correctly");
        assertEq(localFactory.feeBasisPoints(), 100, "Fee basis points should be set correctly");
        assertEq(localFactory.dexFeeBasisPoints(), 50, "DEX fee basis points should be set correctly");
        assertEq(localFactory.migrationFeeFixed(), 0.5 ether, "Migration fee should be set correctly");
        assertEq(localFactory.poolCreationFee(), 0.25 ether, "Pool creation fee should be set correctly");
        assertEq(localFactory.mcUpperLimit(), 27 ether, "MC upper limit should be set correctly");
        assertEq(localFactory.mcLowerLimit(), 25 ether, "MC lower limit should be set correctly");
        assertEq(localFactory.tokensMigrationThreshold(), 799_000_000 ether, "Tokens migration threshold should be set correctly");
        assertEq(localFactory.treasury(), address(0x123), "Treasury address should be set correctly");
        assertEq(localFactory.dexTreasury(), address(0x456), "DEX Treasury address should be set correctly");
        assertEq(localFactory.UNISWAP_V2_ROUTER(), address(0x789), "Uniswap V2 router address should be set correctly");
        assertEq(localFactory.signer(), address(0xabc), "Signer address should be set correctly");

    }


    function testPauseAndUnpuase() public {

        address nonOwner = address(0xAf37C2Fd7F625A490a6352B852ECc1E09fDC8388);

        vm.startPrank(nonOwner);

        vm.expectRevert(abi.encodeWithSelector(
            Ownable.OwnableUnauthorizedAccount.selector, 
            nonOwner
        ));

        factory.pause();

        vm.stopPrank();

        
        factory.pause();


        vm.startPrank(nonOwner);

        vm.expectRevert(abi.encodeWithSelector(
            Ownable.OwnableUnauthorizedAccount.selector, 
            nonOwner
        ));

        factory.unpause();

        vm.stopPrank();
    }


    function testSetConfigSuccess() public {
        // Call the setConfig function from the owner address (msg.sender)
        factory.setConfig(
            2_000_000_000 ether,
            2_120_000_000 ether,
            3.2 ether,
            200,   // Fee basis points
            100,   // DEX fee basis points
            1 ether,
            0.5 ether,
            54 ether,
            45 ether,
            1_600_000_000 ether,
            address(0x111),
            address(0x222),
            address(0x333)
        );

        // Verify the state has been updated correctly
        assertEq(factory.totalSupply(), 2_000_000_000 ether, "Total supply should be updated correctly");
        assertEq(factory.virtualTokenReserves(), 2_120_000_000 ether, "Virtual token reserves should be updated correctly");
        assertEq(factory.virtualCollateralReserves(), 3.2 ether, "Virtual collateral reserves should be updated correctly");
        assertEq(factory.feeBasisPoints(), 200, "Fee basis points should be updated correctly");
        assertEq(factory.dexFeeBasisPoints(), 100, "DEX fee basis points should be updated correctly");
        assertEq(factory.migrationFeeFixed(), 1 ether, "Migration fee should be updated correctly");
        assertEq(factory.poolCreationFee(), 0.5 ether, "Pool creation fee should be updated correctly");
        assertEq(factory.mcUpperLimit(), 54 ether, "MC upper limit should be updated correctly");
        assertEq(factory.mcLowerLimit(), 45 ether, "MC lower limit should be updated correctly");
        assertEq(factory.tokensMigrationThreshold(), 1_600_000_000 ether, "Tokens migration threshold should be updated correctly");
        assertEq(factory.treasury(), address(0x111), "Treasury address should be updated correctly");
        assertEq(factory.dexTreasury(), address(0x222), "DEX Treasury address should be updated correctly");
        assertEq(factory.signer(), address(0x333), "Signer address should be updated correctly");
    }


    function testSetConfigFail() public {

        address nonOwner = address(0xAf37C2Fd7F625A490a6352B852ECc1E09fDC8388);

        vm.startPrank(nonOwner);

        vm.expectRevert(abi.encodeWithSelector(
            Ownable.OwnableUnauthorizedAccount.selector, 
            nonOwner
        ));

        factory.setConfig(
            2_000_000_000 ether,
            2_120_000_000 ether,
            3.2 ether,
            200,   // Fee basis points
            100,   // DEX fee basis points
            1 ether,
            0.5 ether,
            54 ether,
            45 ether,
            1_600_000_000 ether,
            address(0x111),
            address(0x222),
            address(0x333)
        );

        vm.stopPrank();
    }

    function CreateImagineTokenExample() public returns(address) {
        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";

        uint256 nonce = 1;

        bytes memory validSignature = generateSignature(nonce);

        return factory.createImagineToken(name, symbol,tokenURI, nonce, validSignature);
    }


    function testCreateImagineTokenSuccess() public {
        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";

        uint256 nonce = 3;

        bytes memory validSignature = generateSignature(nonce);


        address tokenAddress = factory.createImagineToken(name, symbol,tokenURI, nonce, validSignature);

        assertTrue(tokenAddress != address(0), "Token address should not be zero");

        assertEq(factory.imagineTokens(1), tokenAddress, "The token should be added to the imagineTokens array");
    }

    function testCreateImagineTokenFailInvalidSignature() public {
        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "https://token.uri";
        uint256 nonce = 1;

        bytes memory invalidSignature = hex"123456";

        vm.expectRevert(IImagineFactory.InvalidSignature.selector);

        factory.createImagineToken(name, symbol, tokenURI, nonce, invalidSignature);
    }

    function testCreateImagineTokenFailDuplicateSignature() public {
        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";
        
        uint256 nonce = 1;

        bytes memory validSignature = generateSignature(nonce);

        vm.expectRevert(IImagineFactory.SignatureIsUsed.selector);

        factory.createImagineToken(name, symbol, tokenURI, nonce, validSignature);
    }

    function testCreateImagineTokenFailInvalidName() public {
        string memory name = ""; // Invalid name
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";
        
        uint256 nonce = 1;

        bytes memory validSignature = generateSignature(nonce);


        vm.expectRevert();

        factory.createImagineToken(name, symbol, tokenURI, nonce, validSignature);
    }

    function testCreateImagineTokenFailPause() public {

        factory.pause();

        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";

        uint256 nonce = 2;

        bytes memory validSignature = generateSignature(nonce);

        vm.expectRevert(Pausable.EnforcedPause.selector);

        address tokenAddress = factory.createImagineToken(name, symbol,tokenURI, nonce, validSignature);
    }

    function testCreateImagineTokenAndBuySuccessfull() public {

        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";

        uint256 nonce = 2;

        uint tokenAmount = 100_000 * 10 ** 18;
        uint maxCollateralAmount = 1 * 10 ** 18;
        
        bytes memory validSignature = generateSignature(nonce);

        address tokenAddress = factory.createImagineTokenAndBuy{value:maxCollateralAmount}(name, symbol,tokenURI, nonce,tokenAmount, validSignature);

        assertTrue(ImagineToken(tokenAddress).balanceOf(address(this)) > tokenAmount,"token amount not true");
    }

    function testCreateImagineTokenAndBuyFail() public {

        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";

        uint256 nonce = 2;

        uint tokenAmount = 500_000_000 * 10 ** 18;
        uint maxCollateralAmount = 1 * 10 ** 18;
        
        bytes memory validSignature = generateSignature(nonce);

        vm.expectRevert(IImagineToken.SlippageCheckFailed.selector);

        address tokenAddress = factory.createImagineTokenAndBuy{value:maxCollateralAmount}(name, symbol,tokenURI, nonce,tokenAmount, validSignature);
    }

    function testCreateImagineTokenAndBuyPuase() public {

        factory.pause();

        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";

        uint256 nonce = 2;

        uint tokenAmount = 1_000_000 * 10 ** 18;
        uint maxCollateralAmount = 1 * 10 ** 18;
        
        bytes memory validSignature = generateSignature(nonce);

        vm.expectRevert(Pausable.EnforcedPause.selector);

        address tokenAddress = factory.createImagineTokenAndBuy{value:maxCollateralAmount}(name, symbol,tokenURI, nonce,tokenAmount, validSignature);
    }

    function testBuyExactOutFail() public {

        uint tokenAmount = 500_000_000 * 10 ** 18;
        uint maxCollateralAmount = 1 * 10 ** 18;

        vm.expectRevert(IImagineToken.SlippageCheckFailed.selector);

        factory.buyExactOut{value:maxCollateralAmount}(address(tokenInstance), tokenAmount, maxCollateralAmount);

    }

    function testBuyExactOutSuccess() public {

        uint tokenAmount = 100_000_000 * 10 ** 18;
        uint maxCollateralAmount = 2 * 10 ** 18;

        maxCollateralAmount = tokenInstance.getAmountInAndFee(tokenAmount, false);

        factory.buyExactOut{value:maxCollateralAmount}(address(tokenInstance), tokenAmount, maxCollateralAmount);

        assertTrue(tokenInstance.balanceOf(address(this)) == tokenAmount,"the amount of balance not true");
    }


    function testBuyExactInFail() public {

        uint tokenAmountMin = 500_000_000 * 10 ** 18;
        uint maxEtherSpent = 1 * 10 ** 18;

        vm.expectRevert(IImagineToken.SlippageCheckFailed.selector);

        factory.buyExactIn{value:maxEtherSpent}(address(tokenInstance), tokenAmountMin);

    }

    function testBuyExactInSuccess() public {

        uint tokenAmountMin = 100_000_000 * 10 ** 18;
        uint maxEtherSpent = 1 * 10 ** 18;


        tokenAmountMin = tokenInstance.getAmountOutAndFee(maxEtherSpent, true);

        factory.buyExactIn{value:maxEtherSpent}(address(tokenInstance), tokenAmountMin);
        
        assertTrue(tokenInstance.balanceOf(address(this)) >= tokenAmountMin,"the amount of balance not true");
    }


    function testSellExactInSuccess() public {

        uint tokenAmount = 100_000_000 * 10 ** 18;
        uint maxCollateralAmount = 2 * 10 ** 18;

        factory.buyExactOut{value:maxCollateralAmount}(address(tokenInstance), tokenAmount, maxCollateralAmount);

        uint256 _amountCollateralMin = tokenInstance.getAmountOutAndFee(tokenAmount, false);

        tokenInstance.approve(address(factory), tokenAmount);

        factory.sellExactIn(address(tokenInstance), tokenAmount, _amountCollateralMin);

        assertTrue(tokenInstance.balanceOf(address(this)) == 0,"the amount of balance not true");
    }


    function testSellExactOutSuccess() public {

        uint tokenAmount = 100_000_000 * 10 ** 18;
        uint maxCollateralAmount = 2 * 10 ** 18;

        uint wantEtherAmount = 0.1 * 10 ** 18;

        factory.buyExactOut{value:maxCollateralAmount}(address(tokenInstance), tokenAmount, maxCollateralAmount);
        

        tokenAmount = tokenInstance.getAmountInAndFee(wantEtherAmount, true);

        tokenInstance.approve(address(factory), tokenAmount);

        factory.sellExactOut(address(tokenInstance), tokenAmount, wantEtherAmount);

        assertTrue(tokenInstance.balanceOf(address(this)) == (100_000_000 * 10 ** 18)-tokenAmount,"the amount of balance not true");
    }


    function testMigrationSuccess() public {

        vm.etch(tokenInstance.pair(), type(MockERC20).runtimeCode);
        

        uint tokenAmount = 800_000_000 * 10 ** 18;
        uint maxCollateralAmount = 5.5 * 10 ** 18;

        assertTrue(factory.readyForMigration(address(tokenInstance)) == 0, "readyForMigration must be not ready");

        factory.buyExactOut{value:maxCollateralAmount}(address(tokenInstance), tokenAmount, maxCollateralAmount);

        assertTrue(factory.readyForMigration(address(tokenInstance)) == 1, "readyForMigration must be change to ready for update");

        factory.migrate(address(tokenInstance));

        assertTrue(factory.readyForMigration(address(tokenInstance)) == 2, "readyForMigration no change to already migrate");
    }

    function testMigrateFailsAlreadyMigrated() public {
    
        vm.etch(tokenInstance.pair(), type(MockERC20).runtimeCode);
        

        uint tokenAmount = 800_000_000 * 10 ** 18;
        uint maxCollateralAmount = 5.5 * 10 ** 18;

        factory.buyExactOut{value:maxCollateralAmount}(address(tokenInstance), tokenAmount, maxCollateralAmount);

        factory.migrate(address(tokenInstance));

        vm.expectRevert(IImagineFactory.MigratedBefore.selector);

        factory.migrate(address(tokenInstance));
    }


    function testMigrateFailsNotReady() public {

        vm.expectRevert(IImagineFactory.NotReadyForMigration.selector);
        
        factory.migrate(address(tokenInstance));
    }

    function testAfterMigrateCantBuy() public {

        vm.etch(tokenInstance.pair(), type(MockERC20).runtimeCode);
        

        uint tokenAmount = 800_000_000 * 10 ** 18;
        uint maxCollateralAmount = 5.5 * 10 ** 18;

        factory.buyExactOut{value:maxCollateralAmount}(address(tokenInstance), tokenAmount, maxCollateralAmount);

        factory.migrate(address(tokenInstance));

        tokenAmount = 20_000_000 * 10 ** 18;
        maxCollateralAmount = 0.5 * 10 ** 18;

        vm.expectRevert(IImagineToken.TradingStopped.selector);

        factory.buyExactOut{value:maxCollateralAmount}(address(tokenInstance), tokenAmount, maxCollateralAmount);
    }


    function testDeployFactoryForTestNet() public {

        ImagineFactory localFactory;


        uint256 totalSupply = 1_000_000_000 ether;
        uint256 virtualTokenReserves = 1_060_000_000 ether;
        uint256 virtualCollateralReserves = .16 ether;
        uint256 feeBasisPoints = 100; // 1%
        uint256 dexFeeBasisPoints = 6000; // 0.5%
        uint256 migrationFeeFixed = 0.01 ether;
        uint256 poolCreationFee = 0.005 ether;
        uint256 mcUpperLimit = 2.7 ether;
        uint256 mcLowerLimit = 2.5 ether;
        uint256 tokensMigrationThreshold = 799538870462404697804703491;

        address treasury = address(0x123);
        address dexTreasury = address(0x456);
        
        mockUniswapV2Router = new MockUniswapV2Router();

        
        address uniswapV2Router = address(mockUniswapV2Router);

        uint256 privateKey = 0x7b0646b1c129bb5fd7fbed0be1c4c89eea07b79a4e46d1cf2198c2bdd6c272e5;
        
        address signer = vm.addr(privateKey);

        localFactory = new ImagineFactory(
            totalSupply,
            virtualTokenReserves,
            virtualCollateralReserves,
            feeBasisPoints,
            dexFeeBasisPoints,
            migrationFeeFixed,
            poolCreationFee,
            mcUpperLimit,
            mcLowerLimit,
            tokensMigrationThreshold,
            treasury,
            dexTreasury,
            uniswapV2Router,
            signer
        );


        string memory name1 = "TestToken";
        string memory symbol1 = "TTK";
        string memory tokenURI1 = "test token uri";

        uint256 nonce1 = 1;

        address contractAddress = address(localFactory);
        address msgSender = address(this);

        uint256 chainId = block.chainid;


        vm.startPrank(signer);

        bytes32 messageHash =MessageHashUtils.toEthSignedMessageHash(keccak256(
            abi.encode(name1, symbol1, tokenURI1, nonce1, contractAddress, chainId, msgSender)
        ));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);

        vm.stopPrank();

        bytes memory signature = abi.encodePacked(r, s, v);

        bytes memory validSignature1 = signature;

        address token = localFactory.createImagineToken(name1, symbol1,tokenURI1, nonce1, validSignature1);

        ImagineToken tokenInstance1 = ImagineToken(token);

        vm.etch(tokenInstance1.pair(), type(MockERC20).runtimeCode);
        

        uint tokenAmount1 = 800_000_000 * 10 ** 18;
        uint maxCollateralAmount1 = .55 * 10 ** 18;

        localFactory.buyExactOut{value:maxCollateralAmount1}(address(tokenInstance1), tokenAmount1, maxCollateralAmount1);

        assertTrue(address(tokenInstance1).balance < 0.5 ether, "the balance of contract must be less that .5 ether");

        assertTrue(localFactory.readyForMigration(address(tokenInstance1)) == 1, "readyForMigration must be change to ready for update");

        localFactory.migrate(address(tokenInstance1));
    }


    function generateSignature(uint256 _nonce) public returns(bytes memory) {
        // Variables
        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";

        uint256 nonce = _nonce;

        address contractAddress = address(factory);
        address msgSender = address(this);

        uint256 chainId = block.chainid;

        uint256 privateKey = 0x7b0646b1c129bb5fd7fbed0be1c4c89eea07b79a4e46d1cf2198c2bdd6c272e5;

        address signer = vm.addr(privateKey);

        vm.startPrank(signer);

        bytes32 messageHash =MessageHashUtils.toEthSignedMessageHash(keccak256(
            abi.encode(name, symbol, tokenURI, nonce, contractAddress, chainId, msgSender)
        ));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, messageHash);

        vm.stopPrank();

        bytes memory signature = abi.encodePacked(r, s, v);

        return signature;
        
    }

    receive() external payable {}

}
