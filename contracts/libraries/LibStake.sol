// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { TChangeCountIndex,TUser,TStakePoolInfo,TUserStakeTransactions } from "./Structs.sol";

library LibStake{
    bytes32 internal constant STORAGE_SLOT = keccak256('storage.stake.hoopx.ai');
    uint256 internal constant DIFFERENCE_AMOUNT = 1 ether;

    struct Layout {
        mapping(address => TUser) user;
        mapping(uint256 => TChangeCountIndex) chc;
        mapping(address => TUserStakeTransactions) userStakeTransactionsHistory;

        TStakePoolInfo stakePool;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

}