// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import '../interfaces/ITimelock.sol';
import '../interfaces/ISIRToken.sol';
import '../interfaces/IGovernor.sol';

/// @notice First iteration of the Governor contract. A successor contract can be voted in (vote to change Timelock admin).
contract preReleaseGovernor is IGovernor{
    /// @notice The name of this contract
    string public constant name = "SIR Pre-release Governor";

    uint public proposalCount;

    /// @notice The address of the SIR Protocol Timelock
    ITimelock public timelock;

    /// @notice The address of the SIR governance token
    ISIRToken public sir;

    /// @notice The official record of all proposals ever proposed
    mapping (uint => Proposal) public proposals;

    /// @notice The latest proposal for each proposer
    mapping (address => uint) public latestProposalIds;

    /// @notice The EIP-712 typehash for the contract's domain
    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");

    /// @notice The EIP-712 typehash for the ballot struct used by the contract
    bytes32 public constant BALLOT_TYPEHASH = keccak256("Ballot(uint256 proposalId,bool support)"); 

    constructor(address timelockAddr, address sirAddr){
        timelock = ITimelock(timelockAddr);
        sir = ISIRToken(sirAddr);
    }

    /// @notice The number of votes in support of a proposal required in order for a quorum to be reached and for a vote to succeed
    function quorumVotes() public view returns (uint) { return sir.totalSupply() / 25; } // 4% of SIR tokens in existence

    /// @notice The number of votes required in order for a voter to become a proposer
    function proposalThreshold() public view returns (uint) { return sir.totalSupply() / 100; } // 1% of SIR tokens

    /// @notice The delay before voting on a proposal may take place, once proposed
    function votingDelay() public pure returns (uint) { return 1; } // 1 block

    /// @notice The duration of voting on a proposal, in blocks
    function votingPeriod() public pure returns (uint) { return 40_320; } // ~7 days in blocks (assuming 15s blocks)


    // Functions to add:
    /**
        propose,
        queue,
        execute,
        cancel,
        getActions,
        getProposalState,
        castVote,
        castVoteBySig, //Actually unsure if this costs gas.
    
     */



}