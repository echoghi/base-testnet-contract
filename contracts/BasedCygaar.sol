// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

error SoldOut();
error InvalidQuantity();
error WithdrawFailed();

contract BasedCygaar is Ownable, ERC721A, ReentrancyGuard {
  using Strings for uint256;

  string public _baseTokenURI;
  
  uint256 public price = 0 ether;
  uint256 public constant maxSupply = 10000;
  uint256 public maxMintAmountPerTx = 5;

  constructor() ERC721A("Based Cygaar", "CYGAAR") {
    _baseTokenURI = "https://ipfs.io/ipfs/QmZcH4YvBVVRJtdn4RdbaqgspFU8gH6P9vomDpBVpAL3u4/9649";
  }

  function mint(uint256 _quantity) external payable {
    if(_quantity < 1 || _quantity > maxMintAmountPerTx) revert InvalidQuantity();
    if (totalSupply() + _quantity > maxSupply) revert SoldOut();

    _safeMint(msg.sender, _quantity);
  }

  function getOwnershipData(uint256 tokenId)
    external
    view
    returns (TokenOwnership memory)
  {
    return _ownershipOf(tokenId);
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return currentBaseURI;
  }

  function setPrice(uint256 _price) public onlyOwner {
    price = _price;
  }

  function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    if(!os) revert WithdrawFailed();
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }
}