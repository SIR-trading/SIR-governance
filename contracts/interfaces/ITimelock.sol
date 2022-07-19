// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

interface ITimelock {
    enum ActionsSetState {Queued, Executed, Canceled, Expired}

    struct ActionsSet {
        address[] targets;
        uint[] values;
        string[] signatures;
        bytes[] calldatas;
        bool[] withDelegatecalls;
        uint executionTime;
        bool executed;
        bool canceled;
    }

    /// @dev emitted when an ActionsSet is received from the governor contract and queued
    /// @dev id Id of the ActionsSet
    /// @param targets list of target ERC20 addresses for calls to be made 
    /// @param values list of values in wei for each transaction
    /// @param signatures list of function signatures (can be empty) to be used when created the callData
    /// @param calldatas list of calldatas: if associated signature empty, calldata ready, else calldata is arguments
    /// @param withDelegatecalls boolean, true = transaction delegatecalls the taget, else calls the target
    /// @param executionTime the time these transactions can be executed
    event ActionsSetQueued(
        uint id,
        address[] targets,
        uint[] values,
        string[] signatures,
        bytes[] calldatas,
        bool[] withDelegatecalls,
        uint executionTime
    );

    /// @dev emitted when a ActionsSet is executed successfully
    /// @param id Id of the ActionsSet
    /// @param initiator address that triggered the ActionsSet execution
    /// @param returnedData returned data from the ActionsSet execution
    event ActionsSetExecuted(uint id, address indexed initiator, bytes[] returnedData);

    /// @dev emitted when an ActionsSet is cancelled by the governor contract (admin)
    /// @param id Id of the ActionsSet
    event ActionsSetCancelled(uint id);

    /// @dev emitted when a new pending admin (governor contract) is set
    /// @param newAdmin new admin (new governor contract)
    event PendingAdminUpdate(address newAdmin);

    /// @dev emitted when a new admin (governor contract) is set
    /// @param previousAdmin previous admin (governor contract)
    /// @param newAdmin new admin (new governor contract)
    event AdminUpdate(address previousAdmin, address newAdmin);

    /// @dev emitted when a new delay (between queueing and execution) is set
    /// @param previousDelay previous delay
    /// @param newDelay new delay
    event DelayUpdate(uint previousDelay, uint newDelay);

    
    /// @dev emitted when a GracePeriod is updated
    /// @param previousGracePeriod previous grace period
    /// @param newGracePeriod new grace period
    event GracePeriodUpdate(uint previousGracePeriod, uint newGracePeriod);

    
    /// @dev emitted when a Minimum Delay is updated
    /// @param previousMinimumDelay previous minimum delay
    /// @param newMinimumDelay new minimum delay
    event MinimumDelayUpdate(uint previousMinimumDelay, uint newMinimumDelay);

    
    /// @dev emitted when a Maximum Delay is updated
    /// @param previousMaximumDelay previous maximum delay
    /// @param newMaximumDelay new maximum delay
    event MaximumDelayUpdate(uint previousMaximumDelay, uint newMaximumDelay);

    /// @dev Execute the ActionsSet
    /// @param actionsSetId id of the ActionsSet
    function executeTransaction(uint actionsSetId) external;

    /// @dev Cancel the ActionsSet
    /// @param actionsSetId id of the ActionsSet
    function cancelTransaction(uint actionsSetId) external;

    /// @dev Function, the Governance contract, that queues an action set, returns transaction hash
    /// @param targets smart contract target
    /// @param values wei value of the transaction
    /// @param signatures function signature of the transaction
    /// @param calldatas function arguments of the transaction or callData if signature empty
    function queueActions(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        bool[] memory withDelegatecalls
        ) external;
    
    function getActionsSetById(uint actionsSetId) external view returns (ActionsSet memory);
    
    function getCurrentState(uint actionsSetId) external view returns (ActionsSetState);

    /// @dev Returns whether a action (via actionHash) is queued
    /// @param actionHash hash of the action to be checked
    /// keccak256(abi.encode(target, value, signature, data, executionTime))
    /// @return true if underlying action of actionHash is queued
    function isActionQueued(bytes32 actionHash) external view returns (bool);

    function acceptAdmin() external;

    function setPendingAdmin(address pendingAdmin) external;

    function setDelay(uint delay) external;

    function setGracePeriod(uint gracePeriod) external;

    function setMinimumDelay(uint minimumDelay) external;

    function setMaximumDelay(uint maximumDelay_) external;

    /** 
    /// @dev Getter of the current admin address (should be governance)
    /// @return The address of the current admin 
    function getAdmin() external view returns (address);

    /// @dev Getter of the current pending admin address
    /// @return The address of the pending admin 
    function getPendingAdmin() external view returns (address);

    /// @dev Getter of the delay between queuing and execution
    /// @return The delay in seconds
    function getDelay() external view returns (uint);

    /// @dev Getter of grace period constant
    /// @return grace period in seconds
    function GRACE_PERIOD() external view returns (uint);

    /// @dev Getter of minimum delay constant
    /// @return minimum delay in seconds
    function MINIMUM_DELAY() external view returns (uint);

    /// @dev Getter of maximum delay constant
    /// @return maximum delay in seconds
    function MAXIMUM_DELAY() external view returns (uint);
    */
    

}