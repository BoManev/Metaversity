// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "../src/MetaversityGenesis.sol";


contract ContractTest is Test {
    address[] holders;
    MetaversityGenesis nft;
    function setUp() public {
        vm.prank(0x0000000000000000000000000000000000000001);
        nft = new MetaversityGenesis("baseUri/");
        holders.push(0x0000000000000000000000000000000000000002);
        holders.push(0x0000000000000000000000000000000000000003);
    }

    function testAirdrop() public {
        vm.prank(0x0000000000000000000000000000000000000001);
        nft.airdrop(holders);
        assertEq(nft.balanceOf(0x0000000000000000000000000000000000000001, 1), 1);
        assertEq(nft.balanceOf(0x0000000000000000000000000000000000000001, nft.RESERVE_SUPPLY()), 1);
        assertEq(nft.balanceOf(0x0000000000000000000000000000000000000002, 13), 1);
        assertEq(nft.balanceOf(0x0000000000000000000000000000000000000003, 14), 1);
    }
}