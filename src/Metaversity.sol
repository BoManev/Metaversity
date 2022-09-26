// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "solmate/auth/Owned.sol";
import "solmate/tokens/ERC721.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract Metaversity is ERC721, Owned, ReentrancyGuard {
    using Strings for uint256;

    /// @dev supply for airdrop
    uint256 public constant AIRDROP_SUPPLY = 15;

    /// @dev supply for genesis mint
    uint256 public constant GENESIS_SUPPLY = 85;
    /// @dev is genesis mint active
    bool public isGenesisActive;
    /// @dev duration of genesis mint
    /// @dev after duration, remaining supply is free-for-all
    /// @dev 2 days / 13.5 avg. block time
    uint256 public GENESIS_DURATION_BLOCKS = 12800;
    /// @dev allow list for genesis
    mapping(address => bool) private _genesisList;
    /// @dev number of addresses in allow list
    uint256 private _currentGenesisCount;
    /// @dev start block for genesis
    uint256 private _genesisBlockStamp;

    /// @dev total supply
    uint256 public constant TOTAL_SUPPLY = 1000;
    /// @dev mint price for regular mint (wei)
    uint256 public REGULAR_PRICE;
    /// @dev current genesis supply
    uint256 private _currentID;
    /// @dev is regular mint active
    bool isRegularActive;

    /// @dev of the form ipfs://gateaway/
    string public baseTokenURI;

    constructor(string memory _baseTokenURI) ERC721("Metaversity", "MTTY") Owned(msg.sender) {
        baseTokenURI = _baseTokenURI;
    }

    /*//////////////////////////////////////////////////////////////////////
                                    USERS
    //////////////////////////////////////////////////////////////////////*/

    function mintGenesis() external payable nonReentrant {
        require(isGenesisActive && _currentID >= AIRDROP_SUPPLY, "Genesis mint is not active");
        if (block.number - _genesisBlockStamp <= GENESIS_DURATION_BLOCKS) {
            require(_genesisList[msg.sender], "Not eligible for Genesis");
            _genesisList[msg.sender] = false;
        }
        require(_currentID + 1 <= GENESIS_SUPPLY, "SOLD OUT");
        unchecked {
            _currentID += 1;
        }
        _safeMint(msg.sender, _currentID);
    }

    function mintRegular() external payable nonReentrant {
        require(isRegularActive && _currentID > GENESIS_SUPPLY, "Regular mint is not active");
        require(_currentID + 1 <= TOTAL_SUPPLY, "SOLD OUT");
        require(REGULAR_PRICE <= msg.value, "Not enough Ether");

        unchecked {
            _currentID += 1;
        }
        _safeMint(msg.sender, _currentID);
    }

    /// @notice token must be minted
    function tokenURI(uint256 tokenID) public view override returns (string memory) {
        ownerOf(tokenID);
        return bytes(baseTokenURI).length > 0 ? string(abi.encodePacked(baseTokenURI, tokenID.toString(), ".json")) : "";
    }

    function genesisSupply() external view returns (uint256) {
        return GENESIS_SUPPLY - _currentID;
    }
    

    function genesisBlocks() external view returns (uint256) {
        return GENESIS_DURATION_BLOCKS - _genesisBlockStamp;
    }

    /*//////////////////////////////////////////////////////////////////////
                                        ADMIN
    //////////////////////////////////////////////////////////////////////*/

    function withdraw(address payable to) public onlyOwner {
        (bool success,) = payable(to).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }

    function mintAirDrop() public onlyOwner {
        unchecked {
            _currentID += AIRDROP_SUPPLY;
        }
        for (uint256 x = 0; x <= AIRDROP_SUPPLY; x++) {
            _mint(msg.sender, x);
        }
    }

    /// @notice add to allow list
    function addToGenesis(address[] calldata addresses) external onlyOwner {
        require(addresses.length + _currentGenesisCount <= GENESIS_SUPPLY, "Exceeding Genesis supply");
        for (uint256 i = 0; i < addresses.length; i++) {
            _genesisList[addresses[i]] = true;
        }
    }

    /// @notice remove from allow list
    function removeFromGenesis(address target) external onlyOwner {
        require(_genesisList[msg.sender], "Target not found in allow list");
        _genesisList[target] = false;
    }

    /// @dev records block number
    function startGenesis() external onlyOwner {
        isGenesisActive = true;
        _genesisBlockStamp = block.number;
    }

    function stopGenesis() external onlyOwner {
        isGenesisActive = false;
    }

    /// @notice start/stop regular mint
    function toggleRegular() external onlyOwner {
        isRegularActive = !isRegularActive;
    }

    /// @param _price in wei
    function setRegularPrice(uint256 _price) external onlyOwner {
        REGULAR_PRICE = _price;
    }

    /// @param _baseTokenURI new ipfs hash
    function setBaseTokenURI(string memory _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    receive() external payable {}
}
