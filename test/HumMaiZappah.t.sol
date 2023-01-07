// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/interfaces/IERC721Receiver.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./FakeERC20.sol";
import "./ERC20TokenFaker.sol";
import "../src/HumMaiZappah.sol";

contract HumMaiTest is Test, ERC20TokenFaker {
    HummusQiZappah qiZappah;
    ERC20 MAI;
    IPoolSecondaryV2 pool;
    IMasterHummusV2 masterHum;
    uint256 pid;

    function setUp() public {
        MAI = ERC20(0xdFA46478F9e5EA86d57387849598dbFB2e964b02);
        pool = IPoolSecondaryV2(0x5b7e71F6364DA1716c44a5278098bc46711b9516);
        masterHum = IMasterHummusV2(0x9cadd693cDb2B118F00252Bb3be4C6Df6A74d42C);
        pid = 5;
        qiZappah = new HummusQiZappah();
    }

    function testHumMaiZapIn() public {
        address[] memory c = new address[](3);
        c[0] = address(MAI);
        c[1] = address(pool);
        c[2] = address(masterHum);
        qiZappah.addChainToWhiteList(c);
        fakeOutERC20(address(MAI))._setBalance(address(this), 10e18);
        uint256 amt = 10e18;
        assertEq(MAI.balanceOf(address(this)), amt);
        console.log("%s:%s", "Starting collateral", MAI.balanceOf(address(this)));

        MAI.approve(address(qiZappah), amt);
        qiZappah.beefyZapToVault(amt, pid, address(MAI), address(pool), address(masterHum));
        assertEq(MAI.balanceOf(address(this)), 0);
        (uint depositedAmount,,) = masterHum.userInfo(pid, address(this));
        console.log("%s:%s", "deposited amount", depositedAmount);

    }
}
