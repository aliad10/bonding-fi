// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../../contracts/token/IImagineToken.sol";


contract CheckProgress is Script {

    function run() external returns(address pair) {

        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        IImagineToken token = IImagineToken(tokenAddress);


        pair = token.pair();

        vm.stopBroadcast();
    }
}