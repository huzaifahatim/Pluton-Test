// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721Enumerable, Ownable {
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;


    IERC20 public tokenAddress;

    string public baseExtension = ".json";
    string public unrevealedBaseURI;
    string private revealedBaseURI;
    uint256 public cost = 10 * 10 ** 10;
    uint256 public maxSupply = 2;
    bool public paused = false;
    bool public revealed = false;
    


   constructor(
       address _tokenAddress,
       string memory _unrevealedBaseURI,
       string memory _revealedBaseURI
       ) 
       ERC721("MyNFT", "MTK") {
        tokenAddress = IERC20(_tokenAddress);
        unrevealedBaseURI = _unrevealedBaseURI;
        revealedBaseURI =  _revealedBaseURI; 
    }

    
    function _baseURI() internal view virtual override returns (string memory) {


        if (revealed) { 
        return revealedBaseURI;
        }

        else {
            return unrevealedBaseURI;

        }

    }
    
    function mint() public payable {
        require(!paused);
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId <= maxSupply, "Exceed Limit");
        
        tokenAddress.transferFrom(msg.sender, address(this), cost);
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

        
        if (tokenId == maxSupply) { 
            revealed = true;
        }

        else {
            revealed = false;

        }
 
    }

    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

 
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI_ = _baseURI();

        if (revealed) {
            return bytes(baseURI_).length > 0 ? string(abi.encodePacked(revealedBaseURI, Strings.toString(tokenId), baseExtension)) : "";
        } else {
            return string(abi.encodePacked(unrevealedBaseURI, "hidden.json"));
        }
    }


    //only owner
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function withdrawToken() public onlyOwner {
        tokenAddress.transfer(msg.sender, tokenAddress.balanceOf(address(this)));
    }
}