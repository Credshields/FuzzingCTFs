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

    function testOwnerIsSetToMsgSenderInConstructor() public {
        // Check that the owner is set to msg.sender in the constructor
        address initialOwner = target.owner();
        assertEq(initialOwner, address(this), "Owner should be set to msg.sender in the constructor");
    }

    function testAllocateFunction() public {
        // Test the allocate function
        vm.prank(address(0x1));
        target.allocate{value: 1 ether}();

        uint256 balance = target.allocatorBalance(address(0x1));
        assertEq(balance, 1 ether, "Allocation should be updated correctly");
    }

    function testSendAllocationFunction() public {
        // Test the sendAllocation function
        vm.prank(address(0x1));
        target.allocate{value: 1 ether}();

        vm.prank(address(0x1));
        target.sendAllocation(address(0x1));

        uint256 balance = target.allocatorBalance(address(0x1));
        assertEq(balance, 0, "Allocation should be sent and reset to zero");
    }

    function testCollectAllocationsFunction() public {
        // Test the collectAllocations function
        vm.prank(address(0x1));
        target.allocate{value: 1 ether}();

        vm.prank(address(this));
        target.collectAllocations();

        uint256 contractBalance = address(target).balance;
        assertEq(contractBalance, 0, "Contract balance should be zero after collecting allocations");
    }

    function testOnlyOwnerModifier() public {
        // Test the onlyOwner modifier
        vm.prank(address(0x2));
        vm.expectRevert("caller is not the owner");
        target.collectAllocations();
    }

    function testEdgeCases() public {
        // Test edge cases
        vm.prank(address(0x1));
        vm.expectRevert("caller is not the owner");
        target.sendAllocation(address(0x1));

        vm.prank(address(0x1));
        vm.expectRevert("caller is not the owner");
        target.collectAllocations();
    }
}
