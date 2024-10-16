"use client";
import { Button, Text } from "@mantine/core";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useDisconnect } from "wagmi";
import { getCookie } from "cookies-next";
import ConnectWallet from "./connectWallet";
import { useRouter } from "next/navigation";
import Image from "next/image";
import logo from "../logo.png";
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
        <div style={{ width: "100vw", display: "flex", alignItems: "center" }}>
          <Image
            src={logo}
            alt="Heartify Logo"
            width={50}
            height={50}
            style={{ marginLeft: "2%" }}
          />
          <Text
            size="xl"
            fw={900}
            variant="gradient"
            gradient={{
              from: "rgba(119, 44, 232, 0.68)",
              to: " rgba(128, 187, 255, 1)",
              deg: 360,
            }}
            style={{
              cursor: "pointer",
              marginLeft: "1%",
              fontFamily: "copperplate gothic",
              outline: "white",
            }}
            onClick={() => {
              router.push("/main");
            }}
          >
            Heartify
          </Text>
        </div>
        <div style={{ display: "flex", gap: "10px" }}>
          <ConnectWallet />
          <Button
            variant="light"
            color="red"
            size="lg"
            radius="xl"
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
