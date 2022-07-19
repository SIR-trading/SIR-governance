// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

interface ISIRToken is IERC20 {

    function TOKENS_PER_BLOCK() external returns(uint128);
    function TOKENS_TO_LP() external returns(uint128);
    function TOKENS_TO_DAO() external returns(uint128);
    function TOKENS_TO_CONTRIBUTORS() external returns(uint128);

    function treasuryAddr() external returns(address);
    function lpAddr() external returns(address);
    function CONTRIBUTORS_ADDR() external returns(address);

    function withdrawToLP() external;
    function withdrawToTreasury() external;
    function withdrawToContributors() external;

    function updateLpAddress(address _addr) external;
    function updateTreasuryAddress(address _addr) external;

    function pendingForLP() external view returns (uint256);
    function pendingForTreasury() external view returns (uint256);
    function pendingForContributors() external view returns (uint256 amount);

    function burn(uint256 amount) external;
}
