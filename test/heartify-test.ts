import { ethers } from "hardhat";
import { expect } from "chai";
import { Heartify } from "../typechain-types"; // Adjust the path as necessary
import { Signer } from "ethers";

describe("Heartify NFT Contract", function () {
  let heartify: Heartify; // Heartify contract instance
  let owner: Signer;
  let artist: Signer;

  before(async function () {
    const HeartifyFactory = await ethers.getContractFactory("Heartify");
    [owner, artist] = await ethers.getSigners();

    heartify = (await HeartifyFactory.deploy(
      await owner.getAddress()
    )) as Heartify;
    await heartify.deployed();
  });

  it("Should mint an NFT", async function () {
    await heartify
      .connect(artist)
      .safeMint(await artist.getAddress(), { value: mintingFee });

    const balance: BigNumber = await heartify.balanceOf(
      await artist.getAddress()
    );
    expect(balance).to.equal(1); // Check that the artist has 1 NFT
  });

  it("Should list an NFT for sale", async function () {
    await heartify.connect(artist).listNFT(1, tokenPrice);
    const price: BigNumber = await heartify.getTokenPrice(1);
    expect(price).to.equal(tokenPrice); // Verify the listed price
  });

  it("Should allow a buyer to purchase the listed NFT", async function () {
    await heartify.connect(buyer).buyNFT(1, { value: tokenPrice });

    const newOwner: string = await heartify.ownerOf(1);
    expect(newOwner).to.equal(await buyer.getAddress()); // Check the new owner of the NFT
  });

  it("Should refund excess ETH to buyer", async function () {
    const excessAmount: BigNumber = ethers.utils.parseEther("7"); // Buyer sends 7, needs 2 refunded
    const balanceBefore: BigNumber = await buyer.getBalance();

    const tx = await heartify.connect(buyer).buyNFT(1, { value: excessAmount });
    const receipt = await tx.wait();
    const gasCost: BigNumber = receipt.gasUsed.mul(receipt.effectiveGasPrice);
    const balanceAfter: BigNumber = await buyer.getBalance();

    const allowedMargin: BigNumber = ethers.utils.parseEther("0.1"); // Allow a small margin for gas cost

    expect(balanceAfter.add(gasCost).add(tokenPrice)).to.be.closeTo(
      balanceBefore,
      allowedMargin // Use the defined margin for comparison
    );
  });
});
