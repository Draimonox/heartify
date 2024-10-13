"use client";

import "@mantine/core/styles.css";
import { ColorSchemeScript, MantineProvider } from "@mantine/core";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useAccount, WagmiProvider } from "wagmi";
import { config } from "../../config";
import { Account } from "../app/components/account";
import { WalletOptions } from "./components/walletOptions";
import { RainbowKitProvider } from "@rainbow-me/rainbowkit";

const queryClient = new QueryClient();

function ConnectWallet() {
  const { isConnected } = useAccount();
  if (isConnected) return <Account />;
  return <WalletOptions />;
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider>
          <html lang="en">
            <head>
              <ColorSchemeScript />
            </head>
            <body>
              <MantineProvider forceColorScheme="dark">
                <ConnectWallet />
                {children}
              </MantineProvider>
            </body>
          </html>
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
