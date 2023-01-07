
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "./AbstractZappah.sol";
import "./interfaces/humMai/IMasterHummusV2.sol";
import "./interfaces/humMai/IPoolSecondaryV2.sol";


contract HummusQiZappah is AbstractZappah{

    event AssetZapped(address indexed asset, uint256 indexed amount, uint256 pid);

    error MustDepositMoreThan0(uint256 amount);
    error InsuccficantTokenAllowance(uint256 allowance, uint256 amount);

    // address constant MAI = 0xdFA46478F9e5EA86d57387849598dbFB2e964b02;
    struct AssetChain {
        IERC20 asset;
        IPoolSecondaryV2 pool;
        IMasterHummusV2 masterHummus;
    }

    function _beefyZapToVault(uint256 amount, uint256 pid, address[] memory _chain) internal whenNotPaused returns (uint256) {
        if(amount <= 0){
            revert MustDepositMoreThan0(amount);
        }

        AssetChain memory chain = AssetChain(IERC20(_chain[0]), IPoolSecondaryV2(_chain[1]), IMasterHummusV2(_chain[2]));//, ICrossChainStablecoin(_chain[2]));

        uint256 allowance = chain.asset.allowance(msg.sender, address(this));
        if(allowance < amount){
            revert InsuccficantTokenAllowance(allowance, amount);
        }

        chain.asset.transferFrom(msg.sender, address(this), amount);
        //Approve Mai to MasterChef
        chain.asset.approve(address(chain.pool), amount);
        //Deposit into IPoolSeconaryV2 & receive HLP-MAI
        uint256 lpTokenAmount = chain.pool.deposit(address(chain.asset), amount, address(this), block.timestamp + 5 minutes);
        IERC20 lpToken = IERC20(chain.pool.assetOf(address(chain.asset)));

        //Stake into MasterHummus
        lpToken.approve(address(chain.masterHummus), lpTokenAmount);
        chain.masterHummus.depositFor(pid, lpTokenAmount, msg.sender);
        emit AssetZapped(address(chain.asset), amount, pid);
        return lpTokenAmount;
    }

    function beefyZapToVault(uint256 amount, uint256 pid, address _asset, address _perfToken, address _mooAssetVault) external whenNotPaused returns (uint256) {
        address[] memory chain = new address[](3);
        chain[0] = _asset;
        chain[1] = (_perfToken);
        chain[2] = (_mooAssetVault);
        require(isWhiteListed(chain), "mooToken chain not in on allowable list");
        return _beefyZapToVault(amount, pid, chain);
    }
}