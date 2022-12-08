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
        vault = ICrossChainStablecoin(0xD13Ed4879DCF81C181DA82C46F4D0689b0734F23);
    }

    function testZapInZapOut() public {
       address YVWETH = 0xA628c54C850ff1077b5C954491D19EccE7e321fF;
       address PERF = 0x5A6325c3E3c88Dbcd52a8d55a31b342d09fa7982;
       
        qiZappah.addChainToWhiteList(address(weth), YVWETH, PERF, address(vault));
        uint vaultId = vault.createVault();
        console.log("%s:%s", "vaultId", vaultId);

        fakeOutERC20(address(weth))._setBalance(address(this), 10e18);
        assertEq(weth.balanceOf(address(this)), 10e18);

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

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
