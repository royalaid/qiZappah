// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "openzeppelin-contracts/token/ERC721/IERC721.sol";

interface ICrossChainStablecoin is IERC721 {
    function depositCollateral(uint256 vaultId, uint256 amount) external;
    function withdrawCollateral(uint256 vaultId, uint256 amount) external;
    function exists(uint256 vaultId) external view returns (bool);
    function approve(address to, uint256 tokenId) external override;
    function createVault() external returns (uint256);
}