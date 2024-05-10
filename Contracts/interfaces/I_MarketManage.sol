// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./I_Proof.sol";
import "./I_Good.sol";

import {S_GoodKey, S_ProofKey, S_Ralate} from "../libraries/L_Struct.sol";
import {L_Good} from "../libraries/L_Good.sol";

import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd} from "../libraries/L_BalanceUINT256.sol";

/// @title 市场管理接口 market manage interface
/// @notice 市场管理接口 market manage interface
interface I_MarketManage is I_Good, I_Proof {
    /// @notice emit when customer buy good :当用户购买商品时触发
    /// @param sellgood good's id  商品的商品ID
    /// @param forgood   initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.
    /// @param fromer   seller or buyer address 卖家或买家地址
    /// @param swapvalue   trade value  交易价值
    /// @param sellgoodstate   the sellgood status amount0:fee,amount1:quantity 使用商品的交易结果 amount0:手续费,amount1:数量
    /// @param forgoodstate   the forgood status amount0:fee,amount1:quantity 获得商品的交易结果amount0:手续费,amount1:数量
    event e_buyGood(
        uint256 indexed sellgood,
        uint256 indexed forgood,
        address fromer,
        uint128 swapvalue,
        T_BalanceUINT256 sellgoodstate,
        T_BalanceUINT256 forgoodstate
    );
    /// @notice emit when customer buy good pay to the seller :当用户购买商品支付给卖家时触发
    /// @param buygood good's id  商品的商品ID
    /// @param usegood   initial good,amount0:value,amount1:quantity 初始化的商品的参数,前128位为价值,后128位为数量.
    /// @param fromer   seller or buyer address 卖家或买家地址
    /// @param receipt   receipt  收款方
    /// @param swapvalue   trade value  交易价值
    /// @param buygoodstate   the buygood status amount0:fee,amount1:quantity 使用商品的交易结果 amount0:手续费,amount1:数量
    /// @param usegoodstate   the usegood status amount0:fee,amount1:quantity 获得商品的交易结果amount0:手续费,amount1:数量
    event e_buyGoodForPay(
        uint256 indexed buygood,
        uint256 indexed usegood,
        address fromer,
        address receipt,
        uint128 swapvalue,
        T_BalanceUINT256 buygoodstate,
        T_BalanceUINT256 usegoodstate
    );
    event e_proof(uint256 indexed);

    error err_total();

    /// @notice initial market's first good~初始化市场中第一个商品
    /// @param _erc20address good's contract address~商品合约地址
    /// @param _initial   initial good.amount0:value,amount1:quantity~初始化的商品的参数,前128位为价值,后128位为数量.
    /// @param _goodconfig   good config (detail config according to the whitepaper)~商品配置(详细配置参见技术白皮书)
    /// @return metagood_no_  good_no~商品编号
    /// @return proof_no_  proof_no~投资证明编号
    function initMetaGood(
        address _erc20address,
        T_BalanceUINT256 _initial,
        uint256 _goodconfig
    ) external returns (uint256 metagood_no_, uint256 proof_no_);

    /// @notice initial the normal good~初始化市场中的普通商品
    /// @param _valuegood   valuegood_no:measure the normal good value~价值商品编号:衡量普通商品价值
    /// @param _initial     initial good.amount0:value,amount1:quantity~初始化的商品的参数,前128位为价值,后128位为数量.
    /// @param _erc20address  good's contract address~商品合约地址
    /// @param _goodConfig   good config (detail config according to the whitepaper)~商品配置(详细配置参见技术白皮书)
    /// @param _gater   gater address~门户地址
    /// @return goodNo_ the_normal_good_No ~普通物品的编号
    /// @return proofNo_ the_proof_of_initial_good~初始化普通物品的投资证明
    function initNormalGood(
        uint256 _valuegood,
        T_BalanceUINT256 _initial,
        address _erc20address,
        uint256 _goodConfig,
        address _gater
    ) external returns (uint256 goodNo_, uint256 proofNo_);

    /// @notice sell _swapQuantity units of good1 to buy good2~用户出售_swapQuanitity个_goodid1去购买 _goodid2
    /// @dev 如果购买商品1而出售商品2,开发者需求折算成使用商品2购买商品1
    /// @param _goodid1 good1's No~商品1的编号
    /// @param _goodid2 good2's No~商品2的编号
    /// @param _swapQuanitity good1's quantity~商品1的数量
    /// @param _limitprice trade price's limit~交易价格限制
    /// @param _istotal is need trade all~是否允许全部成交
    /// @param _gater   gater address~门户地址
    /// @return goodid2Quanitity_  实际情况
    /// @return goodid2FeeQuanitity_ 实际情况
    function buyGood(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitprice,
        bool _istotal,
        address _gater
    )
        external
        returns (uint128 goodid2Quanitity_, uint128 goodid2FeeQuanitity_);

    /// @notice buy _swapQuantity units of good to sell good2 and send good1 to recipent~用户购买_swapQuanitity个_goodid1去出售 _goodid2并且把商品转给RECIPENT
    /// @param _goodid1 good1's No~商品1的编号
    /// @param _goodid2 good2's No~商品2的编号
    /// @param _swapQuanitity buy good2's quantity~购买商品2的数量
    /// @param _limitprice trade price's limit~交易价格限制
    /// @param _recipent recipent~收款人
    /// @param _gater   gater address~门户地址
    /// @return goodid1Quanitity_  good1 actual quantity~商品1实际数量
    /// @return goodid1FeeQuanitity_ good1 actual fee~商品1实际手续费
    function buyGoodForPay(
        uint256 _goodid1,
        uint256 _goodid2,
        uint128 _swapQuanitity,
        uint256 _limitprice,
        address _recipent,
        address _gater
    )
        external
        returns (uint128 goodid1Quanitity_, uint128 goodid1FeeQuanitity_);

    /// @notice invest value good~投资价值商品
    /// @param _goodid   value good No~价值商品的编号
    /// @param _goodQuanitity  value good quanity~投资价值商品的数量
    /// @param _gater   gater address~门户地址
    /// @return valueInvest_
    ///  valueInvest_.actualFeeQuantity //actutal fee quantity 实际手续费
    ///  valueInvest_.contructFeeQuantity //contrunct fee quantity 构建手续费
    ///  valueInvest_.actualinvestValue //value of invest 实际投资价值
    ///  valueInvest_.actualinvestQuantity //the quantity of invest 实际投资数量
    /// @return valueProofno_ 证明编号
    function investValueGood(
        uint256 _goodid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        returns (
            L_Good.S_GoodInvestReturn calldata valueInvest_,
            uint256 valueProofno_
        );

    /// @notice disinvest value good~撤资价值商品
    /// @param _goodid   value good No~价值商品的ID
    /// @param _goodQuanitity  the quantity of value good to disinvest~取消价值商品的数量
    /// @param _gater   gater~门户
    /// @return disinvestResult_
    /// disinvestResult_.profit; // profit of stake 投资收入
    /// disinvestResult_.actual_fee; // actual fee 实际手续费
    /// disinvestResult_.actualDisinvestValue; // disinvest value  撤资价值
    /// disinvestResult_.actualDisinvestQuantity; //disinvest quantity 撤资数量
    /// @return valueProofno_ the proof of value proof~投资证明的编号
    function disinvestValueGood(
        uint256 _goodid,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        returns (
            L_Good.S_GoodDisinvestReturn memory disinvestResult_,
            uint256 valueProofno_
        );

    /// @notice invest normal good~投资普通商品
    /// @param _togood  normal good No~普通商品的编号
    /// @param _valuegood value good No~价值商品的编号
    /// @param _quanitity   invest normal good quantity~投资普通商品的数量
    /// @param _gater   gater address~门户
    /// @return normalInvest_
    ///  normalInvest_.actualFeeQuantity //actutal fee quantity 实际手续费
    ///  normalInvest_.contructFeeQuantity //contrunct fee quantity 构建手续费
    ///  normalInvest_.actualinvestValue //value of invest 实际投资价值
    ///  normalInvest_.actualinvestQuantity //the quantity of invest 实际投资数量
    /// @return valueInvest_
    ///  valueInvest_.actualFeeQuantity //actutal fee quantity 实际手续费
    ///  valueInvest_.contructFeeQuantity //contrunct fee quantity 构建手续费
    ///  valueInvest_.actualinvestValue //value of invest 实际投资价值
    ///  valueInvest_.actualinvestQuantity //the quantity of invest 实际投资数量
    /// @return normalProofno_  证明编号
    function investNormalGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _quanitity,
        address _gater
    )
        external
        returns (
            L_Good.S_GoodInvestReturn memory normalInvest_,
            L_Good.S_GoodInvestReturn memory valueInvest_,
            uint256 normalProofno_
        );

    /// @notice disinvest normal good~撤资普通商品
    /// @param _togood   normal good No~普通商品编号
    /// @param _valuegood   value Good No~价值商品编号
    /// @param _goodQuanitity  disinvest quantity~取消普通商品投资数量
    /// @param _gater   gater address~门户
    /// @return disinvestResult1_ 普通商品结果
    /// disinvestResult1_.profit; // profit of stake 投资收入
    /// disinvestResult1_.actual_fee; // actual fee 实际手续费
    /// disinvestResult1_.actualDisinvestValue; // disinvest value  撤资价值
    /// disinvestResult1_.actualDisinvestQuantity; //disinvest quantity 撤资数量
    /// @return disinvestResult2_ 价值商品结果
    /// disinvestResult2_.profit; // profit of stake 投资收入
    /// disinvestResult2_.actual_fee; // actual fee 实际手续费
    /// disinvestResult2_.actualDisinvestValue; // disinvest value  撤资价值
    /// disinvestResult2_.actualDisinvestQuantity; //disinvest quantity 撤资数量
    /// @return normalProofno_  证明编号
    function disinvestNormalGood(
        uint256 _togood,
        uint256 _valuegood,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        returns (
            L_Good.S_GoodDisinvestReturn memory disinvestResult1_,
            L_Good.S_GoodDisinvestReturn memory disinvestResult2_,
            uint256 normalProofno_
        );

    /// @notice disinvest value good~撤资价值商品
    /// @param _valueproofid   the invest proof No of value good ~价值投资证明的编号编号
    /// @param _goodQuanitity  the quantity of value good to disinvest~取消价值商品的数量
    /// @param _gater   gater~门户
    /// @return disinvestResult_
    /// disinvestResult_.profit; // profit of stake 投资收入
    /// disinvestResult_.actual_fee; // actual fee 实际手续费
    /// disinvestResult_.actualDisinvestValue; // disinvest value  撤资价值
    /// disinvestResult_.actualDisinvestQuantity; //disinvest quantity 撤资数量
    function disinvestValueProof(
        uint256 _valueproofid,
        uint128 _goodQuanitity,
        address _gater
    ) external returns (L_Good.S_GoodDisinvestReturn memory disinvestResult_);

    /// @notice disinvest normal good~撤资普通商品
    /// @param _normalProof   the invest proof No of normal good ~普通投资证明的编号编号
    /// @param _goodQuanitity  disinvest quantity~取消普通商品投资数量
    /// @param _gater   gater address~门户
    /// @return disinvestResult1_ 普通商品结果
    /// disinvestResult1_.profit; // profit of stake 投资收入
    /// disinvestResult1_.actual_fee; // actual fee 实际手续费
    /// disinvestResult1_.actualDisinvestValue; // disinvest value  撤资价值
    /// disinvestResult1_.actualDisinvestQuantity; //disinvest quantity 撤资数量
    /// @return disinvestResult2_ 价值商品结果
    /// disinvestResult2_.profit; // profit of stake 投资收入
    /// disinvestResult2_.actual_fee; // actual fee 实际手续费
    /// disinvestResult2_.actualDisinvestValue; // disinvest value  撤资价值
    /// disinvestResult2_.actualDisinvestQuantity; //disinvest quantity 撤资数量
    function disinvestNormalProof(
        uint256 _normalProof,
        uint128 _goodQuanitity,
        address _gater
    )
        external
        returns (
            L_Good.S_GoodDisinvestReturn memory disinvestResult1_,
            L_Good.S_GoodDisinvestReturn memory disinvestResult2_
        );

    /// @notice collect the profit of normal proof~提取普通投资证明的收益
    /// @param _normalProofid   the proof No of invest normal good~普通投资证明编号
    /// @return profit_   amount0 普通商品的投资收益 amount1价值商品的投资收益
    function collectNormalProofFee(
        uint256 _normalProofid
    ) external returns (T_BalanceUINT256 profit_);

    /// @notice collect the profit of normal proof~提取普通投资证明的收益
    /// @param _valueProofid   the proof No of invest value good~价值投资证明编号
    /// @return profit_  profit of invest value good~价值商品的投资收益
    function collectValueProofFee(
        uint256 _valueProofid
    ) external returns (uint128 profit_);
}
