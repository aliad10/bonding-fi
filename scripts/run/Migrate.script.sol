// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../../src/tokenFactory/IImagineFactory.sol";

contract CreateNewToken is Script {


    //contract address 

    string public name = "TestToken";

    string public symbol = "TTK";
    
    string public tokenURI = "test token uri";

    uint256 public nonce = 1;

    bytes public validSignature = vm.envBytes("VALID_SIGNATURE"); // for generate use generateSignature.js

    function run() external {

        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");

        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IImagineFactory factory = IImagineFactory(factoryAddress);

        factory.migrate(tokenAddress);

        vm.stopBroadcast();

    }
}