"use client";

import "@mantine/core/styles.css";
import { ColorSchemeScript, MantineProvider } from "@mantine/core";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { useAccount, WagmiProvider } from "wagmi";
import { config } from "../../config";
import Account from "../app/components/account";
import WalletOptions from "./components/walletOptions";
import { RainbowKitProvider, midnightTheme } from "@rainbow-me/rainbowkit";

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
    <>
      <html lang="en">
        <body id="body">
          <MantineProvider forceColorScheme="dark" defaultColorScheme="dark">
            <WagmiProvider config={config}>
              <QueryClientProvider client={queryClient}>
                <RainbowKitProvider
                  modalSize="wide"
                  theme={{
                    ...midnightTheme({ ...midnightTheme.accentColors.purple }),
                  }}
                >
                  {/* <ConnectWallet /> */}
                  {children}
                </RainbowKitProvider>
              </QueryClientProvider>
            </WagmiProvider>
          </MantineProvider>
        </body>
      </html>
    </>
  );
}
