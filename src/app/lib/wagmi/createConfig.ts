import { http, createConfig } from "wagmi";
import { base, baseSepolia } from "wagmi/chains";

export const wagmiConfig = createConfig({
  chains: [base, baseSepolia],
  transports: {
    [base.id]: http(process.env.NEXT_PUBLIC_BASE_MAINNET_RPC_URL),
    [baseSepolia.id]: http(process.env.NEXT_PUBLIC_BASE_TESTNET_RPC_URL),
    // [GANACHE_LOCAL_HOST.id]: http(),
  },
  // ssr: true,
});
