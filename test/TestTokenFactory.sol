// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import "forge-std/Test.sol";
import "../src/tokenFactory/TokenFactory.sol";

contract TestTokenFactory is Test {
    TokenFactory factory;

    function setUp() public {
        factory = new TokenFactory();
    }

    
    function testConstructorSuccess() public {
        
        TokenFactory factorylocal = new TokenFactory();

        
        assertEq(factorylocal.totalSupply(), 0, "Total supply should be zero by default");
        assertEq(factorylocal.treasury(), address(0), "Treasury address should be uninitialized");
        assertEq(factorylocal.dexTreasury(), address(0), "DEX Treasury address should be uninitialized");
        assertEq(factorylocal.signer(), address(0), "Signer address should be uninitialized");
    }

}
