import { ethers } from "hardhat";

const {
  FacetList,
  TMembershipInitParams,
  NFTParams,
} = require("../libs/facets.ts");
const { getSelectors, FacetCutAction } = require("../libs/diamond.js");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.dir(FacetList);
  console.log("Attached diamond");
  const diamondFactory = await ethers.getContractFactory("HoopXDiamond");
  const diamondContract = await diamondFactory.deploy();
  await diamondContract.deployed();
  console.log(
    "Diamond contract was deployed successfully. 🤩👍 => ",
    diamondContract.address
  );
  console.log("");

  const cut = [];
  for (const FacetName of FacetList) {
    const Facet = await ethers.getContractFactory(FacetName);
    // @ts-ignore
    const facet = await Facet.deploy();
    await facet.deployed();
    console.log(`${FacetName} facet deployed 👍 => ${facet.address}`);
    cut.push({
      target: facet.address,
      action: FacetCutAction.Add,
      selectors: getSelectors(facet),
    });
  }

  console.log("");
  console.log("Writing diamondCut...");
  const tx = await diamondContract.diamondCut(
    cut,
    ethers.constants.AddressZero,
    "0x"
  );
  await tx.wait();
  console.log("Successfully. 🤩👍");
  console.log("");

  const settingMembership = await ethers.getContractAt(
    "SettingMembership",
    diamondContract.address
  );
  console.log("SUCCESS member wait");

  const initMembership = await settingMembership
    .connect(deployer)
    .initMembership(TMembershipInitParams);
  await initMembership.wait();
  console.log("SUCCESS INIT MEMBER");

  console.log("SUCCESS INIT wait");

  const initMembershipNFTs = await settingMembership
    .connect(deployer)
    .initMembershipNFTs(NFTParams);
  await initMembershipNFTs.wait();
  console.log("SUCCESS INIT nft");

  let contractAddresses = new Map<string, string>();
  contractAddresses.set("DIAMOND => ", diamondContract.address);

  console.table(contractAddresses);
}

/*
npx hardhat run scripts/deploy.ts --network localhost
*/

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
