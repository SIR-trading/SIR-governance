The on-chain-governance is heavily influenced by the following github repos:
 - Uniswap (https://github.com/Uniswap/governance/tree/master/contracts)
 - Compound finance (https://github.com/compound-finance/compound-protocol/tree/v2.8.1) --> Uniswap based off of this
 - MakerDao (https://github.com/makerdao/governance-manual/tree/main/governance)
 - Aave (https://github.com/aave/governance-v2, https://github.com/aave/governance-crosschain-bridges/blob/master/contracts/BridgeExecutorBase.sol)


 Uniswap and Compund Finance make use of a Timelock contract which acts as a multisig that has a governance contract act as the admin. Aave has a newer contracts with different governance models based off this, and some across multiple chains.

 MakerDao has good documentation of off-chain to on-chain governance, which is usefule.

 The governance contract is replaceable, as the admin of the Timelock can be changed by the governance contract itself. This essentially makes the governance upgradable, but not the Timelock.