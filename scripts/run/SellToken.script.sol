// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../../contracts/tokenFactory/IImagineFactory.sol";
import "../../contracts/token/IImagineToken.sol";


contract SellToken is Script {


    uint tokenAmount = 100_000_000 * 10 ** 18;
    uint collateralAmountMin = 1;

    function run() external {

        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IImagineFactory factory = IImagineFactory(factoryAddress);
        IImagineToken token = IImagineToken(tokenAddress);

        token.approve(address(factory),tokenAmount);
        
        factory.sellExactIn(address(token), tokenAmount, collateralAmountMin);

        vm.stopBroadcast();

    }
}