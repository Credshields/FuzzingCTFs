// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";
import "./Fallout.sol";

contract FalloutTest is Test {
    Fallout public target;

    function setUp() public {
        // Deploy the contract
        target = new Fallout();
        // Label the contract for better trace output
        vm.label(address(target), "Fallout");
        // Target the contract for invariant testing
        targetContract(address(target));
    }

    function testOwnerInvariant() public {
        // Track initial state
        address initialOwner = target.owner();

        // Test state changes through all relevant functions
        // Call functions that could affect the invariant
        target.allocate{value: 1 ether}();
        target.sendAllocation(payable(address(this)));
        target.collectAllocations();

        // Final state verification
        address finalOwner = target.owner();
        assertEq(finalOwner, initialOwner, "Owner should not change after any function call");
    }

    function testOwnerDoesNotChangeAfterDeployment() public {
        // Deploy the contract
        Fallout newTarget = new Fallout();
        // Check the owner is set correctly
        address owner = newTarget.owner();
        assertEq(owner, address(this), "Owner should be set to the deployer address");
    }

    function testOnlyOwnerCanCollectAllocations() public {
        // Deploy the contract
        Fallout newTarget = new Fallout();
        // Try to collect allocations as a non-owner
        vm.prank(address(1));
        vm.expectRevert("caller is not the owner");
        newTarget.collectAllocations();
    }

    function testSendAllocation() public {
        // Deploy the contract
        Fallout newTarget = new Fallout();
        // Allocate some funds
        newTarget.allocate{value: 1 ether}();
        // Send allocation to another address
        address allocator = address(1);
        newTarget.sendAllocation(payable(allocator));
        // Check the balance of the allocator
        uint256 balance = newTarget.allocatorBalance(allocator);
        assertEq(balance, 0, "Allocator balance should be zero after sending allocation");
    }

    function testAllocatorBalance() public {
        // Deploy the contract
        Fallout newTarget = new Fallout();
        // Allocate some funds
        newTarget.allocate{value: 1 ether}();
        // Check the balance of the allocator
        uint256 balance = newTarget.allocatorBalance(address(this));
        assertEq(balance, 1 ether, "Allocator balance should be 1 ether");
    }
}