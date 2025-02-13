// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {DeployPermit2} from "permit2/test/utils/DeployPermit2.sol";

contract MyTest is DeployPermit2 {
    address permit2;

    function setUp() public {
        permit2 = deployPermit2();
    }
}
