import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const Heartify = await ethers.getContractFactory("Heartify");
  const heartify = await Heartify.deploy(deployer.address); // Pass the deployer's address as the default admin

  console.log("Heartify contract deployed to:", heartify.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
