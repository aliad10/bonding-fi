// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../../src/tokenFactory/IImagineFactory.sol";

contract CreateNewToken is Script {


    //contract address 

    address public constant factoryAddress = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512;


    string public name = "TestToken";

    string public symbol = "TTK";
    
    string public tokenURI = "test token uri";

    uint256 public nonce = 1;

    bytes public validSignature = hex"362268d4e7b262b9e9902e9b50fc4fe5550a44a03a776b3a54adc0a7c04e305e34e0da3f08ad2ac28e347e99322009940269b6923be9298cd6af04c2b9a177771b"; // for generate use generateSignature.js

    function run() external {
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IImagineFactory factory = IImagineFactory(factoryAddress);

        factory.createImagineToken(name, symbol,tokenURI, nonce, validSignature);

        vm.stopBroadcast();

    }
}