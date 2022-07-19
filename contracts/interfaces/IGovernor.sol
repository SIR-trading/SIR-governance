// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGovernor {

/// @param id (unique) for looking up a proposal
/// @param proposer:Creator of the proposal
/// @param eta: The timestamp that the proposal will be available for execution, set once the vote succeeds
/// @param targets: the ordered list of target addresses for calls to be made
/// @param values: The ordered list of values (i.e. msg.value) to be passed to the calls to be made
/// @param signatures: The ordered list of function signatures to be called
/// @param calldatas: The ordered list of calldata to be passed to each call
/// @param startBlock: The block at which voting begins: holders must delegate their votes prior to this block
/// @param endBlock: The block at which voting ends: votes must be cast prior to this block
/// @param forVotes: Current number of votes in favor of this proposal
/// @param againstVotes: Current number of votes in opposition to this proposal
/// @param canceled: Flag marking whether the proposal has been canceled
/// @param executed: Flag marking whether the proposal has been executed
/// @param Receipts of ballots for the entire set of voters
struct Proposal { 
        uint id;
        address proposer;
        uint eta;
        address[] targets;
        uint[] values;
        string[] signatures;
        bytes[] calldatas;
        uint startBlock;
        uint endBlock;
        uint forVotes;
        uint againstVotes;
        bool canceled; 
        bool executed;
        mapping (address => Receipt) receipts;
    }

/// @notice Ballot receipt record for a voter
/// @param hasVoted: Whether or not a vote has been cast
/// @param support: Whether or not the voter supports the proposal
/// @param votes: The number of votes the voter had, which were cast
    struct Receipt {      
        bool hasVoted;
        bool support; 
        uint votes;
    }

/// @notice Possible states that a proposal may be in
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    /// @notice An event emitted when a new proposal is created
    event ProposalCreated(uint id, address proposer, address[] targets, uint[] values, string[] signatures, bytes[] calldatas, uint startBlock, uint endBlock, string description);

    /// @notice An event emitted when a vote has been cast on a proposal
    event VoteCast(address voter, uint proposalId, bool support, uint votes);

    /// @notice An event emitted when a proposal has been canceled
    event ProposalCanceled(uint id);

    /// @notice An event emitted when a proposal has been queued in the Timelock
    event ProposalQueued(uint id, uint eta);

    /// @notice An event emitted when a proposal has been executed in the Timelock
    event ProposalExecuted(uint id);


}