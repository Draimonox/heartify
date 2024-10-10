"use client";
import { Button, Text } from "@mantine/core";

import { deleteCookie, getCookie } from "cookies-next";

import { useRouter } from "next/navigation";
// import { useEffect, useState } from "react";
// import jwt from "jsonwebtoken";

function Header() {
  const router = useRouter();

  function logOut() {
    console.log("Logging out...");
    deleteCookie("token");
    router.push("/login");
  }
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
          BlogUp!
        </Text>
        <div style={{ display: "flex", gap: "10px" }}>
          <Button
            variant="light"
            color="blue"
            size="lg"
            radius="xl"
            onClick={() => {
              router.push("/");
            }}
          >
            Search
          </Button>
          <Button
            variant="light"
            color="green"
            size="lg"
            radius="xl"
            onClick={() => {
              router.push("/blogUp");
            }}
          >
            BlogUp!
          </Button>
          <Button
            variant="light"
            color="gray"
            size="lg"
            radius="xl"
            onClick={() => {}}
          >
            Profile
          </Button>
          <Button
            variant="light"
            color="red"
            size="lg"
            radius="xl"
            onClick={logOut}
          >
            Log out
          </Button>
        </div>
      </header>
    </>
  );
}

export default Header;
