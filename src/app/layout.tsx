import type { Metadata } from "next";
import "@mantine/core/styles.css";
import { ColorSchemeScript, MantineProvider } from "@mantine/core";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { WagmiProvider } from "wagmi";
import { config } from "../../config";

const queryClient = new QueryClient();

export const metadata: Metadata = {
  title: "Heartify",
  description: "",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <html lang="en">
          <head>
            <ColorSchemeScript />
          </head>
          <body>
            <MantineProvider forceColorScheme="dark">
              {children}
            </MantineProvider>
          </body>
        </html>
      </QueryClientProvider>
    </WagmiProvider>
  );
}
