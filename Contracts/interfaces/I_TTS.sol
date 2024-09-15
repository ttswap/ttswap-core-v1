// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {S_ProofKey} from "../libraries/L_Struct.sol";
import {L_Proof} from "../libraries/L_Proof.sol";
import {T_BalanceUINT256} from "../libraries/L_BalanceUINT256.sol";
import {IERC721Permit} from "./IERC721Permit.sol";

/// @title Investment Proof Interface
/// @notice Contains a series of interfaces for goods
interface I_TTS {
    /// @notice Emitted when a referral is added
    /// @param users The address of the user
    /// @param referal The address of the referrer
    event e_addreferal(address users, address referal);

    /// @notice Emitted when environment variables are set
    /// @param normalgoodid The ID of the normal good
    /// @param valuegoodid The ID of the value good
    /// @param marketcontract The address of the market contract
    event e_setenv(
        uint256 normalgoodid,
        uint256 valuegoodid,
        address marketcontract
    );

    /// @notice Emitted when a DAO admin is set
    /// @param recipent The address of the new DAO admin
    event e_setdaoadmin(address recipent);

    /// @notice Emitted when authorizations are added
    /// @param auths The address being authorized
    /// @param priv The privilege level being granted
    event e_addauths(address auths, uint256 priv);

    /// @notice Emitted when authorizations are removed
    /// @param auths The address being deauthorized
    event e_rmauths(address auths);

    /// @notice Emitted when minting is added
    /// @param recipent The address receiving the minted tokens
    /// @param leftamount The remaining amount to be minted
    /// @param metric The metric used for minting
    /// @param chips The number of chips
    /// @param index The index of the minting operation
    event e_addmint(
        address recipent,
        uint256 leftamount,
        uint8 metric,
        uint8 chips,
        uint8 index
    );

    /// @notice Emitted when minting is burned
    /// @param index The index of the minting operation being burned
    event e_burnmint(uint8 index);

    /// @notice Emitted when DAO minting occurs
    /// @param mintamount The amount being minted
    /// @param index The index of the minting operation
    event e_daomint(uint256 mintamount, uint8 index);

    /// @notice Emitted during a public sale
    /// @param usdtamount The amount of USDT involved
    /// @param ttsamount The amount of TTS involved
    event e_publicsell(uint256 usdtamount, uint256 ttsamount);

    /// @notice Emitted when chain stake is synchronized
    /// @param chain The chain ID
    /// @param poolvalue The value of the pool
    /// @param proolcontruct The pool construct value
    /// @param poolasset The pool asset value
    event e_synchainstake(
        uint256 chain,
        uint256 poolvalue,
        uint256 proolcontruct,
        uint256 poolasset
    );

    /// @notice Emitted when staking occurs
    /// @param stakeid The ID of the stake
    /// @param marketcontract The address of the market contract
    /// @param proofid The ID of the proof
    /// @param stakevalue The value being staked
    /// @param stakecontruct The stake construct value
    event e_stake(
        uint256 stakeid,
        address marketcontract,
        uint256 proofid,
        uint256 stakevalue,
        uint256 stakecontruct
    );

    /// @notice Emitted when unstaking occurs
    /// @param recipent The address receiving the unstaked tokens
    /// @param proofvalue The proof value
    /// @param unstakestate The state after unstaking
    /// @param stakestate The state of the stake
    event e_unstake(
        address recipent,
        uint128 proofvalue,
        T_BalanceUINT256 unstakestate,
        T_BalanceUINT256 stakestate
    );
    /// @notice Emitted when the pool state is updated
    /// @param poolstate The new state of the pool
    /// @param stakestate The new state of the stake
    event e_updatepool(uint256 poolstate, uint256 stakestate);

    /// @notice Get the referral address for a customer
    /// @param _customer The address of the customer
    /// @return The address of the referrer
    function getreferal(address _customer) external view returns (address);

    /// @notice Add a referral relationship
    /// @param user The address of the user being referred
    /// @param referal The address of the referrer
    function addreferal(address user, address referal) external;

    /// @notice Stake tokens
    /// @param staker The address of the staker
    /// @param proofvalue The proof value for the stake
    /// @return contruct The construct value after staking
    function stake(
        address staker,
        uint128 proofvalue
    ) external returns (uint128 contruct);

    /// @notice Unstake tokens
    /// @param staker The address of the staker
    /// @param proofvalue The proof value for unstaking
    function unstake(address staker, uint128 proofvalue) external;

    /// @notice Check if an address is authorized
    /// @param recipent The address to check
    /// @return The authorization level (0 if not authorized)
    function isauths(address recipent) external view returns (uint256);

    /// @notice Get the DAO admin and referral for a customer
    /// @param _customer The address of the customer
    /// @return dba_admin The address of the DAO admin
    /// @return referal The address of the referrer
    function getreferalanddaoamdin(
        address _customer
    ) external view returns (address dba_admin, address referal);
}
