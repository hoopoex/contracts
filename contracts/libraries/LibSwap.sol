// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { TSwapPool,TSwapPoolUser,TSwapPoolPendingRequests,TUserSwapTransactions } from "./Structs.sol";

library LibSwap{
    bytes32 internal constant STORAGE_SLOT = keccak256('storage.swap.hoopx.ai');

    struct Layout {
        mapping(address => TSwapPoolUser) swapPoolUser;
        mapping(address => TSwapPoolPendingRequests) swapPoolPendingRequests;
        mapping(address => TUserSwapTransactions) UserSwapTransactionsHistory;
        TSwapPool swapPool;
    }


    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}