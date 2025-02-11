// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossRealm is Ownable, ReentrancyGuard {
    // State variables
    mapping(address => uint256) public playerLevels;
    mapping(address => mapping(string => uint256)) public playerAssets;
    mapping(string => bool) public validRealms;
    mapping(address => string) public playerCurrentRealm;
    
    // Structs
    struct Asset {
        string id;
        string realm;
        uint256 quantity;
        bool transferable;
    }
    
    // Events
    event LevelUp(address indexed player, uint256 newLevel);
    event AssetTransferred(address indexed from, address indexed to, string assetId, uint256 amount);
    event RealmTransfer(address indexed player, string fromRealm, string toRealm);
    event NewRealmAdded(string realmId);
    event AssetCreated(string assetId, string realm, bool transferable);
    
    // Modifiers
    modifier validRealm(string memory realm) {
        require(validRealms[realm], "Invalid realm");
        _;
    }
    
    modifier sufficientAssets(string memory assetId, uint256 amount) {
        require(playerAssets[msg.sender][assetId] >= amount, "Insufficient assets");
        _;
    }
    
    constructor() {
        // Initialize with default realm
        validRealms["genesis"] = true;
        emit NewRealmAdded("genesis");
    }
    
    // Realm Management Functions
    function addRealm(string memory realmId) external onlyOwner {
        require(!validRealms[realmId], "Realm already exists");
        validRealms[realmId] = true;
        emit NewRealmAdded(realmId);
    }
    
    function enterRealm(string memory realmId) external validRealm(realmId) {
        string memory previousRealm = playerCurrentRealm[msg.sender];
        playerCurrentRealm[msg.sender] = realmId;
        emit RealmTransfer(msg.sender, previousRealm, realmId);
    }
    
    // Player Management Functions
    function levelUp() external {
        require(playerLevels[msg.sender] < 100, "Max level reached");
        playerLevels[msg.sender]++;
        emit LevelUp(msg.sender, playerLevels[msg.sender]);
    }
    
    // Asset Management Functions
    function mintAsset(
        address player,
        string memory assetId,
        uint256 amount
    ) external onlyOwner {
        playerAssets[player][assetId] += amount;
        emit AssetTransferred(address(0), player, assetId, amount);
    }
    
    function transferAsset(
        address to,
        string memory assetId,
        uint256 amount
    ) external sufficientAssets(assetId, amount) nonReentrant {
        require(to != address(0), "Invalid recipient");
        
        playerAssets[msg.sender][assetId] -= amount;
        playerAssets[to][assetId] += amount;
        
        emit AssetTransferred(msg.sender, to, assetId, amount);
    }
    
    // Cross-Realm Transfer Functions
    function crossRealmTransfer(
        address to,
        string memory assetId,
        uint256 amount,
        string memory targetRealm
    ) external 
        sufficientAssets(assetId, amount) 
        validRealm(targetRealm) 
        nonReentrant 
    {
        require(to != address(0), "Invalid recipient");
        require(keccak256(bytes(playerCurrentRealm[to])) == keccak256(bytes(targetRealm)), 
                "Recipient not in target realm");
        
        playerAssets[msg.sender][assetId] -= amount;
        playerAssets[to][assetId] += amount;
        
        emit AssetTransferred(msg.sender, to, assetId, amount);
    }
    
    // View Functions
    function getPlayerLevel(address player) external view returns (uint256) {
        return playerLevels[player];
    }
    
    function getPlayerAssetBalance(address player, string memory assetId) 
        external view returns (uint256) 
    {
        return playerAssets[player][assetId];
    }
    
    function getPlayerCurrentRealm(address player) 
        external view returns (string memory) 
    {
        return playerCurrentRealm[player];
    }
}
