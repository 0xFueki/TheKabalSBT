const { expect } = require("chai");
const { ethers, network } = require("hardhat");

const main = async () => {
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
