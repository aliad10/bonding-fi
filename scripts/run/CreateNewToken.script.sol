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

    bytes public validSignature = hex"0a5503217727afcf5ba93b7b3e74009797ffba688c21d016a602ce39490bf63c17bfa8398faea05973adcdd56de6dddb94343ad72bd16c28cdb123101e82c43a1b"; // for generate use generateSignature.js

    function run() external {

        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");

        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IImagineFactory factory = IImagineFactory(factoryAddress);

        factory.createImagineToken(name, symbol,tokenURI, nonce, validSignature);

        vm.stopBroadcast();

    }
}