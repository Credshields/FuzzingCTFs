// Improved test code

// SPDX-License-Identifier: MIT
// model: - GPT4o
// Note: - Gave proper invariant and test case to solve the challenge.
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";
import "./Delegate.sol";
import "./Delegation.sol";

contract DelegateTest is Test {
    Delegate public delegate;
    Delegation public delegation;
    address public deployer;

    function setUp() public {
        // Set the deployer address
        deployer = address(this);

        // Deploy the Delegate contract
        delegate = new Delegate(deployer);

        // Deploy the Delegation contract with the Delegate address
        delegation = new Delegation(address(delegate));

        // Label the contracts for better trace output
        vm.label(address(delegate), "Delegate");
        vm.label(address(delegation), "Delegation");

        // Target the Delegation contract for invariant testing
        targetContract(address(delegation));
    }

    function invariant_OwnerInDelegationIsInitiallySetToTheAddressOfTheContractDeployer() public {
        // Assert that the owner of the Delegation contract is the deployer
        assertEq(delegation.owner(), deployer, "Owner should be the deployer address initially");

        // Test that the owner does not change unexpectedly
        (bool success, ) = address(delegation).call(abi.encodeWithSignature("pwn()"));
        assertTrue(!success, "Fallback should not allow changing the owner");

        // Assert again to ensure the owner is still the deployer
        assertEq(delegation.owner(), deployer, "Owner should remain the deployer address");
    }
}
