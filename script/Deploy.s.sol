// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../src/Metaversity.sol";

contract MyScript is Script {
    function run() external {
        string memory mnemonic = "test test test test test test test test test test test junk";
        uint256 privateKey = vm.deriveKey(mnemonic, 0);
        address deployer = vm.rememberKey(privateKey);
        vm.startBroadcast(deployer);
        Metaversity nft = new Metaversity("baseUri");
        vm.stopBroadcast();
    }
}