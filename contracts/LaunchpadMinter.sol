// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

interface TheKabalMinter {
    function batchMint(address to, uint256 amount) external;
}

contract LaunchpadMinter {
    address tokenAddress;

    constructor() {}

    function setTokenAddress(address _tokenAddress) external {
        tokenAddress = _tokenAddress;
    }

    function mint(address to, uint256 amount) public {
        TheKabalMinter(tokenAddress).batchMint(to, amount);
    }
}
