// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

// Membership Structs

struct TMembership{
    bool membershipIsActive;

    uint256 acceptableTokenIdForHoopX; // 5 = 1,2,3,4,5
    uint256 balancedOneHoop; // 1 HOOP = 70 HOOPX

    uint256 buyPrice; // 0.0012 eth
    uint256 buyNFTBurnPercentage;
    uint256 buyNFTReservePercentage;

    uint256 upgradePrice; // 0.0012 eth
    uint256 upgradeNFTBurnPercentage;
    uint256 upgradeNFTReservePercentage;

    uint256[] tokenIDs;

    address hoopXTokenAddress;
    address hoopTokenAddress;

    address hoopXReserveAddress;

    address nftContract;
}

struct TNFT{
    bool nftIsExist;
    uint256 tokenID;
    uint256 price;
}

// Stake Structs

struct TChangeCountIndex{
    bool canWinPrizesToken0;
    bool canWinPrizesToken1;

    uint256 chcTotalPoolScore;
    uint256 chcStartTime;
    uint256 chcEndTime;

    uint256 chcToken0RewardPerTime;
    uint256 chcToken0DistributionEndTime;

    uint256 chcToken1RewardPerTime;
    uint256 chcToken1DistributionEndTime;
}

struct TUser {
    bool staker;

    uint256 userStakedNFT;
    uint256 userChangeCountIndex;
    uint256 userTotalScore;
    uint256 userEarnedToken0Amount;
    uint256 userEarnedToken1Amount;
}

struct TStakePoolInfo {
    bool isActive;

    uint256 lastCHCIndex;
    uint256 numberOfStakers;

    uint256 poolTotalScore;
    uint256 totalLockedHOOPValue;
    uint256 totalLockedHOOPXValue;

    uint256 poolToken0RewardPerTime;
    uint256 poolDistributedToken0Reward;
    uint256 poolToken0DistributionEndTime;
    uint256 poolTotalDistributedToken0;
    uint256 poolToken0Liquidity;

    uint256 poolToken1RewardPerTime;
    uint256 poolDistributedToken1Reward;
    uint256 poolToken1DistributionEndTime;
    uint256 poolTotalDistributedToken1;
    uint256 poolToken1Liquidity;

    address token0;
    address token1;
}

struct TUserStakeTransactionsData{
    string identifierStakeTransactions;
    uint256 stakeTransactionsTime;
    uint256 stakeTransactionsValue;
    uint256 stakeTransactionsValueForHoopX;
}

struct TUserStakeTransactions{
    TUserStakeTransactionsData[] stakeTransactions;
}

// Swap Structs

struct TSwapPool{
        bool isExistSwapPool;
        bool isWithdrawActive;
        bool isDepositActive;

        uint256 swapFee;
        uint256 totalLocked;
        uint256 lastValuation;

        address pairToken0;
        address pairToken1;
    }

    struct TSwapPoolUser{
        bool isRequested;
        uint256 pendingRequests;
        uint256 burnedAmount; // all time burned amount
        uint256 depositValue; // all time deposited value
        uint256 amountWithdrawn; // all time amount withdrawn
    }

    struct TPendingRequests{
        uint256 requestValue;
        address userAddress;
    }
    struct TSwapPoolPendingRequests{
        TPendingRequests[] pendingRequests;
    }

    struct TUserSwapTransactionsData{
        string identifierSwapTransactions;
        uint256 swapTransactionsTime;
        uint256 swapTransactionsValue;
    }

    struct TUserSwapTransactions{
        TUserSwapTransactionsData[] swapTransactions;
    }