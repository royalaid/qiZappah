// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./FakeERC20.sol";
import "./ERC20TokenFaker.sol";
import "../src/QiZappah.sol";
import "openzeppelin-contracts/interfaces/IERC721Receiver.sol";

contract ContractTest is Test, ERC20TokenFaker, IERC721Receiver {
    QiZappah qiZappah;
    ICrossChainStablecoin vault;
    ERC20 weth;

    function setUp() public {
        weth = ERC20(0x4200000000000000000000000000000000000006);
        qiZappah = new QiZappah();
        vault = ICrossChainStablecoin(0x929596C08815cF9d97e3c8280017Dc74bE81C12c);
    }

    function testZapInZapOut() public {
       address YVWETH = 0x5B977577Eb8a480f63e11FC615D6753adB8652Ae;
       address PERF = 0x881Dace37C6fa4a5364Bf4806D0e9F8DAD8098e8;
       
        qiZappah.addChainToWhiteList(address(weth), YVWETH, PERF, address(vault));
        uint vaultId = vault.createVault();
        console.log("%s:%s", "vaultId", vaultId);

        fakeOutERC20(address(weth))._setBalance(address(this), 10e18);
        assertEq(weth.balanceOf(address(this)), 10e18);
        console.log("%s:%s", "Starting collateral", weth.balanceOf(address(this)));

        vault.approve(address(qiZappah), vaultId);
        weth.approve(address(qiZappah), 10e18);
        qiZappah.beefyZapToVault(10e18, vaultId, address(weth), YVWETH, PERF, address(vault));
        assertEq(weth.balanceOf(address(this)), 0);
        uint collateral = vault.vaultCollateral(vaultId);
        console.log("%s:%s", "collateral", collateral);

        vault.approve(address(qiZappah), vaultId);
        qiZappah.beefyZapFromVault(collateral, vaultId, address(weth), YVWETH, PERF, address(vault));
        collateral = vault.vaultCollateral(vaultId);
        console.log("%s:%s", "collateral", collateral);
        console.log("%s:%s", "weth", weth.balanceOf(address(this)));
    }

    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
