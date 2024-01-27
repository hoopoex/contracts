// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import '@solidstate/contracts/access/ownable/OwnableInternal.sol';
import { LibMembership } from "../libraries/LibMembership.sol";
import { TMembership,TNFT } from "../libraries/Structs.sol";
import { Modifiers } from "../libraries/Modifiers.sol";
import "../libraries/Errors.sol";

contract SettingMembership is Modifiers, OwnableInternal {

// init settings

    function initMembership(
        TMembership memory _params
    )
        external 
        onlyOwner 
    {
        LibMembership.layout().membership = _params;
    }

    function initMembershipNFTs(
        TNFT[] memory _paramsArray
    )
        public 
        onlyOwner 
    {
        LibMembership.Layout storage ms = LibMembership.layout();
        address nftContract = ms.membership.nftContract;
        uint256[] storage tokenIDs = ms.membership.tokenIDs;
        TNFT[] memory paramsArray = _paramsArray;
        for(uint256 i = 0; i < paramsArray.length;) {
            TNFT memory params = paramsArray[i];
            if(!LibMembership.checkExistence(tokenIDs,params.tokenID)){ revert Invalid_Action(); }
            ms.nft[nftContract][params.tokenID] = params;

            unchecked{
                i++;
            }
        }
    }

// other settings

    function setMembershipActive(
        bool _status
    ) 
        external 
        onlyOwner 
    {
        LibMembership.layout().membership.membershipIsActive = _status;
    }

    function setAcceptableTokenIDForHoopX(
        uint256 _id
    ) 
        external 
        onlyOwner 
    {
        LibMembership.layout().membership.acceptableTokenIdForHoopX = _id;
    }

    function setBalancedOneHoop(
        uint256 _oneHoop
    )
        external 
        onlyOwner 
    {
        LibMembership.layout().membership.balancedOneHoop = _oneHoop;
    }

    function setBuyPrice(
        uint256 _buyPrice
    )
        external 
        onlyOwner 
    {
        LibMembership.layout().membership.buyPrice = _buyPrice;
    }

    function setUpgradePrice(
        uint256 _upgradePrice
    )
        external 
        onlyOwner 
    {
        LibMembership.layout().membership.upgradePrice = _upgradePrice;
    }

    function setBuyNFTBurnPercentage(
        uint256 _buyNFTBurnPercentage
    )
        external 
        onlyOwner 
    {
        LibMembership.layout().membership.buyNFTBurnPercentage = _buyNFTBurnPercentage;
    }

    function setUpgradeNFTBurnPercentage(
        uint256 _upgradeNFTBurnPercentage
    )
        external 
        onlyOwner 
    {
        LibMembership.layout().membership.upgradeNFTBurnPercentage = _upgradeNFTBurnPercentage;
    }

    function setBuyNFTReservePercentage(
        uint256 _buyNFTReservePercentage
    )
        external 
        onlyOwner 
    {
        LibMembership.layout().membership.buyNFTReservePercentage = _buyNFTReservePercentage;
    }

    function setUpgradeNFTReservePercentage(
        uint256 _upgradeNFTReservePercentage
    )
        external 
        onlyOwner 
    {
        LibMembership.layout().membership.upgradeNFTReservePercentage = _upgradeNFTReservePercentage;
    }

    function setHoopXTokenAddress(
        address _hoopXTokenAddress
    )
        external 
        onlyOwner 
        isValidContract(_hoopXTokenAddress)
    {
        LibMembership.layout().membership.hoopXTokenAddress = _hoopXTokenAddress;
    }

    function setHoopTokenAddress(
        address _hoopTokenAddress
    )
        external 
        onlyOwner 
        isValidContract(_hoopTokenAddress)
    {
        LibMembership.layout().membership.hoopTokenAddress = _hoopTokenAddress;
    }

    function setHoopXReserveAddress(
        address _hoopXReserveAddress
    )
        external 
        onlyOwner 
        isValidContract(_hoopXReserveAddress)
    {
        LibMembership.layout().membership.hoopXReserveAddress = _hoopXReserveAddress;
    }

    function setNFT(
        TNFT memory _params
    )
        external 
        onlyOwner 
    {
        LibMembership.layout().nft[LibMembership.layout().membership.nftContract][_params.tokenID] = _params;
    }

    function setAuthorizedUser(
        bool _status,
        address _user
    ) 
        external 
        onlyOwner 
    {
        LibMembership.layout().authorizedUser[_user] = _status;
    }

}