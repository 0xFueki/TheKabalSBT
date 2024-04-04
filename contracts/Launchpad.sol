// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface ITheKabalMinter {
    function batchMint(address to, uint256 amount) external;
}

contract Launchpad {
    address public tokenAddress;

    constructor() {}

    function setTokenAddress(address _tokenAddress) external {
        tokenAddress = _tokenAddress;
    }

    function mint(uint256 amount) public {
        ITheKabalMinter(tokenAddress).batchMint(msg.sender, amount);
    }
}
