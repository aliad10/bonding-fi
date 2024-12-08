// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";

import "../src/tokenFactory/ImagineFactory.sol";

import "@openzeppelin-contracts-5.1.0/access/Ownable.sol";

import {MockUniswapV2Router} from "../src/utils/external/MockUniswapV2Router.sol";


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
        address signer = address(0x36dAE5e01a28Eef44Fc6122C3518157c66570805);

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

        bytes memory validSignature = hex"b1fef06d29793f1448b0f4fdc2ee821b3b7f9ec74af47042b6e017a826faed184ff3c4948568fa164aa701d956231264c6231f2cea53a37f08c131ed0544f90f1c";


        return factory.createImagineToken(name, symbol,tokenURI, nonce, validSignature);
    }

    function testCreateImagineTokenSuccess() public {
        string memory name = "TestToken";
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";

        uint256 nonce = 1;

        bytes memory validSignature = hex"b1fef06d29793f1448b0f4fdc2ee821b3b7f9ec74af47042b6e017a826faed184ff3c4948568fa164aa701d956231264c6231f2cea53a37f08c131ed0544f90f1c";


        // vm.expectEmit(true, true, true, true);
        // emit IImagineFactory.NewImagineToken(address(0), address(this), validSignature);


        address tokenAddress = factory.createImagineToken(name, symbol,tokenURI, nonce, validSignature);


        assertTrue(tokenAddress != address(0), "Token address should not be zero");

        assertEq(factory.imagineTokens(0), tokenAddress, "The token should be added to the imagineTokens array");


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

        bytes memory validSignature = hex"b1fef06d29793f1448b0f4fdc2ee821b3b7f9ec74af47042b6e017a826faed184ff3c4948568fa164aa701d956231264c6231f2cea53a37f08c131ed0544f90f1c";
        
        uint256 nonce = 1;

        factory.createImagineToken(name, symbol, tokenURI, nonce, validSignature);

        vm.expectRevert(IImagineFactory.SignatureIsUsed.selector);

        factory.createImagineToken(name, symbol, tokenURI, nonce, validSignature);
    }

    function testCreateImagineTokenFailInvalidName() public {
        string memory name = ""; // Invalid name
        string memory symbol = "TTK";
        string memory tokenURI = "test token uri";

        bytes memory validSignature = hex"b1fef06d29793f1448b0f4fdc2ee821b3b7f9ec74af47042b6e017a826faed184ff3c4948568fa164aa701d956231264c6231f2cea53a37f08c131ed0544f90f1c";
        
        uint256 nonce = 1;


        vm.expectRevert();

        factory.createImagineToken(name, symbol, tokenURI, nonce, validSignature);
    }


    // function testMigrateFailsNotReady() public {

    //     vm.expectRevert(IImagineFactory.NotReadyForMigration.selector);
        
    //     factory.migrate(tokenInstance);
    // }

    // function testMigrateSuccess() public {
   
    //     assertTrue(factory.readyForMigration(address(tokenInstance)));

    //     // Simulate migration
    //     vm.prank(creator);
    //     vm.expectEmit(true, true, true, true);
    //     emit ImagineFactory.Migrated(
    //         address(token),
    //         100 ether,     // tokensToMigrate (example value)
    //         50 ether,      // tokensToBurn (example value)
    //         1.5 ether,     // collateralAmount (example value)
    //         1.5 ether,     // migration fees
    //         token.pair()   // associated pair address
    //     );

    //     factory.migrate(address(token));

    //     // Post-migration assertions
    //     assertFalse(factory.readyForMigration(address(token)), "Token should no longer be ready for migration");
    // }

    // function testMigrateFailsUnauthorizedCaller() public {


    //     assertTrue(factory.readyForMigration(address(tokenInstance)));

    //     address unauthorizedCaller = address(0x999);
        
    //     vm.prank(unauthorizedCaller);
        
    //     vm.expectRevert("Ownable: caller is not the owner");

    //     factory.migrate(address(tokenInstance));
    // }

    // // Test: Migration Fails - Token Already Migrated
    // function testMigrateFailsAlreadyMigrated() public {
    //     // Ensure the token is marked as ready for migration
    //     assertTrue(factory.readyForMigration(address(token)));

    //     // Simulate migration
    //     vm.prank(creator);
    //     factory.migrate(address(token));

    //     // Attempt migration again and expect revert
    //     vm.expectRevert(ImagineFactory.NotReadyForMigration.selector);
    //     factory.migrate(address(token));
    // }

}

