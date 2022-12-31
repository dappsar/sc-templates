// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Base64.sol";

contract Heroes is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIdCounter;

    using Strings for uint256;
    using Strings for uint128;

    struct DataNFT {
        string name;
        string description;
        string imageIPFS;
        uint128 level;
        uint128 life;
    }

    mapping(uint256 => DataNFT) public tokensData;

    constructor() ERC721("MyToken", "MTK") {}

    function safeMint(string memory name, string memory description, string memory imageIPFS, uint128 level, uint128 life) public {
        tokenIdCounter.increment();
        uint256 currentId = tokenIdCounter.current();
        
        tokensData[currentId] = DataNFT(
            name,
            description,
            imageIPFS,
            level,
            uint128(block.timestamp) + life
        );

        _safeMint(msg.sender, currentId);
    }

    function incrementLevel(uint256 tokenId) public {
        tokensData[tokenId].level++;
    }

    function decrementLevel(uint256 tokenId) public {
        require(tokensData[tokenId].level > 0, "Level is zero");
        tokensData[tokenId].level--;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        return getTokenURI(tokenId);
    }

    function getTokenURI(uint256 tokenId) internal view returns (string memory){
        DataNFT memory data = tokensData[tokenId];

        uint256 diffSeconds = data.life - uint128(block.timestamp);
        uint256 _hours = diffSeconds / 1 hours;
        uint256 _minutes = (diffSeconds % 1 hours) / 1 minutes;
        uint256 _seconds = ((diffSeconds % 1 hours) % 1 minutes) / 1 seconds;

        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "', data.name, '",',
                '"description": "', data.description, '",',
                '"image": "ipfs://',  data.imageIPFS, '",',
                '"attributes": [',
                    '{', 
                        '"trait_type": "Level",', 
                        '"value": "', data.level.toString(), '"',
                    '},', 
                    '{', 
                        '"trait_type": "Life",', 
                        '"value": "', _hours.toString(), ':', _minutes.toString(), ':', _seconds.toString(), '"'
                    '}', 
                ']'
            '}'
        );

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }
}