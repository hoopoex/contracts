import { ethers } from "hardhat";

const HoopXFacets = [
  "Membership",
  "Stake",
  "SettingMembership",
  "SettingStake",
];

const Tortullix = ethers.utils.parseEther("1");
const Woolvenia = ethers.utils.parseEther("2");
const Bouncebyte = ethers.utils.parseEther("3");
const Stagora = ethers.utils.parseEther("4");
const Honeyheart = ethers.utils.parseEther("5");
const PiggyPrime = ethers.utils.parseEther("6");
const HoopX = ethers.utils.parseEther("7");
const PrimeBull = ethers.utils.parseEther("8");
const Wolvenix = ethers.utils.parseEther("9");
const Whalesong = ethers.utils.parseEther("10");

const HOOP_TOKEN = "0x99Bd9444C841286291964ECe900b4b25E908D716";
const RESERVE_CONTRACT = "0x750a73578Dd12F6E469e7aC64fC8bA0B3928F1d7";
const NFT_CONTRACT = "0x73aE08c2Ed3e8eFb5a8B0766cB47B57C8d49679a";

const TMembershipInitParams = {
  membershipIsActive: true,
  acceptableTokenIdForHoopX: 0,
  balancedOneHoop: 70,

  buyPrice: ethers.utils.parseEther("0.0012"),
  buyNFTBurnPercentage: 70,
  buyNFTReservePercentage: 30,

  upgradePrice: ethers.utils.parseEther("0.0012"),
  upgradeNFTBurnPercentage: 70,
  upgradeNFTReservePercentage: 30,

  tokenIDs: [
    Tortullix,
    Woolvenia,
    Bouncebyte,
    Stagora,
    Honeyheart,
    PiggyPrime,
    HoopX,
    PrimeBull,
    Wolvenix,
    Whalesong,
  ],

  hoopXTokenAddress: ethers.constants.AddressZero,
  hoopTokenAddress: HOOP_TOKEN,

  hoopXReserveAddress: RESERVE_CONTRACT,

  nftContract: NFT_CONTRACT,
};

const NFTParams = [
  {
    nftIsExist: true,
    tokenID: Tortullix,
    price: ethers.utils.parseEther("1"),
  },
  {
    nftIsExist: true,
    tokenID: Woolvenia,
    price: ethers.utils.parseEther("2"),
  },
  {
    nftIsExist: true,
    tokenID: Bouncebyte,
    price: ethers.utils.parseEther("3"),
  },
  {
    nftIsExist: true,
    tokenID: Stagora,
    price: ethers.utils.parseEther("4"),
  },
  {
    nftIsExist: true,
    tokenID: Honeyheart,
    price: ethers.utils.parseEther("5"),
  },
  {
    nftIsExist: true,
    tokenID: PiggyPrime,
    price: ethers.utils.parseEther("6"),
  },
  {
    nftIsExist: true,
    tokenID: HoopX,
    price: ethers.utils.parseEther("8"),
  },
  {
    nftIsExist: true,
    tokenID: PrimeBull,
    price: ethers.utils.parseEther("15"),
  },
  {
    nftIsExist: true,
    tokenID: Wolvenix,
    price: ethers.utils.parseEther("25"),
  },
  {
    nftIsExist: true,
    tokenID: Whalesong,
    price: ethers.utils.parseEther("40"),
  },
];

exports.FacetList = HoopXFacets;
exports.TMembershipInitParams = TMembershipInitParams;
exports.NFTParams = NFTParams;
