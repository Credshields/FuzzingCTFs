// SPDX-License-Identifier: MIT
// model: - GPT4 Turbo
// Note: - Gave proper invariant and test case to solve the challenge.
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Delegation.sol";

contract DelegationTest is Test {
    Delegate public delegate;
    Delegation public delegation;
    
    function setUp() public {
        // Deploy the Delegate contract
        delegate = new Delegate(address(this));
        vm.label(address(delegate), "DelegateContract");

        // Deploy the Delegation contract with the Delegate contract address
        delegation = new Delegation(address(delegate));
        vm.label(address(delegation), "DelegationContract");
    }

    function test_OwnerInDelegationContractIsSetToTheAddressThatDeploysTheContractAndIsNotChangedThereafter() public {
        // Check that the owner of the Delegation contract is this test contract
        assertEq(delegation.owner(), address(this), "Owner should be the deployer");

        // Attempt to change the owner via the Delegate contract's pwn function
        (bool success,) = address(delegation).call(abi.encodeWithSignature("pwn()"));
        assertTrue(success, "Call to pwn should succeed");

        // Verify that the owner of the Delegation contract has not changed
        assertEq(delegation.owner(), address(this), "Owner should not change after pwn call");
    }
}
