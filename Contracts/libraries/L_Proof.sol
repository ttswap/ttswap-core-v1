// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.24;

import {S_ProofState, S_ProofKey} from "./L_Struct.sol";
import {T_BalanceUINT256, toBalanceUINT256} from "./L_BalanceUINT256.sol";
import {FullMath} from "../libraries/FullMath.sol";

library L_Proof {
    function updateValueInvest(
        S_ProofState storage _self,
        uint256 _currenctgood,
        T_BalanceUINT256 _state,
        T_BalanceUINT256 _invest
    ) internal {
        if (_self.invest.amount1() == 0) {
            _self.owner = msg.sender;
            _self.currentgood = _currenctgood;
            _self.valuegood = 0;
        }
        _self.invest = _self.invest + _invest;
        _self.state = _self.state + _state;
    }

    function updateNormalInvest(
        S_ProofState storage _self,
        uint256 _currenctgood,
        uint256 _valuegood,
        T_BalanceUINT256 _state,
        T_BalanceUINT256 _invest,
        T_BalanceUINT256 _valueinvest
    ) internal {
        if (_self.invest.amount1() == 0) {
            _self.owner = msg.sender;
            _self.currentgood = _currenctgood;
            _self.valuegood = _valuegood;
        }
        _self.state = _self.state + _state;
        _self.invest = _self.invest + _invest;
        _self.valueinvest = _self.valueinvest + _valueinvest;
    }

    function burnValueProofSome(
        S_ProofState storage _self,
        uint128 _quantity
    ) internal {
        T_BalanceUINT256 burnResult_ = toBalanceUINT256(
            FullMath.mulDiv128(
                _self.state.amount0(),
                _quantity,
                _self.invest.amount1()
            ),
            _self.invest.getamount0fromamount1(_quantity)
        );
        _self.invest =
            _self.invest -
            toBalanceUINT256(burnResult_.amount1(), _quantity);

        _self.state = _self.state - toBalanceUINT256(burnResult_.amount0(), 0);
    }

    function burnNormalProofSome(
        S_ProofState storage _self,
        uint128 _quantity
    ) internal {
        T_BalanceUINT256 burnResult1_ = toBalanceUINT256(
            FullMath.mulDiv128(
                _self.state.amount0(),
                _quantity,
                _self.invest.amount1()
            ),
            _self.invest.getamount0fromamount1(_quantity)
        );

        T_BalanceUINT256 burnResult2_ = toBalanceUINT256(
            FullMath.mulDiv128(
                _self.valueinvest.amount0(),
                _quantity,
                _self.invest.amount1()
            ),
            FullMath.mulDiv128(
                _self.valueinvest.amount1(),
                _quantity,
                _self.invest.amount1()
            )
        );
        _self.invest =
            _self.invest -
            toBalanceUINT256(burnResult1_.amount1(), _quantity);
        _self.valueinvest = _self.valueinvest - burnResult2_;
        _self.state = _self.state - toBalanceUINT256(burnResult1_.amount0(), 0);
    }
}

library L_ProofIdLibrary {
    function toId(S_ProofKey memory proofKey) internal pure returns (bytes32) {
        return keccak256(abi.encode(proofKey));
    }
}
