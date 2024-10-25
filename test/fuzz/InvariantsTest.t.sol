// SPDX-License-Identifier: MIT

// Have our invariant aka properties

// What are our invariants?

// 1. The total supply of DSC should be less than the total value of all collateral
// 2. Getter view functions should never revert <- evergreen invariant

pragma solidity 0.8.19;

import { Test } from "forge-std/Test.sol";
import { DSCEngine } from "../../src/DSCEngine.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
import { console } from "forge-std/console.sol";
import { DeployDSC } from "../../script/DeployDSC.s.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { DecentralizedStableCoin } from "../../src/DecentralizedStableCoin.sol";    
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDSC deployDSC;
    DSCEngine engine;
    DecentralizedStableCoin dsc;
    HelperConfig config;
    address weth;
    address btc;

    function setUp() external {
        deployDSC = new DeployDSC();
        (dsc, engine, config) = deployDSC.run();
        (,, weth, btc,) = config.activeNetworkConfig();
        console.log("address weth", weth);
        console.log("address btc", btc);
        console.log("address dsc", address(dsc));
        targetContract(address(engine));
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        // get the value of all the collateral in the protocol
        // compare it to all the debt (dsc)
        uint256 totalSupply = dsc.totalSupply();
        uint totalWethDeposited = IERC20(weth).balanceOf(address(engine));
        uint totalBtcDeposited = IERC20(btc).balanceOf(address(engine));

        uint256 wethValue = engine.getUsdValue(weth, totalWethDeposited);
        uint256 btcValue = engine.getUsdValue(btc, totalBtcDeposited);
        uint256 totalCollateralValue = wethValue + btcValue;

        console.log("totalSupply", totalSupply);
        console.log("totalCollateralValue", totalCollateralValue);

        assert(wethValue + btcValue >= totalSupply);
    }
}