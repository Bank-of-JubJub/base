// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {PrivateTokenFactory} from "../src/PrivateTokenFactory.sol";
import {IERC20} from "../src/IERC20.sol";
import {UltraVerifier as ProcessDepositVerifier} from "../src/process_pending_deposits/plonk_vk.sol";
import {UltraVerifier as ProcessTransferVerifier} from "../src/process_pending_transfers/plonk_vk.sol";
import {UltraVerifier as TransferVerifier} from "../src/transfer/plonk_vk.sol";
import {UltraVerifier as WithdrawVerifier} from "../src/withdraw/plonk_vk.sol";
import {UltraVerifier as LockVerifier} from "../src/lock/plonk_vk.sol";

contract PrivateTokenTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
