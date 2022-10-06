// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC1155.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract MetaversityGenesis is ERC1155, Owned, ReentrancyGuard {
    /// @dev of the form ipfs://gateaway/
    string public tokenURI;
    /// @dev reserve supply for airdrop
    uint256 public constant RESERVE_SUPPLY = 12;
    /// @dev airdrop status
    bool public end;

    constructor(string memory _tokenURI) Owned(msg.sender) {
        tokenURI = _tokenURI;
    }

    function airdrop(address[] memory holders) public onlyOwner {
        require(!end, "Genesis Compelte!");
        for (uint256 x = 1; x <= RESERVE_SUPPLY; x++) {
            _mint(msg.sender, x, 1, "");
        }
        uint256 id = RESERVE_SUPPLY + 1;
        for (uint256 x = 0; x < holders.length; x++) {
            _mint(holders[x], id, 1, "");
            id++;
        }
        end = true;
    }

    /// @notice returns uri by id
    /// @return string with the format ipfs://<uri>/id.json
    function uri(uint256 id) public view override returns (string memory) {
        return string.concat(tokenURI, "/", Strings.toString(id), ".json");
    }
}