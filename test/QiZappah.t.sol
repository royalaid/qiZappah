// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./FakeERC20.sol";
import "./ERC20TokenFaker.sol";
import "../src/QiZappah.sol";

contract ContractTest is Test {
    QiZappah qiZappah;
    ICrossChainStablecoin vault;
    ERC20TokenFaker faker;

    function setUp() public {
        qiZappah = new QiZappah();
        vault = ICrossChainStablecoin(0xD13Ed4879DCF81C181DA82C46F4D0689b0734F23);
        FakeERC20 fakeToken = faker.fakeOutERC20(address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2));
    }

    function testExample() public {
        /*
        WETH ->
        Call deposit on yearn vault @ 0xA628c54C850ff1077b5C954491D19EccE7e321fF
        Call enter on PerfToken @ 0x5A6325c3E3c88Dbcd52a8d55a31b342d09fa7982
        Call depositCollateral @ 0xD13Ed4879DCF81C181DA82C46F4D0689b0734F23
        */
       
        qiZappah.addChainToWhiteList(0x4200000000000000000000000000000000000006, 0xA628c54C850ff1077b5C954491D19EccE7e321fF,
                                     0x5A6325c3E3c88Dbcd52a8d55a31b342d09fa7982, 0xD13Ed4879DCF81C181DA82C46F4D0689b0734F23);
        uint vaultId = vault.createVault();
        console.log("%s:%s", "vaultId", vaultId);
    }
}
