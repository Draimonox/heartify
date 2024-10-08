import { ethers } from "hardhat";
import { Heartify } from "../typechain-types";
import { expect } from "chai";
import { Signer } from "ethers";

describe("Heartify NFT Contract", function () {
  let heartify: Heartify;
  let owner: Signer;
  let artist: Signer;
  let buyer: Signer;
  let dev: Signer;
  const mintingFee = ethers.parseEther("15"); // 15 MATIC;

  beforeEach(async function () {
    const HeartifyFactory = await ethers.getContractFactory("Heartify");
    [owner, artist, buyer, dev] = await ethers.getSigners();

    heartify = (await (
      await HeartifyFactory.deploy(await owner.getAddress())
    ).waitForDeployment()) as Heartify;
  });

  it("should set the correct minting fee", async function () {
    expect(await heartify.mintingFee()).to.equal(mintingFee);
  });

  it("should mint an NFT", async function () {
    await heartify
      .connect(artist)
      .safeMint(await artist.getAddress(), { value: mintingFee });
    const tokenId = 1;
    expect(await heartify.ownerOf(tokenId)).to.equal(await artist.getAddress());
    expect(await heartify.getArtist(tokenId)).to.equal(
      await artist.getAddress()
    );
  });

  it("should not mint if insufficient funds are sent", async function () {
    await expect(
      heartify.connect(artist).safeMint(await artist.getAddress(), {
        value: ethers.parseEther("10"),
      }) // Less than 15
    ).to.be.revertedWith("Insufficient funds to mint");
  });

  it("should allow batch minting of NFTs", async function () {
    await heartify
      .connect(artist)
      .batchMint(await artist.getAddress(), 3, { value: mintingFee * 3n });
    expect(await heartify.balanceOf(await artist.getAddress())).to.equal(3);
  });

  it("should list an NFT for sale", async function () {
    await heartify
      .connect(artist)
      .safeMint(await artist.getAddress(), { value: mintingFee });
    await heartify.connect(artist).listNFT(1, ethers.parseEther("100"));
    expect(await heartify.getTokenPrice(1)).to.equal(ethers.parseEther("100"));
  });

  it("should not allow listing an NFT that the user does not own", async function () {
    await heartify
      .connect(artist)
      .safeMint(await artist.getAddress(), { value: mintingFee });
    await expect(
      heartify.connect(buyer).listNFT(1, ethers.parseEther("100"))
    ).to.be.revertedWith("You do not own this token");
  });

  it("should allow buying an NFT", async function () {
    await heartify
      .connect(artist)
      .safeMint(await artist.getAddress(), { value: mintingFee });
    await heartify.connect(artist).listNFT(1, ethers.parseEther("100"));
    await heartify
      .connect(buyer)
      .buyNFT(1, { value: ethers.parseEther("100") });

    expect(await heartify.ownerOf(1)).to.equal(await buyer.getAddress());
  });

  it("should calculate royalties correctly on purchase", async function () {
    await heartify
      .connect(artist)
      .safeMint(await artist.getAddress(), { value: mintingFee });
    await heartify.connect(artist).listNFT(1, ethers.parseEther("100"));

    const initialDevBalance = await ethers.provider.getBalance(
      await dev.getAddress()
    );
    const initialArtistBalance = await ethers.provider.getBalance(
      await artist.getAddress()
    );

    await heartify
      .connect(buyer)
      .buyNFT(1, { value: ethers.parseEther("100") });

    const finalDevBalance = await ethers.provider.getBalance(
      await dev.getAddress()
    );
    const finalArtistBalance = await ethers.provider.getBalance(
      await artist.getAddress()
    );

    const artistRoyalty = (100 * 300) / 10000; // 3% of 100
    const devRoyalty = (100 * 300) / 10000; // 3% of 100

    expect(finalDevBalance - initialDevBalance).to.equal(
      ethers.parseEther(devRoyalty.toString())
    );
    expect(finalArtistBalance - initialArtistBalance).to.equal(
      ethers.parseEther(artistRoyalty.toString())
    );
  });

  it("should not allow buying an NFT that is not listed", async function () {
    await heartify
      .connect(artist)
      .safeMint(await artist.getAddress(), { value: mintingFee });
    await expect(
      heartify.connect(buyer).buyNFT(1, { value: ethers.parseEther("100") })
    ).to.be.revertedWith("Token is not listed for sale");
  });

  it("should allow the owner to withdraw funds", async function () {
    await heartify
      .connect(artist)
      .safeMint(await artist.getAddress(), { value: mintingFee });
    await heartify.connect(artist).listNFT(1, ethers.parseEther("100"));
    await heartify
      .connect(buyer)
      .buyNFT(1, { value: ethers.parseEther("100") });

    const initialDevBalance = await ethers.provider.getBalance(
      await dev.getAddress()
    );
    await heartify.withdrawFunds();
    const finalDevBalance = await ethers.provider.getBalance(
      await dev.getAddress()
    );

    expect(finalDevBalance).to.be.gt(initialDevBalance); // Check if funds have been withdrawn
  });

  it("should pause and unpause the contract", async function () {
    await heartify.pause();
    await expect(
      heartify
        .connect(artist)
        .safeMint(await artist.getAddress(), { value: mintingFee })
    ).to.be.revertedWith("Pausable: paused");

    await heartify.unpause();
    await heartify
      .connect(artist)
      .safeMint(await artist.getAddress(), { value: mintingFee });
    expect(await heartify.ownerOf(1)).to.equal(await artist.getAddress());
  });
});
