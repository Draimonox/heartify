"use client";

import "@mantine/core/styles.css";
import { MantineProvider } from "@mantine/core";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useAccount, WagmiProvider, http } from "wagmi";
import Account from "../app/components/account";
import WalletOptions from "./components/walletOptions";
import { RainbowKitProvider, midnightTheme } from "@rainbow-me/rainbowkit";
import { injected, metaMask, safe, walletConnect } from "wagmi/connectors";
import { getDefaultConfig } from "@rainbow-me/rainbowkit";
import { mainnet, base } from "wagmi/chains";
import "@rainbow-me/rainbowkit/styles.css";

const projectId = "4a8dc4d3faf82e8069b2095c947af7cb";

function ConnectWallet() {
  const { isConnected } = useAccount();
  if (isConnected) return <Account />;
  return <WalletOptions />;
}

const config = getDefaultConfig({
  appName: "Heartify",
  projectId: projectId,
  chains: [mainnet, base],
  transports: {
    [mainnet.id]: http(),
  },
});

const queryClient = new QueryClient();

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <>
      <html lang="en">
        <body id="body">
          <WagmiProvider config={config}>
            <QueryClientProvider client={queryClient}>
              <RainbowKitProvider
                modalSize="wide"
                theme={{
                  ...midnightTheme({ ...midnightTheme.accentColors.purple }),
                }}
              >
                <MantineProvider
                  forceColorScheme="dark"
                  defaultColorScheme="dark"
                >
                  {children}
                </MantineProvider>
              </RainbowKitProvider>
            </QueryClientProvider>
          </WagmiProvider>
        </body>
      </html>
    </>
  );
}
