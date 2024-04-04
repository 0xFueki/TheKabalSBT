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

    describe("Setting contract address", () => {
        it("Should set addresses on contracts", async function () {

            await expect(minterContract.setLaunchpadAddress(launchpadContract.address)).to.not.be.reverted
            await expect(minterContract.setTokenAddress(tokenContract.address)).to.not.be.reverted
            await expect(tokenContract.setMinterAddress(minterContract.address)).to.not.be.reverted
            await expect(launchpadContract.setTokenAddress(minterContract.address)).to.not.be.reverted
        });
    });

    describe("Minter whitelist", () => {
        it("Should set map of addresses and token ids", async function () {
            await expect(minterContract.setAvailableTokenIds([addr1.address, addr2.address], [37, 69])).to.not.be.reverted
        });
    });

    describe("Mint from launchpad", () => {
        beforeEach(async () => {
            await expect(minterContract.setAvailableTokenIds([addr1.address, addr2.address], [37, 69])).to.not.be.reverted            
        })

        it("Should mint 1 with given token id for 1 address", async function () {
            await expect(launchpadContract.connect(addr1).mint(1)).not.to.be.reverted

            await expect(await tokenContract.balanceOf(addr1.address)).to.eq(1);
            await expect(await tokenContract.ownerOf(37)).to.eq(addr1.address);
            await expect(await tokenContract.totalSupply()).to.eq(1);
        });

        it("Should mint 1 with given token id for all address", async function () {
            await expect(launchpadContract.connect(addr1).mint(1)).not.to.be.reverted

            await expect(await tokenContract.balanceOf(addr1.address)).to.eq(1);
            await expect(await tokenContract.ownerOf(37)).to.eq(addr1.address);
            await expect(await tokenContract.totalSupply()).to.eq(1);

            await expect(launchpadContract.connect(addr2).mint(1)).not.to.be.reverted

            await expect(await tokenContract.balanceOf(addr2.address)).to.eq(1);
            await expect(await tokenContract.ownerOf(69)).to.eq(addr2.address);
            await expect(await tokenContract.totalSupply()).to.eq(2);
        });

        it("Should not mint 2", async function () {
            await expect(launchpadContract.connect(addr1).mint(2)).to.be.revertedWith("only mint 1")
        });

        it("Should not mint if address is not set", async function () {
            await expect(launchpadContract.connect(addr3).mint(1)).to.be.revertedWith("address not set")
        });

        it("Should not mint after already minted", async function () {
            await expect(launchpadContract.connect(addr1).mint(1)).to.not.be.reverted

            await expect(launchpadContract.connect(addr1).mint(1)).to.be.revertedWith("address not set")
        });
    });

    describe("Token transfer", () => {
        beforeEach(async () => {
            await expect(minterContract.setAvailableTokenIds([addr1.address, addr2.address], [37, 69])).to.not.be.reverted

            await expect(launchpadContract.connect(addr1).mint(1)).to.not.be.reverted
        })

        it("Should not transfer", async function () {
            await expect(tokenContract.connect(addr1).transferFrom(addr1.address, addr3.address, 37)).to.be.revertedWith("TRANSFER_LOCKED")
        });        

        it("Should transfer by token owner after transfer enabled", async function () {            
            await expect(tokenContract.setTransferLock(false)).to.not.be.reverted
            await expect(tokenContract.connect(addr1).transferFrom(addr1.address, addr3.address, 37)).to.not.be.revertedWith("TRANSFER_LOCKED")
        });

        it("Should not approve", async function () {
            await expect(tokenContract.connect(addr1).approve(addr3.address, 37)).to.be.revertedWith("TRANSFER_LOCKED")
        });    
        
        it("Should not set approval for all", async function () {
            await expect(tokenContract.connect(addr1).setApprovalForAll(addr3.address, true)).to.be.revertedWith("TRANSFER_LOCKED")
        });    

        it("Should approve after transfer unlocked", async function () {
            await expect(tokenContract.setTransferLock(false)).to.not.be.reverted

            await expect(tokenContract.connect(addr1).approve(addr3.address, 37)).to.not.be.reverted
        });    
        
        it("Should set approval for all after transfer unlocked", async function () {
            await expect(tokenContract.setTransferLock(false)).to.not.be.reverted

            await expect(tokenContract.connect(addr1).setApprovalForAll(addr3.address, true)).to.not.be.reverted
        });  

        describe("SBT token transfer", () => {
            it("Should transfer by contract owner", async function () {            
                await expect(tokenContract.transferSBT(addr3.address, 37)).to.not.be.reverted
            });
    
            it("Should not transfer by contract if not minted", async function () {            
                await expect(tokenContract.transferSBT(addr3.address, 38)).to.be.revertedWith("NOT_MINTED")
            });

            it("Should add wallet as admin", async function () {            
                await expect(tokenContract.addAdmin(addr3.address)).to.not.be.reverted
            });

            it("Should remove wallet as admin", async function () {            
                await expect(tokenContract.removeAdmin(addr3.address)).to.not.be.reverted
            });

            it("Should transfer by contract admin", async function () {     
                await expect(tokenContract.addAdmin(addr3.address)).to.not.be.reverted

                await expect(tokenContract.connect(addr3).transferSBT(addr4.address, 37)).to.not.be.reverted
            });

            it("Should not transfer by contract admin after wallet removed", async function () {     
                await expect(tokenContract.addAdmin(addr3.address)).to.not.be.reverted

                await expect(tokenContract.removeAdmin(addr3.address)).to.not.be.reverted

                await expect(tokenContract.connect(addr3).transferSBT(addr4.address, 37)).to.be.revertedWith("UNAUTHORIZED")
            });

            it("Should not transfer if not contract owner or admin", async function () {
                await expect(tokenContract.connect(addr4).transferSBT(addr3.address, 37)).to.be.revertedWith("UNAUTHORIZED")
            });

            it("Should not transfer by contract owner after transfer unlocked", async function () {     
                await expect(tokenContract.setTransferLock(false)).to.not.be.reverted

                await expect(tokenContract.transferSBT(addr3.address, 37)).to.be.revertedWith("TRANSFER_UNLOCKED")
            });

            it("Should not set transfer lock after lock revoked", async function () {     
                await expect(tokenContract.revokeTransferLock()).to.not.be.reverted

                await expect(tokenContract.setTransferLock(false)).to.be.revertedWith("TRANSFER_LOCK_REVOKED")                
            });

            it("Should not set transfer lock if not owner", async function () {     
                await expect(tokenContract.connect(addr1).setTransferLock(false)).to.be.revertedWith("UNAUTHORIZED")                
            });

            it("Should not revoke transfer lock if not owner", async function () {     
                await expect(tokenContract.connect(addr1).revokeTransferLock()).to.be.revertedWith("UNAUTHORIZED")                
            });
        })
    });
})