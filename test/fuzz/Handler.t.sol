// SPDX-License-Identifier: MIT
// Handler is going to narrow down the way we call function

pragma solidity 0.8.19;

import { Test } from "forge-std/Test.sol";
import { DSCEngine } from "../../src/DSCEngine.sol";
import { DecentralizedStableCoin } from "../../src/DecentralizedStableCoin.sol";

contract Handler is Test {
    DSCEngine engine;
    DecentralizedStableCoin dsc;

    constructor(DSCEngine _dscEngine, DecentralizedStableCoin _dsc) {
        engine = _dscEngine;
        dsc = _dsc;
    }

    // redeem collateral <-
    function depositCollateral(address collateral, uint256 amountCollateral) public {
        engine.depositCollateral(collateral, amountCollateral);
    }

}