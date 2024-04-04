// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "./lib/ERC721.sol";
import "./lib/Owned.sol";
import "./lib/LibString.sol";
import "./lib/IMetadata.sol";

/// @author 0xFueki (https://x.com/0xFueki)
contract TheKabal is ERC721, Owned {
    using LibString for uint256;

    /* (•_• ) Event (•_• ) */

    event MetadataUpdate(uint256 _tokenId);

    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

    /* (•_• ) Minter Storage (•_• ) */

    address public minterAddress;

    bool public minterAddressLock = false;

    /* (•_• ) Burner Storage (•_• ) */

    address public burnerAddress;

    bool public burnerAddressLock = false;

    /* (•_• ) Metadata Storage (•_• ) */

    string public baseURI;

    address public metadataAddress;

    bool public metadataAddressLock = false;

    /* (•_• ) SBT Storage (•_• ) */

    bool transferLock = true;

    /* (•_• ) Constructor (•_• ) */

    constructor() ERC721("The Kabal", "KABAL") Owned(msg.sender) {}

    /* (•_• ) Mint Logic (•_• ) */

    modifier onlyMinter() {
        require(msg.sender == minterAddress, "NOT_MINTER");

        _;
    }

    function mint(address to, uint256 id) public onlyMinter {
        _mint(to, id);
    }

    function safeMint(address to, uint256 id) public onlyMinter {
        _safeMint(to, id);
    }

    function mintPrivate(address to, uint256 id) public onlyOwner {
        _mint(to, id);
    }

    function safeMintPrivate(address to, uint256 id) public onlyOwner {
        _safeMint(to, id);
    }

    function setMinterAddress(address _minteraddress) external onlyOwner {
        require(!minterAddressLock, "MINTER_ADDRESS_LOCKED");

        minterAddress = _minteraddress;
    }

    function lockMinter() external onlyOwner {
        minterAddressLock = true;
    }

    /* (•_• ) Burn Logic (•_• ) */

    modifier onlyBurner() {
        require(msg.sender == minterAddress, "NOT_BURNER");

        _;
    }

    function burn(uint256 id) public onlyBurner {
        _burn(id);
    }

    function burnPrivate(uint256 id) public onlyOwner {
        _burn(id);
    }

    function setBurnerAddress(address _burnerAddress) external onlyOwner {
        require(!burnerAddressLock, "BURNER_ADDRESS_LOCKED");

        burnerAddress = _burnerAddress;
    }

    function lockBurner() external onlyOwner {
        burnerAddressLock = true;
    }

    /* (•_• ) Transfer Logic (•_• ) */

    function approve(address spender, uint256 id) public override {
        require(!transferLock, "TRANSFER_LOCKED");

        super.approve(spender, id);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override {
        require(!transferLock, "TRANSFER_LOCKED");

        super.setApprovalForAll(operator, approved);
    }

    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(!transferLock, "TRANSFER_LOCKED");

        super.transferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public override {
        require(!transferLock, "TRANSFER_LOCKED");

        super.safeTransferFrom(from, to, id);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public override {
        require(!transferLock, "TRANSFER_LOCKED");

        super.safeTransferFrom(from, to, id, data);
    }

    function transferSBT(address to, uint256 id) public onlyAdmins {
        address from = _ownerOf[id];

        require(from != address(0), "NOT_MINTED");

        _transfer(from, to, id);
    }

    function toggleTransfer(bool toggle) external onlyOwner {
        transferLock = toggle;
    }

    /* (•_• ) Metadata Logic (•_• ) */

    modifier onlyMetadata() {
        require(msg.sender == metadataAddress, "NOT_METADATA_ADDRESS");

        _;
    }

    function emitMetadataUpdate(uint256 _tokenId) external onlyMetadata {
        emit MetadataUpdate(_tokenId);
    }

    function emitBatchMetadataUpdate(
        uint256 _fromTokenId,
        uint256 _tokenId
    ) external onlyMetadata {
        emit BatchMetadataUpdate(_fromTokenId, _tokenId);
    }

    function emitAllMetadataUpdate() external onlyMetadata {
        emit MetadataUpdate(type(uint256).max);
    }

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function setMetadataAddress(address _metadataAddress) external onlyOwner {
        require(!metadataAddressLock, "METADATA_ADDRESS_LOCKED");

        metadataAddress = _metadataAddress;
    }

    function lockMetadata() external onlyOwner {
        metadataAddressLock = true;
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

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721) returns (bool) {
        return
            interfaceId == 0x49064906 || super.supportsInterface(interfaceId);
    }
}
