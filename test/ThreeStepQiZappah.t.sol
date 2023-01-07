// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/interfaces/IERC721Receiver.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./FakeERC20.sol";
import "./ERC20TokenFaker.sol";
import "../src/ThreeStepQiZappah.sol";

contract ContractTest is Test, ERC20TokenFaker, IERC721Receiver {
    ThreeStepQiZappah qiZappah;
    ICrossChainStablecoin vault;
    ERC20 wsteth;

    function setUp() public {
        wsteth = ERC20(0x1F32b1c2345538c0c6f582fCB022739c4A194Ebb);
        qiZappah = new ThreeStepQiZappah();
        vault = ICrossChainStablecoin(0xdB5D7086C5198e8A4da5BD2972c8584309c3759e);
    }

    function testZapInZapOut() public {
       address PERF = 0x77965B3282DFdeB258B7ad77e833ad7Ee508B878;

        qiZappah.addChainToWhiteList(address(wsteth), PERF, address(vault));
        uint vaultId = vault.createVault();
        console.log("%s:%s", "vaultId", vaultId);

        fakeOutERC20(address(wsteth))._setBalance(address(this), 10e18);
        assertEq(wsteth.balanceOf(address(this)), 10e18);
        console.log("%s:%s", "Starting collateral", wsteth.balanceOf(address(this)));

        vault.approve(address(qiZappah), vaultId);
        wsteth.approve(address(qiZappah), 10e18);
        qiZappah.beefyZapToVault(10e18, vaultId, address(wsteth), PERF, address(vault));
        assertEq(wsteth.balanceOf(address(this)), 0);
        uint collateral = vault.vaultCollateral(vaultId);
        console.log("%s:%s", "collateral", collateral);

        vault.approve(address(qiZappah), vaultId);
        qiZappah.beefyZapFromVault(collateral, vaultId, address(wsteth), PERF, address(vault));
        collateral = vault.vaultCollateral(vaultId);
        console.log("%s:%s", "collateral", collateral);
        console.log("%s:%s", "wsteth", wsteth.balanceOf(address(this)));
    }

    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
