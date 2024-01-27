// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { TSwapPool,TSwapPoolUser,TSwapPoolPendingRequests,TPendingRequests,TUserSwapTransactionsData } from "../libraries/Structs.sol";
import  "@solidstate/contracts/security/reentrancy_guard/ReentrancyGuard.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import '@solidstate/contracts/access/ownable/OwnableInternal.sol';
import { LibMembership } from "../libraries/LibMembership.sol";
import { Modifiers } from "../libraries/Modifiers.sol";
import { LibSwap } from "../libraries/LibSwap.sol";
import { IHOOPX } from "../interfaces/IHOOPX.sol";
import "../libraries/Errors.sol";

contract Swap is Modifiers, ReentrancyGuard, OwnableInternal{
    using Math for uint256;


    // input(token) => output(usdt) => 6 decimals;
    function calculatePair0(
        uint256 _amount
    )
        public
        view
        returns(uint256 result)
    {

        (uint256 subFeeAmount) = calculateFee(_amount);
        uint256 realAmount = _amount - subFeeAmount;
        result = realAmount.mulDiv(LibSwap.layout().swapPool.lastValuation,IHOOPX(LibSwap.layout().swapPool.pairToken0).decimals());
    }

    // input(usdt) => output(token) => 18 decimals;
    function calculatePair1(
        uint256 _amount
    )
        public 
        view 
        returns(uint256 result)
    {
        (uint256 subFeeAmount) = calculateFee(_amount);
        uint256 realAmount = _amount - subFeeAmount;
        result = realAmount.mulDiv(IHOOPX(LibSwap.layout().swapPool.pairToken0).decimals(),LibSwap.layout().swapPool.lastValuation);
    }
    
    function calculateFee(
        uint256 _amount
    )
        public
        view
        returns(uint256 feeAmount)
    {
        if (LibSwap.layout().swapPool.swapFee > 0){
            feeAmount = _amount.mulDiv(LibSwap.layout().swapPool.swapFee,100);
        }
    }

    // .... 
}