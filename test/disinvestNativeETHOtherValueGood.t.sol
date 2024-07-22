// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MyToken} from "../src/ERC20.sol";
import "../Contracts/MarketManager.sol";
import {BaseSetup} from "./BaseSetup.t.sol";
import {S_GoodKey, S_ProofKey} from "../Contracts/libraries/L_Struct.sol";
import {L_ProofIdLibrary, L_Proof} from "../Contracts/libraries/L_Proof.sol";
import {L_GoodIdLibrary, L_Good} from "../Contracts/libraries/L_Good.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "../Contracts/libraries/L_BalanceUINT256.sol";

import {L_GoodConfigLibrary} from "../Contracts/libraries/L_GoodConfig.sol";
import {L_MarketConfigLibrary} from "../Contracts/libraries/L_MarketConfig.sol";

contract disinvestNativeETHOwnValueGood is BaseSetup {
    using L_MarketConfigLibrary for uint256;
    using L_GoodConfigLibrary for uint256;
    using L_GoodIdLibrary for S_GoodKey;
    using L_ProofIdLibrary for S_ProofKey;

    uint256 metagood;
    uint256 normalgoodusdt;
    uint256 normalgoodeth;

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
            address(0),
            toBalanceUINT256(50000 * 10 ** 6, 50000 * 10 ** 6),
            _goodconfig
        );
        metagood = S_GoodKey(marketcreator, address(0)).toId();
        vm.stopPrank();
    }

    function investOtherERC20ValueGood() public {
        vm.startPrank(users[2]);
        deal(users[2], 1000000 * 10 ** 6);
        market.investGood{value: 50000000000}(metagood, 0, 50000 * 10 ** 6);
        vm.stopPrank();
    }

    function testDistinvestProof() public {
        vm.startPrank(users[2]);
        uint256 normalproof;
        normalproof = market.proofmapping(
            S_ProofKey(users[2], metagood, 0).toId()
        );
        L_Proof.S_ProofState memory _proof = market.getProofState(normalproof);
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

        L_Good.S_GoodTmpState memory good_ = market.getGoodState(metagood);
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
            good_.feeQunitityState.amount0(),
            5000000,
            "before disinvest erc20 good:metagood feeQunitityState amount0 error"
        );
        assertEq(
            good_.feeQunitityState.amount1(),
            0,
            "before disinvest erc20 good:metagood feeQunitityState amount1 error"
        );

        market.disinvestProof(
            normalproof,
            10000 * 10 ** 6,
            address(0),
            address(0)
        );
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
            good_.feeQunitityState.amount0(),
            7499975,
            "after disinvest erc20 good:metagood feeQunitityState amount0 error"
        );
        assertEq(
            good_.feeQunitityState.amount1(),
            0,
            "after disinvest erc20 good:metagood feeQunitityState amount1 error"
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
        market.disinvestProof(
            normalproof,
            10000 * 10 ** 6,
            address(0),
            address(0)
        );
        snapLastCall("disinvest_other_nativeth_valuegood_second");

        market.disinvestProof(
            normalproof,
            10000 * 10 ** 6,
            address(0),
            address(0)
        );
        snapLastCall("disinvest_other_nativeth_valuegood_three");
        vm.stopPrank();
    }
}
