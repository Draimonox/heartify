// // ./testChain.js
// export const localhostChain = {
// id: 1337, // Or the Chain ID used by your local blockchain (e.g., 5777 for Ganache GUI, 31337 for Hardhat)
// name: "Localhost",
// network: "localhost",
// nativeCurrency: {
//   decimals: 18,
//   name: "Ether",
//   symbol: "ETH",
// },
// rpcUrls: {
//   default: {
//     http: ["http://127.0.0.1:7545"], // Replace with your local blockchain's RPC URL
//   },
// },
// testnet: true,
// } as const;

import { defineChain } from "viem";

export const GANACHE_LOCAL_HOST = /*#__PURE__*/ defineChain({
  blockExplorers: {
    default: {
      name: "Basescan",
      url: "https://basescan.org",
      apiUrl: "https://api.basescan.org/api",
    },
  },
  id: 1337, // Or the Chain ID used by your local blockchain (e.g., 5777 for Ganache GUI, 31337 for Hardhat)
  name: "Localhost",
  network: "localhost",
  nativeCurrency: {
    decimals: 18,
    name: "Ether",
    symbol: "ETH",
  },
  rpcUrls: {
    default: {
      http: ["http://127.0.0.1:7545"], // Replace with your local blockchain's RPC URL
    },
  },
  testnet: true,
});
