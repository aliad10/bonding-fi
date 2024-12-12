// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../../src/tokenFactory/IImagineFactory.sol";

contract CreateNewToken is Script {


    //contract address 

    address public constant factoryAddress = 0xb8d54C3d0AB1300cbE437ECC14B2baC26603522d;


    string public name = "";

    string public symbol = "";
    
    string public tokenURI = "";

    uint256 public nonce = 1;

    bytes public validSignature = ""; // for generate use generateSignature.js

    function run() external {
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IImagineFactory factory = IImagineFactory(factoryAddress);

        factory.createImagineToken(name, symbol,tokenURI, nonce, validSignature);

        vm.stopBroadcast();

    }
}