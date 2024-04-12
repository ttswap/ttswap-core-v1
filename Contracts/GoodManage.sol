// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import "./RefererManage.sol";
import "./interfaces/I_Good.sol";

import {L_GoodConfigLibrary} from "./libraries/L_GoodConfig.sol";
import {L_Good} from "./libraries/L_Good.sol";

import {L_MarketConfigLibrary} from "./libraries/L_MarketConfig.sol";
import {L_CurrencyLibrary} from "./libraries/L_Currency.sol";
import {S_GoodKey} from "./libraries/L_Struct.sol";
import {T_BalanceUINT256, L_BalanceUINT256Library, toBalanceUINT256, addsub, subadd} from "./libraries/L_BalanceUINT256.sol";

abstract contract GoodManage is I_Good, RefererManage {
    using L_CurrencyLibrary for address;
    using L_GoodConfigLibrary for uint256;
    using L_MarketConfigLibrary for uint256;
    using L_Good for L_Good.S_GoodState;

    uint256 public marketconfig;
    uint256 public goodnum;
    mapping(uint256 => L_Good.S_GoodState) public goods;
    mapping(address => uint256[]) public ownergoods;
    mapping(bytes32 => uint256) public goodseq;
    uint256 internal locked;
    address public marketcreator;
    mapping(address => uint256) public banlist;

    constructor(address _marketcreator, uint256 _marketconfig) {
        marketcreator = _marketcreator;
        marketconfig = _marketconfig;
        // emit e_initMarket(_marketcreator, _marketconfig);
    }

    modifier onlyMarketCreator() {
        require(msg.sender == marketcreator, "G02");
        _;
    }

    modifier noReentrant() {
        require(locked == 0, "G01");
        locked = 1;
        _;
        locked = 0;
    }

    modifier noblacklist() {
        require(banlist[msg.sender] == 0);
        _;
    }

    function addbanlist(
        address _user
    ) external override onlyMarketCreator returns (bool) {
        banlist[_user] = 1;
        return true;
    }

    function removebanlist(
        address _user
    ) external override onlyMarketCreator returns (bool) {
        banlist[_user] = 0;
        return true;
    }

    function setMarketConfig(
        uint256 _marketconfig
    ) external override onlyMarketCreator returns (bool) {
        require(_marketconfig.checkAllocate(), "G03");
        marketconfig = _marketconfig;
        return true;
    }

    function getGoodIdByAddress(
        address _owner
    ) external view returns (uint256[] memory) {
        return ownergoods[_owner];
    }

    function getGoodState(
        uint256 _goodid
    ) external view override returns (L_Good.S_GoodTmpState memory good_) {
        good_.currentState = goods[_goodid].currentState;
        good_.investState = goods[_goodid].investState;
        good_.feeQunitityState = goods[_goodid].feeQunitityState;
        good_.goodConfig = goods[_goodid].goodConfig;
        good_.owner = goods[_goodid].owner;
        good_.erc20address = goods[_goodid].erc20address;
    }

    function getGoodsFee(
        uint256 _goodid,
        address user
    ) external view returns (uint256) {
        return goods[_goodid].fees[user];
    }

    function updateGoodConfig(
        uint256 _goodid,
        uint256 _goodConfig
    ) external override returns (bool) {
        require(msg.sender == goods[_goodid].owner, "G04");
        goods[_goodid].updateGoodConfig(_goodConfig);

        return true;
    }

    function updatetoValueGood(
        uint256 _goodid
    ) external override onlyMarketCreator returns (bool) {
        goods[_goodid].updateToValueGood();
        emit e_updateGood(_goodid, 1);
        return true;
    }

    function updatetoNormalGood(
        uint256 _goodid
    ) external override onlyMarketCreator returns (bool) {
        goods[_goodid].updateToNormalGood();
        emit e_updateGood(_goodid, 0);
        return true;
    }

    function payGood(
        uint256 _goodid,
        uint256 _payquanity,
        address _recipent
    ) external returns (bool) {
        goods[_goodid].erc20address.transfer(_recipent, _payquanity);
        return true;
    }

    function changeOwner(
        uint256 _goodid,
        address _to
    ) external override returns (bool) {
        require(
            msg.sender == goods[_goodid].owner || msg.sender == marketcreator,
            "G05"
        );
        emit e_changeOwner(_goodid, goods[_goodid].owner, _to);
        goods[_goodid].owner = _to;
        ownergoods[_to].push(_goodid);
        return true;
    }

    function collectProtocolFee(
        uint256 _goodid
    ) external payable override noblacklist returns (uint256) {
        uint256 fee = goods[_goodid].fees[msg.sender];
        require(fee > 0, "G06");
        goods[_goodid].fees[msg.sender] = 0;
        uint256 protocol = marketconfig.getPlatFee256(fee);
        emit e_collectProtocolFee(_goodid, msg.sender, protocol);
        goods[_goodid].fees[marketcreator] += protocol;
        goods[_goodid].erc20address.transfer(msg.sender, fee - protocol);
        return fee;
    }
}
