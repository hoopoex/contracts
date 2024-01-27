// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '@solidstate/contracts/access/ownable/OwnableInternal.sol';
import { Modifiers } from "../libraries/Modifiers.sol";
import { LibStake } from "../libraries/LibStake.sol";

contract SettingStake is Modifiers, OwnableInternal {

    function setStakePoolActive(
        bool _status
    ) 
        external 
        onlyOwner 
    {
        LibStake.layout().stakePool.isActive = _status;
    }

    function setToken0(
        address _contract
    ) 
        external 
        onlyOwner 
        isValidContract(_contract) 
    {
        LibStake.layout().stakePool.token0 = _contract;
    }

    function setToken1(
        address _contract
    ) 
        external 
        onlyOwner 
        isValidContract(_contract) 
    {
        LibStake.layout().stakePool.token1 = _contract;
    }

}