"use client";
import * as React from "react";
import { useConnect } from "wagmi";

export function WalletOptions() {
  const { connectors, connect } = useConnect();

  return (
    <>
      {connectors.map((connector) => (
        <button
          key={connector.id} // Use connector.id if uid is not available
          onClick={() => connect({ connector })}
          // Handle loading state
        >
          {connector.name}
        </button>
      ))}
    </>
  );
}
