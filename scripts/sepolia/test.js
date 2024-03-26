const { ethers, network } = require("hardhat");

const main = async () => {
  [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();
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
