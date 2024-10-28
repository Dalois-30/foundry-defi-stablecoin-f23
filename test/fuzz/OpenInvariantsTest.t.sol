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
import { ERC20Mock } from "../mocks/ERC20Mock.sol";
import { Handler } from "../fuzz/Handler.t.sol";

contract OpenInvariantsTest is StdInvariant, Test {
    DeployDSC deployDSC;
    DSCEngine engine;
    DecentralizedStableCoin dsc;
    HelperConfig config;
    address weth;
    address btc;
    Handler handler;

    function setUp() external {
        deployDSC = new DeployDSC();
        (dsc, engine, config) = deployDSC.run();
        (,, weth, btc,) = config.activeNetworkConfig();
        // targetContract(address(engine));
        handler = new Handler(engine, dsc);
        targetContract(address(handler));
        console.log("handler: %s", address(handler));
        console.log("engine: %s", address(engine));
        console.log("dsc: %s", address(dsc));
        // hey, don't call redeemcollateral, unless there is collateral to redeem
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        // get the value of all the collateral in the protocol
        // compare it to all the debt (dsc)
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(engine));
        uint256 totalBtcDeposited = IERC20(btc).balanceOf(address(engine));

        uint256 wethValue = engine.getUsdValue(weth, totalWethDeposited);
        uint256 btcValue = engine.getUsdValue(btc, totalBtcDeposited);
        uint256 totalCollateralValue = wethValue + btcValue;

        console.log("totalSupply", totalSupply);
        console.log("totalCollateralValue", totalCollateralValue);

        assert(totalCollateralValue >= totalSupply);
    }

    // function invariant_protocolMustHaveMoreValueThanTotalSupplyDollars() public view {
    //     uint256 totalSupply = dsc.totalSupply();
    //     uint256 wethDeposted = ERC20Mock(weth).balanceOf(address(engine));
    //     uint256 wbtcDeposited = ERC20Mock(btc).balanceOf(address(engine));

    //     uint256 wethValue = engine.getUsdValue(weth, wethDeposted);
    //     uint256 wbtcValue = engine.getUsdValue(btc, wbtcDeposited);

    //     console.log("wethValue: %s", wethValue);
    //     console.log("wbtcValue: %s", wbtcValue);

    //     assert(wethValue + wbtcValue >= totalSupply);
    // }
}