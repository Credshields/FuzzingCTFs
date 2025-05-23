// SPDX-License-Identifier: MIT
// model: - GPT4.1-mini
// Note gave the proper invariant to break the contract 
// But not able to generate the proper test-case for the same.
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/StdInvariant.sol";
import "./Delegate.sol";
import "./Delegation.sol";

contract DelegationTest is Test {
    Delegate public delegate;
    Delegation public delegation;

    function setUp() public {
        // Deploy the Delegate contract
        delegate = new Delegate(address(this));
        // Label the contract for better trace output
        vm.label(address(delegate), "Delegate");

        // Deploy the Delegation contract
        delegation = new Delegation(address(delegate));
        // Label the contract for better trace output
        vm.label(address(delegation), "Delegation");

        // Target the contract for invariant testing
        targetContract(address(delegation));
    }

    function testOwnerIsInitiallySetToDeployer() public {
        // Check that the owner is initially set to the deployer
        address initialOwner = delegation.owner();
        assertEq(initialOwner, address(this), "Owner should be initially set to the deployer");
    }

    function testOwnerChangeViaDelegate() public {
        // Call the pwn function via the delegate
        address attacker = address(0x123);
        vm.prank(attacker);
        delegation.fallback();

        // Check that the owner has been changed
        address newOwner = delegation.owner();
        assertEq(newOwner, attacker, "Owner should be changed to the attacker");
    }

    function testOwnerCannotBeZeroAddress() public {
        // Attempt to set the owner to the zero address
        address zeroAddress = address(0);
        vm.prank(zeroAddress);
        delegation.fallback();

        // Check that the owner has not been changed to the zero address
        address currentOwner = delegation.owner();
        assertNotEq(currentOwner, zeroAddress, "Owner should not be set to the zero address");
    }

    function invariant_TheOwnerStateVariableInTheDelegationContractIsInitiallySetToTheAddressThatDeploysTheDelegationContractMsgsenderInItsConstructor() public {
        // Check that the owner is initially set to the deployer
        address initialOwner = delegation.owner();
        assertEq(initialOwner, address(this), "Owner should be initially set to the deployer");

        // Simulate various scenarios to ensure the invariant holds
        address attacker = address(0x123);
        vm.prank(attacker);
        delegation.fallback();      // Prasad -> It should have called with signature and would solve the challenge.

        // Check that the owner has been changed
        address newOwner = delegation.owner();
        assertEq(newOwner, attacker, "Owner should be changed to the attacker");

        // Attempt to set the owner to the zero address
        address zeroAddress = address(0);
        vm.prank(zeroAddress);
        delegation.fallback();

        // Check that the owner has not been changed to the zero address
        address currentOwner = delegation.owner();
        assertNotEq(currentOwner, zeroAddress, "Owner should not be set to the zero address");
    }
}
