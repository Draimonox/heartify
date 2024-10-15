"use client";
import { Button, Text } from "@mantine/core";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useDisconnect } from "wagmi";
import { deleteCookie, getCookie } from "cookies-next";

import { useRouter } from "next/navigation";
// import { useEffect, useState } from "react";
// import jwt from "jsonwebtoken";

function Header() {
  const { disconnect } = useDisconnect();
  const router = useRouter();

  const token = getCookie("token");
  if (!token) {
    router.push("/");
  }

  return (
    <>
      <header
        style={{
          paddingRight: "50px",
          paddingTop: "15px",
          paddingBottom: "15px",
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          boxShadow: "0px 4px 6px rgba(0, 0, 0, 0.1)",
          color: "red",
        }}
      >
        <Text
          size="xl"
          fw={700}
          c="teal.4"
          style={{ marginLeft: "50px", cursor: "pointer" }}
          onClick={() => {
            router.push("/main");
          }}
        >
          Heartify
        </Text>
        <div style={{ display: "flex", gap: "10px" }}>
          {/* <Button
            variant="light"
            color="green"
            size="lg"
            radius="xl"
            onClick={() => {}}
          >
            Connect Wallet
          </Button> */}
          <ConnectButton showBalance={false} chainStatus={"icon"} />
          <Button
            variant="light"
            color="red"
            size="lg"
            radius="xl"
            disabled={!ConnectButton}
            onClick={() => disconnect()}
          >
            Disconnect
          </Button>
        </div>
      </header>
    </>
  );
}

export default Header;
