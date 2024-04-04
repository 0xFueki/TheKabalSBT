// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./lib/Owned.sol";

interface TheKabal {
    function mint(address to, uint256 id) external;
}

contract TheKabalMinter is Owned {
    /* (•_• ) Storage (•_• ) */

    address launchpadAddress;

    mapping(address => uint256) addressToTokenId;

    address tokenAddress;

    /* (•_• ) Constructor (•_• ) */

    constructor(address _launchpadAddress) Owned(msg.sender) {
        launchpadAddress = _launchpadAddress;
    }

    /* (•_• ) Mint Logic (•_• ) */

    function setLaunchpadAddress(address _launchpadAddress) external onlyOwner {
        launchpadAddress = _launchpadAddress;
    }

    modifier onlyLaunchpad() {
        require(msg.sender == launchpadAddress, "NOT_LAUNCHPAD_ADDRESS");
        _;
    }

    function batchMint(address to, uint256 amount) public onlyLaunchpad {
        uint256 tokenId = addressToTokenId[to];
        require(tokenId != 0, "address not set");
        require(amount == 1, "only mint 1");

        addressToTokenId[to] = 0;

        TheKabal(tokenAddress).mint(to, tokenId);
    }

    /* (•_• ) Admin Logic (•_• ) */

    function setAvailableTokenIds(
        address[] calldata tos,
        uint256[] calldata tokenIds
    ) public onlyOwner {
        require(tos.length == tokenIds.length, "Array lengths must be equal");

        for (uint256 i = 0; i < tos.length; i++) {
            addressToTokenId[tos[i]] = tokenIds[i];
        }
    }
}
