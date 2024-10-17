import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Heartify = await ethers.getContractFactory("Heartify");
  const heartify = await Heartify.deploy(deployer.address);

  await heartify.waitForDeployment();

  console.log("Heartify contract deployed to:", await heartify.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
