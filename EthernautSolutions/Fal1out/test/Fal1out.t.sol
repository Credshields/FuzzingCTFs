// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Test.sol";
import "./Fallout.sol";

contract FalloutTest is Test {
    Fallout public target;
    address public owner;
    
    function setUp() public {
        // Deploy the contract
        owner = msg.sender;
        target = new Fallout();
        // Label the contract for better trace output
        vm.label(address(target), "Fallout");
        // Target the contract for invariant testing
        targetContract(address(target));
    }

    function testConstructor() public {
        assertEq(target.owner(), owner, "Owner should be msg.sender");  // comment by prasad
                                                                        // this should fail as the target.owner would be address of zero due to misname of the function
        assertEq(target.allocatorBalance(owner), address(target).balance, "Owner's balance should equal initial contract balance");
    }

    function testOnlyOwnerModifier() public {
        (bool success, ) = address(target).call(abi.encodeWithSignature("collectAllocations()"));
        assertTrue(!success, "collectAllocations should fail when called by non-owner");
    }

    function invariant_TheFal1outFunctionCanOnlyBeCalledByTheOwnerOfTheContract() public {
        address initialOwner = target.owner();
        (bool success, ) = address(target).call(abi.encodeWithSignature("Fal1out()"));
        assertTrue(!success, "Fal1out should fail when called by non-owner");
        address finalOwner = target.owner();
        assertEq(finalOwner, initialOwner, "Owner should not change");
    }
}
