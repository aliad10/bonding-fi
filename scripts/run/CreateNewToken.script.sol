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

    bytes public validSignature = hex"12e929f034cf7f5613dbfa7e30870ec32d69283dfb168564b4b2b658f4874f1a520df0ee4a454a56cc637a585deece9ca7ddb1c96038c7dda044884c86f6422a1c"; // for generate use generateSignature.js

    function run() external {

        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");

        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IImagineFactory factory = IImagineFactory(factoryAddress);

        factory.createImagineToken(name, symbol,tokenURI, nonce, validSignature);

        vm.stopBroadcast();

    }
}