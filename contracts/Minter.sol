// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./lib/Owned.sol";

interface TheKabal {
    function mint(address to, uint256 id) external;
}

contract Minter is Owned {
    /*//////////////////////////////////////////////////////////////
                            Errors
    //////////////////////////////////////////////////////////////*/

    error SenderNotMinter();

    /*//////////////////////////////////////////////////////////////
                            Storage
    //////////////////////////////////////////////////////////////*/

    address launchpadAddress;

    mapping(address => uint256) addressToTokenId;

    address tokenAddress;

    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/

    constructor(address _launchpadAddress) Owned(msg.sender) {
        launchpadAddress = _launchpadAddress;
    }

    /*//////////////////////////////////////////////////////////////
                            Launchpad Logic
    //////////////////////////////////////////////////////////////*/

    function setLaunchpadAddress(address _launchpadAddress) external onlyOwner {
        launchpadAddress = _launchpadAddress;
    }

    modifier onlyLaunchpad() {
        if (msg.sender != launchpadAddress) revert SenderNotMinter();
        _;
    }

    function batchMint(address to, uint256 amount) public onlyLaunchpad {
        uint256 tokenId = addressToTokenId[to];
        require(tokenId != 0, "address not set");
        require(amount == 1, "only mint 1");

        addressToTokenId[to] = 0;

        TheKabal(tokenAddress).mint(to, tokenId);
    }

    /*//////////////////////////////////////////////////////////////
                            Setup
    //////////////////////////////////////////////////////////////*/

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
