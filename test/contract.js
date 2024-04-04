const { expect } = require("chai");
const { ethers } = require("hardhat");
const { DateTime } = require("luxon");

describe("Minting Test", function () {
    let Token,
    tokenContract,
    Minter,
    minterContract,
    Metadata,
    metadataContract,
    Nest,
    nestContract,
    owner,
    addr1,
    addr2,
    addr3,
    addr4,
    addr5;

    beforeEach(async () => {
        [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();

        Token = await ethers.getContractFactory("TheKabalSBT");
    })
})