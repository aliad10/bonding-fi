// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../../contracts/tokenFactory/IImagineFactory.sol";


contract GetAmountOut is Script {

    function run() external returns(uint256 amountOut) {

        uint256 amount = 5 ether;

        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IImagineFactory factory = IImagineFactory(factoryAddress);


        amountOut = factory.getAmountOut(amount);

        vm.stopBroadcast();
    }
}