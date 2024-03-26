// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./lib/ERC721Kabal.sol";
import "./lib/LibString.sol";
import "./lib/IMetadata.sol";

abstract contract TheKabal is ERC721 {
    using LibString for uint256;

    /*//////////////////////////////////////////////////////////////
                            Errors
    //////////////////////////////////////////////////////////////*/

    error SenderNotMinter();
    error MetadataOwnershipRenounced();
    error MinterOwnershipRenounced();

    /*//////////////////////////////////////////////////////////////
                            Minter Storage
    //////////////////////////////////////////////////////////////*/

    address public minteraddress;
    bool public isMinterLocked = false;

    /*//////////////////////////////////////////////////////////////
                            Metadata Storage
    //////////////////////////////////////////////////////////////*/

    string public baseURI;
    address public metadataAddress;
    bool public isMetadataLocked = false;

    /*//////////////////////////////////////////////////////////////
                            Constructor
    //////////////////////////////////////////////////////////////*/

    constructor() ERC721("The Kabal", "KABAL") {}

    /*//////////////////////////////////////////////////////////////
                            Mint Logic
    //////////////////////////////////////////////////////////////*/

    modifier onlyMinter() {
        if (msg.sender != minteraddress) revert SenderNotMinter();
        _;
    }

    function mint(address to, uint256 id) public onlyMinter {
        _mint(to, id);
    }

    function mintPrivate(address to, uint256 id) public onlyOwner {
        _mint(to, id);
    }

    function setMinterAddress(address _minteraddress) external onlyOwner {
        if (isMinterLocked) revert MinterOwnershipRenounced();
        minteraddress = _minteraddress;
    }

    function lockMinter() external onlyOwner {
        isMinterLocked = true;
    }

    /*//////////////////////////////////////////////////////////////
                            Metadata Logic
    //////////////////////////////////////////////////////////////*/

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function setMetadataAddress(address _metadataAddress) external onlyOwner {
        if (isMetadataLocked) revert MetadataOwnershipRenounced();
        metadataAddress = _metadataAddress;
    }

    function tokenURI(
        uint256 _tokenId
    ) public view override returns (string memory) {
        require(_ownerOf[_tokenId] != address(0), "NOT_MINTED");

        if (address(metadataAddress) != address(0)) {
            return IAsuraMetadata(metadataAddress).tokenURI(_tokenId);
        }

        return
            bytes(baseURI).length > 0
                ? string.concat(baseURI, _tokenId.toString())
                : "";
    }
}
