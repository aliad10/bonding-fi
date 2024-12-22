// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "../../contracts/tokenFactory/ImagineFactory.sol";
import "forge-std/console.sol";

contract DeployImagineFactory is Script {

    function run() external returns (address) {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        uint256 totalSupply = 1_000_000_000 ether;
        uint256 virtualTokenReserves = 1_060_000_000 ether;
        uint256 virtualCollateralReserves = 1.6 ether;
        uint256 feeBasisPoints = 100;
        uint256 dexFeeBasisPoints = 6000;
        uint256 migrationFeeFixed = 0.1 ether;
        uint256 poolCreationFee = 0.05 ether;
        uint256 mcUpperLimit = 27 ether;
        uint256 mcLowerLimit = 25 ether;
        uint256 tokensMigrationThreshold = 799538870462404697804703491; // near to 800 million ether

        address uniswapV2Router = vm.envAddress("UNISWAP_V2_ROUTER");
        
        //change this address
        
        address treasury = vm.envAddress("TREASURY");
        address dexTreasury = vm.envAddress("DEX_TREASURY");
        address signer = vm.envAddress("SIGNER");

        vm.startBroadcast(deployerPrivateKey);

        ImagineFactory imagineFactory = new ImagineFactory(
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

        vm.stopBroadcast();

        return (address(imagineFactory));
    }
}