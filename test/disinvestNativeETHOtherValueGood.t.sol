// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/test/MyToken.sol";
import "../src/TTSwap_Market.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../src/interfaces/I_TTSwap_Market.sol";
import {L_ProofIdLibrary, L_Proof} from "../src/libraries/L_Proof.sol";
import {L_Good} from "../src/libraries/L_Good.sol";
import {L_TTSwapUINT256Library, toTTSwapUINT256, addsub, subadd, lowerprice, toUint128} from "../src/libraries/L_TTSwapUINT256.sol";

import {L_GoodConfigLibrary} from "../src/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../src/libraries/L_MarketConfig.sol";

contract disinvestNativeETHOwnValueGood is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_TTSwapUINT256Library for uint256;
    using L_GoodConfigLibrary for uint256;

    using L_ProofIdLibrary for S_ProofKey;

    address metagood;
    address normalgoodusdt;
    address normalgoodeth;

    function setUp() public override {
        BaseSetup.setUp();
        initmetagood();
        investOtherERC20ValueGood();
    }

    function initmetagood() public {
        deal(marketcreator, 1000000 * 10 ** 6);
        vm.startPrank(marketcreator);
        uint256 _goodconfig = (2 ** 255) +
            1 *
            2 ** 217 +
            3 *
            2 ** 211 +
            5 *
            2 ** 204 +
            7 *
            2 ** 197;
        market.initMetaGood{value: 50000 * 10 ** 6}(
            address(1),
            toTTSwapUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            _goodconfig,
            defaultdata
        );
        metagood = address(1);
        vm.stopPrank();
    }

    function investOtherERC20ValueGood() public {
        vm.startPrank(users[2]);
        deal(users[2], 1000000 * 10 ** 6);
        market.investGood{value: 50000000000}(
            metagood,
            address(0),
            50000 * 10 ** 6,
            defaultdata,
            defaultdata
        );
        vm.stopPrank();
    }

    function testDistinvestProof() public {
        vm.startPrank(users[2]);
        uint256 normalproof;
        normalproof = S_ProofKey(users[2], metagood, address(0)).toId();
        S_ProofState memory _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            49995000000,
            "before disinvest:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            49995000000,
            "before disinvest:proof quantity error"
        );

        assertEq(
            _proof.invest.amount0(),
            0,
            "before disinvest:proof contruct error"
        );

        S_GoodTmpState memory good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            99995000000,
            "before disinvest erc20 good:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            99995000000,
            "before disinvest erc20 good:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            99995000000,
            "before disinvest erc20 good:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            99995000000,
            "before disinvest erc20 good:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            5000000,
            "before disinvest erc20 good:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "before disinvest erc20 good:metagood feeQuantityState amount1 error"
        );

        market.disinvestProof(normalproof, 10000 * 10 ** 6, address(0));
        snapLastCall("disinvest_other_nativeth_valuegood_first");
        good_ = market.getGoodState(metagood);
        assertEq(
            good_.currentState.amount0(),
            89995000000,
            "after disinvest erc20 good:metagood currentState amount0 error"
        );
        assertEq(
            good_.currentState.amount1(),
            89995000000,
            "after disinvest erc20 good:metagood currentState amount1 error"
        );
        assertEq(
            good_.investState.amount0(),
            89995000000,
            "after disinvest erc20 good:metagood investState amount0 error"
        );
        assertEq(
            good_.investState.amount1(),
            89995000000,
            "after disinvest erc20 good:metagood investState amount1 error"
        );
        assertEq(
            good_.feeQuantityState.amount0(),
            7499975,
            "after disinvest erc20 good:metagood feeQuantityState amount0 error"
        );
        assertEq(
            good_.feeQuantityState.amount1(),
            0,
            "after disinvest erc20 good:metagood feeQuantityState amount1 error"
        );

        _proof = market.getProofState(normalproof);
        assertEq(
            _proof.state.amount0(),
            39995000000,
            "after disinvest:proof value error"
        );
        assertEq(
            _proof.invest.amount1(),
            39995000000,
            "after disinvest:proof quantity error"
        );
        assertEq(
            _proof.invest.amount0(),
            0,
            "after disinvest:proof contruct error"
        );
        market.disinvestProof(normalproof, 10000 * 10 ** 6, address(0));
        snapLastCall("disinvest_other_nativeth_valuegood_second");

        market.disinvestProof(normalproof, 10000 * 10 ** 6, address(0));
        snapLastCall("disinvest_other_nativeth_valuegood_three");
        vm.stopPrank();
    }
}
