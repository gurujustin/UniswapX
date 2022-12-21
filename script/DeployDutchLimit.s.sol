// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/console2.sol";
import "forge-std/Script.sol";
import {ISignatureTransfer} from "../src/external/ISignatureTransfer.sol";
import {DutchLimitOrderReactor} from "../src/reactors/DutchLimitOrderReactor.sol";
import {OrderQuoter} from "../src/lens/OrderQuoter.sol";
import {DeployPermit2} from "../test/util/DeployPermit2.sol";
import {MockERC20} from "../test/util/mock/MockERC20.sol";

struct DutchLimitDeployment {
    ISignatureTransfer permit2;
    DutchLimitOrderReactor reactor;
    OrderQuoter quoter;
    MockERC20 tokenIn;
    MockERC20 tokenOut;
}

contract DeployDutchLimit is Script, DeployPermit2 {
    address constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;
    address constant UNI_TIMELOCK = 0x1a9C8182C09F50C8318d769245beA52c32BE35BC;
    uint256 constant PROTOCOL_FEES_BPS = 5000;

    function setUp() public {}

    function run() public returns (DutchLimitDeployment memory deployment) {
        vm.startBroadcast();
        if (PERMIT2.code.length == 0) {
            deployPermit2();
        }

        DutchLimitOrderReactor reactor =
            new DutchLimitOrderReactor{salt: 0x00}(address(PERMIT2), PROTOCOL_FEES_BPS, UNI_TIMELOCK);
        console2.log("Reactor", address(reactor));

        OrderQuoter quoter = new OrderQuoter{salt: 0x00}();
        console2.log("Quoter", address(quoter));

        MockERC20 tokenIn = new MockERC20{salt: 0x00}("Token A", "TA", 18);
        console2.log("tokenA", address(tokenIn));
        MockERC20 tokenOut = new MockERC20{salt: 0x00}("Token B", "TB", 18);
        console2.log("tokenB", address(tokenOut));

        vm.stopBroadcast();

        return DutchLimitDeployment(ISignatureTransfer(PERMIT2), reactor, quoter, tokenIn, tokenOut);
    }
}