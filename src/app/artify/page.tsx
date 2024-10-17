"use client";
import Header from "../components/header";
import { type BaseError, useReadContracts, useWriteContract } from "wagmi";
import { wagmiConfig } from "../lib/wagmi/createConfig";

// contract address :  0x6EBfa771489B9D56DaD960AA24db1f8C69f89Ccc
function Artify() {
  const { data, error, isPending } = useReadContracts({
    contracts: [
      {
        ...wagmiConfig,
        functionName: "balanceOf",
        args: ["0x03A71968491d55603FFe1b11A9e23eF013f75bCF"],
      },
      {
        ...wagmiConfig,
        functionName: "ownerOf",
        args: [69n],
      },
      {
        ...wagmiConfig,
        functionName: "totalSupply",
      },
    ],
  });
  const [balance, ownerOf, totalSupply] = data || [];

  if (isPending) return <div>Loading...</div>;

  if (error)
    return (
      <div>Error: {(error as BaseError).shortMessage || error.message}</div>
    );

  return (
    <>
      <Header />
      <div>Balance: {balance?.toString()}</div>
      <div>Owner of Token 69: {ownerOf?.toString()}</div>
      <div>Total Supply: {totalSupply?.toString()}</div>
    </>
  );
}

export default Artify;
