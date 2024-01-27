// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { TUser,TUserStakeTransactionsData,TUserStakeTransactions,TStakePoolInfo,TChangeCountIndex } from "../libraries/Structs.sol";
import  "@solidstate/contracts/security/reentrancy_guard/ReentrancyGuard.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import '@solidstate/contracts/access/ownable/OwnableInternal.sol';
import { LibMembership } from "../libraries/LibMembership.sol";
import { Modifiers } from "../libraries/Modifiers.sol";
import { LibStake } from "../libraries/LibStake.sol";
import { IHOOPNFT } from "../interfaces/IHOOPNFT.sol";
import { IHOOPX } from "../interfaces/IHOOPX.sol";
import "../libraries/Errors.sol";

contract Stake is Modifiers, ReentrancyGuard, OwnableInternal{
    using Math for uint256;

    event HANDLE_STAKE_PROCESS(address indexed, address indexed, uint256);
    event HANDLE_UNSTAKE_PROCESS(address indexed, uint256);
    event HANDLE_CLAIM_PROCESS(address indexed, address indexed, uint256);
    event HANDLE_ADD_LIQUIDITY(address indexed,address indexed,uint256);

    function stake(
        uint256 _tokenID
    ) 
        external 
        nonReentrant 
        whenNotContract(msg.sender) 
    {
        LibStake.Layout storage ss = LibStake.layout();
        LibMembership.Layout storage ms = LibMembership.layout();
        uint256 tokenID = _tokenID;
        address user = msg.sender;
        address nftContract = ms.membership.nftContract;

        if(ms.blacklist[user]){ revert Address_Is_Blacklist(user); }
        if(ss.user[user].staker){ revert User_Already_Staked(); }
        if(!ss.stakePool.isActive){ revert Paused(); }
        if(!LibMembership.checkExistence(ms.membership.tokenIDs,tokenID)){ revert Invalid_Action(); }
        IHOOPNFT nft = IHOOPNFT(nftContract);
        if(nft.balanceOf(user, tokenID) == 0){ revert Insufficient_Balance(); }
        if(!nft.isApprovedForAll(user,address(this))){ revert Insufficient_Allowance(); }

        uint256 multipler = nft.getTokenInfo(tokenID).multiplier;

        ss.user[user] = TUser({
            staker                 : true,
            userStakedNFT          : tokenID,
            userChangeCountIndex   : 0,
            userTotalScore         : multipler,
            userEarnedToken0Amount : ss.user[user].userEarnedToken0Amount,
            userEarnedToken1Amount : ss.user[user].userEarnedToken1Amount
        });

        ss.userStakeTransactionsHistory[user].stakeTransactions.push(TUserStakeTransactionsData({
            identifierStakeTransactions    : "Staked",
            stakeTransactionsTime          : block.timestamp,
            stakeTransactionsValue         : tokenID,
            stakeTransactionsValueForHoopX : tokenID
        }));

        ms.isStaker[user] = true;

        _findAndDeleteStakeData(user);

        uint256 nftPrice = ms.nft[nftContract][tokenID].price;
        if(tokenID > ms.membership.acceptableTokenIdForHoopX) {
            unchecked {
                ss.stakePool.totalLockedHOOPValue += nftPrice;
            }
        }else {
            unchecked {
                ss.stakePool.totalLockedHOOPXValue += nftPrice;
            }
        }
        unchecked {
            ss.stakePool.poolTotalScore += multipler;
            ss.stakePool.numberOfStakers += 1;
        }

        nft.safeTransferFrom(user,address(this),tokenID,1,"");

        _updateChc(user);

        emit HANDLE_STAKE_PROCESS(user,nftContract,block.timestamp);
    }

    function claimRewards(
    ) 
        external 
        nonReentrant 
        whenNotContract(msg.sender) 
    {
        if(LibMembership.layout().blacklist[msg.sender]){ revert Address_Is_Blacklist(msg.sender); }
        if(!LibStake.layout().user[msg.sender].staker){ revert User_Not_Staker(); }
        if(!LibStake.layout().stakePool.isActive){ revert Paused(); }

        _safeClaim(msg.sender);
        _updateChc(msg.sender);
    }

    function withdraw(
    ) 
        external 
        nonReentrant 
        whenNotContract(msg.sender) 
    {
        LibStake.Layout storage ss = LibStake.layout();
        LibMembership.Layout storage ms = LibMembership.layout();
        
        address user = msg.sender;
        address nftContract = ms.membership.nftContract;

        if(ms.blacklist[user]){ revert Address_Is_Blacklist(user); }
        if(!ss.user[user].staker){ revert User_Not_Staker(); }
        if(!ss.stakePool.isActive){ revert Paused(); }

        (uint256 token0Reward,uint256 token1Reward) = calculateRewards(user);
        if(token0Reward > 0 || token1Reward > 0) {
            _safeClaim(user);
        }
        IHOOPNFT nft = IHOOPNFT(nftContract);

        uint256 stakedTokenID = ss.user[user].userStakedNFT;
        uint256 nftPrice = ms.nft[nftContract][stakedTokenID].price;
        uint256 multipler = nft.getTokenInfo(stakedTokenID).multiplier;

        if(stakedTokenID > ms.membership.acceptableTokenIdForHoopX) {
            unchecked {
                ss.stakePool.totalLockedHOOPValue -= nftPrice;
            }
        }else {
            unchecked {
                ss.stakePool.totalLockedHOOPXValue -= nftPrice;
            }
        }
        unchecked {
            ss.stakePool.poolTotalScore -= multipler;
            ss.stakePool.numberOfStakers -= 1;
        }

        _updateChc(user);

        ss.user[user] = TUser({
            staker        : false,
            userStakedNFT : 0,
            userChangeCountIndex : 0,
            userTotalScore       : 0,
            userEarnedToken0Amount : ss.user[user].userEarnedToken0Amount,
            userEarnedToken1Amount : ss.user[user].userEarnedToken1Amount
        });
        ms.isStaker[user] = false;

        nft.safeTransferFrom(address(this),user,stakedTokenID,1,"");

        emit HANDLE_UNSTAKE_PROCESS(user,stakedTokenID);
    }

    function _safeClaim(
        address _address
    ) 
        private 
    {
        LibStake.Layout storage ss = LibStake.layout();
        address user = _address;
        (uint256 token0Reward,uint256 token1Reward) = calculateRewards(user);
        if(token0Reward == 0 && token1Reward == 0){ revert User_Not_Expired(); }

        if(token0Reward > 0){
            IHOOPX token = IHOOPX(ss.stakePool.token0);
            unchecked {
                ss.stakePool.poolTotalDistributedToken0 += token0Reward;
                ss.user[user].userEarnedToken0Amount += token0Reward;
            }
            if(token.balanceOf(address(this)) < token0Reward){ revert Insufficient_Balance(); }
            token.transfer(user,token0Reward);
            emit HANDLE_CLAIM_PROCESS(user,address(token),token0Reward);
        }
        if(token1Reward > 0){
            IHOOPX token = IHOOPX(ss.stakePool.token1);
            unchecked {
                ss.stakePool.poolTotalDistributedToken1 += token1Reward;
                ss.user[user].userEarnedToken1Amount += token1Reward;
            }
            if(token.balanceOf(address(this)) < token1Reward){ revert Insufficient_Balance(); }
            token.transfer(user,token1Reward);
            emit HANDLE_CLAIM_PROCESS(user,address(token),token1Reward);
        }

        ss.userStakeTransactionsHistory[user].stakeTransactions.push(TUserStakeTransactionsData({
            identifierStakeTransactions    : "Claimed",
            stakeTransactionsTime          : block.timestamp,
            stakeTransactionsValue         : token0Reward,
            stakeTransactionsValueForHoopX : token1Reward
        }));

        _findAndDeleteStakeData(user);
    }

    function _findAndDeleteStakeData(
        address _address
    ) 
        private 
    {
        TUserStakeTransactionsData[] storage transactions = LibStake.layout().userStakeTransactionsHistory[_address].stakeTransactions;

        if (transactions.length > 10) {
            delete transactions[0];
            for (uint256 i = 0; i < transactions.length - 1;) {
                transactions[i] = transactions[i + 1];
                unchecked{
                    i++;
                }
            }
            transactions.pop();
        }
    }

    function calculateRewards(
        address _user
    ) 
        public 
        view 
        returns(uint256,uint256) 
    {
        uint256 token0Reward = 0;
        uint256 token1Reward = 0;
        address user = _user;
        LibStake.Layout storage ss = LibStake.layout();

        if(ss.user[user].staker){
            uint256 userCCIndex = ss.user[user].userChangeCountIndex;
            uint256 poolCCIndex = ss.stakePool.lastCHCIndex;
            uint256 blockTime = block.timestamp;
            uint256 diff = LibStake.DIFFERENCE_AMOUNT;
            for(uint256 i = userCCIndex; i <= poolCCIndex;) {
                uint256 userWeight = ss.user[user].userTotalScore.mulDiv(diff,ss.chc[i].chcTotalPoolScore);
                uint256 reward0 = ss.chc[i].chcToken0RewardPerTime.mulDiv(userWeight,diff);
                uint256 reward1 = ss.chc[i].chcToken1RewardPerTime.mulDiv(userWeight,diff);

                if(ss.chc[i].canWinPrizesToken0) {
                    uint256 userActiveTimeForToken0 = 0;

                    if(i == poolCCIndex && blockTime > ss.chc[i].chcToken0DistributionEndTime) {
                        unchecked {
                            userActiveTimeForToken0 = ss.chc[i].chcToken0DistributionEndTime - ss.chc[i].chcStartTime;
                        }
                    }else {
                        if(i == poolCCIndex) {
                            unchecked {
                                userActiveTimeForToken0 = blockTime - ss.chc[i].chcStartTime;
                            }
                        }else {
                            unchecked {
                                userActiveTimeForToken0 = ss.chc[i].chcEndTime - ss.chc[i].chcStartTime;
                            }
                        }
                    }
                    unchecked {
                        token0Reward = token0Reward + (reward0 * userActiveTimeForToken0);
                    }
                }

                if(ss.chc[i].canWinPrizesToken1) {
                    uint256 userActiveTimeForToken1 = 0;

                    if(i == poolCCIndex && blockTime > ss.chc[i].chcToken1DistributionEndTime) {
                        unchecked {
                            userActiveTimeForToken1 = ss.chc[i].chcToken1DistributionEndTime - ss.chc[i].chcStartTime;
                        }
                    }else {
                        if(i == poolCCIndex) {
                            unchecked {
                                userActiveTimeForToken1 = blockTime - ss.chc[i].chcStartTime;
                            }
                        }else {
                            unchecked {
                                userActiveTimeForToken1 = ss.chc[i].chcEndTime - ss.chc[i].chcStartTime;
                            }
                        }
                    }
                    unchecked {
                        token1Reward = token1Reward + (reward1 * userActiveTimeForToken1);
                    }
                }
                unchecked {
                    i++;
                }
            }
        }
        return (token0Reward, token1Reward);
    }

    function _updateChc(
        address _address
    )
        private
    {
        LibStake.Layout storage ss = LibStake.layout();

        uint256 blockTime                      = block.timestamp;
        uint256 currentCHCIndex                = ss.stakePool.lastCHCIndex;
        ss.chc[currentCHCIndex].chcEndTime     = blockTime;
        uint256 nextCHCIndex = 0;

        unchecked {
            nextCHCIndex = currentCHCIndex + 1;
        }

        ss.stakePool.lastCHCIndex              = nextCHCIndex;
        ss.user[_address].userChangeCountIndex = nextCHCIndex;

        ss.chc[nextCHCIndex] = TChangeCountIndex({
            canWinPrizesToken0 : blockTime < ss.stakePool.poolToken0DistributionEndTime,
            canWinPrizesToken1 : blockTime < ss.stakePool.poolToken1DistributionEndTime,
            chcTotalPoolScore  : ss.stakePool.poolTotalScore,
            chcStartTime       : blockTime,
            chcEndTime         : 0,
            chcToken0RewardPerTime       : ss.stakePool.poolToken0RewardPerTime,
            chcToken0DistributionEndTime : ss.stakePool.poolToken0DistributionEndTime,
            chcToken1RewardPerTime       : ss.stakePool.poolToken1RewardPerTime,
            chcToken1DistributionEndTime : ss.stakePool.poolToken1DistributionEndTime
        });
    }

    function addToken0Liquidity(
        uint256 _amount,
        uint256 _distTime
    ) 
        public 
        onlyOwner 
    {
        LibStake.Layout storage ss = LibStake.layout();
        IHOOPX token0 = IHOOPX(ss.stakePool.token0);

        if(token0.balanceOf(msg.sender) < _amount){ revert Insufficient_Balance(); }
        if(token0.allowance(msg.sender, address(this)) < _amount){ revert Insufficient_Allowance(); }

        unchecked {
            ss.stakePool.poolToken0Liquidity += _amount;
            ss.stakePool.poolToken0RewardPerTime = _amount / _distTime;
            ss.stakePool.poolToken0DistributionEndTime = block.timestamp + _distTime;
        }

        _updateChc(address(0));

        token0.transferFrom(msg.sender,address(this),_amount);

        emit HANDLE_ADD_LIQUIDITY(msg.sender,ss.stakePool.token0,block.timestamp);
    }

    function addToken1Liquidity(
        uint256 _amount,
        uint256 _distTime
    ) 
        public 
        onlyOwner 
    {
        LibStake.Layout storage ss = LibStake.layout();
        IHOOPX token1 = IHOOPX(ss.stakePool.token1);

        if(token1.balanceOf(msg.sender) < _amount){ revert Insufficient_Balance(); }
        if(token1.allowance(msg.sender, address(this)) < _amount){ revert Insufficient_Allowance(); }

        unchecked {
            ss.stakePool.poolToken1Liquidity += _amount;
            ss.stakePool.poolToken1RewardPerTime = _amount / _distTime;
            ss.stakePool.poolToken1DistributionEndTime = block.timestamp + _distTime;
        }

        _updateChc(address(0));

        token1.transferFrom(msg.sender,address(this),_amount);
        
        emit HANDLE_ADD_LIQUIDITY(msg.sender,ss.stakePool.token1,block.timestamp);
    }

    function getStaker(
        address _address
    ) 
        public 
        view 
        returns (TUser memory user) 
    {
        user = LibStake.layout().user[_address];
    }

    function getStakePool(
    ) 
        public 
        view 
        returns (TStakePoolInfo memory stakePool) 
    {
        stakePool = LibStake.layout().stakePool;
    }

    function getChcInfo(
        uint256 _index
    ) 
        public 
        view 
        returns (TChangeCountIndex memory chcInfo) 
    {
        chcInfo = LibStake.layout().chc[_index];
    }

    function getUserHistory(
        address _address
    ) 
        public 
        view 
        returns (TUserStakeTransactions memory history) 
    {
        history = LibStake.layout().userStakeTransactionsHistory[_address];
    }

    function onERC1155Received(
        address, 
        address, 
        uint256, 
        uint256, 
        bytes memory
    ) 
        public 
        virtual 
        returns(bytes4) 
    {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, 
        address, 
        uint256[] memory, 
        uint256[] memory, 
        bytes memory
    ) 
        public 
        virtual 
        returns(bytes4) 
    {
        return this.onERC1155BatchReceived.selector;
    }

}