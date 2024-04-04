const { expect } = require("chai");
const { ethers } = require("hardhat");
const { DateTime } = require("luxon");

describe("Minting Test", function () {
    let Token,
        tokenContract,
        Minter,
        minterContract,
        Launchpad,
        launchpadContract,
        owner,
        addr1,
        addr2,
        addr3,
        addr4,
        addr5;

    beforeEach(async () => {
        [owner, addr1, addr2, addr3, addr4, addr5] = await ethers.getSigners();

        Token = await ethers.getContractFactory("TheKabal")
        tokenContract = await Token.deploy()

        Minter = await ethers.getContractFactory("TheKabalMinter")
        minterContract = await Minter.deploy()

        Launchpad = await ethers.getContractFactory("Launchpad")
        launchpadContract = await Launchpad.deploy()

        await expect(minterContract.setLaunchpadAddress(launchpadContract.address)).to.not.be.reverted
        await expect(minterContract.setTokenAddress(tokenContract.address)).to.not.be.reverted
        await expect(tokenContract.setMinterAddress(minterContract.address)).to.not.be.reverted
        await expect(launchpadContract.setTokenAddress(minterContract.address)).to.not.be.reverted
    })

    describe("Set launchpad address to minter contract", () => {
        it("Should set launchpad address to minter contract", async function () {

            await expect(minterContract.setLaunchpadAddress(launchpadContract.address)).to.not.be.reverted
            await expect(minterContract.setTokenAddress(tokenContract.address)).to.not.be.reverted
            await expect(tokenContract.setMinterAddress(minterContract.address)).to.not.be.reverted
            await expect(launchpadContract.setTokenAddress(minterContract.address)).to.not.be.reverted

            console.log(await minterContract.launchpadAddress())
            console.log(await minterContract.tokenAddress())
            console.log(await tokenContract.minterAddress())
            console.log(await launchpadContract.tokenAddress())
        });
    });

    describe("Set minter whitelist", () => {
        it("Should set launchpad address to minter contract", async function () {
            await expect(minterContract.setAvailableTokenIds([addr1.address, addr2.address],[37,69])).to.not.be.reverted            
        });
    });

    describe("Set mint", () => {
        it("Should mint 1", async function () {
            await expect(minterContract.setAvailableTokenIds([addr1.address, addr2.address],[37,69])).to.not.be.reverted            

            console.log(await minterContract.addressToTokenId(addr1.address))

            await expect(launchpadContract.connect(addr1).mint(1)).not.to.be.reverted

            await expect(await tokenContract.balanceOf(addr1.address)).to.eq(1);
            await expect(await tokenContract.ownerOf(37)).to.eq(addr1.address);
            await expect(await tokenContract.totalSupply()).to.eq(1);
        });
    });
})