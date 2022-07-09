// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// 
import '../interfaces/ITimelock.sol';

/// libraries
//import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/// get delegateCall back

/// @notice Tokens will be ERC20, therefor, no payable functions
contract Timelock is ITimelock{

    /// @dev this is copied from Uniswap and Compound Finance
    uint public delay;
    uint public gracePeriod;
    uint public minimumDelay;
    uint public maximumDelay;
    address public admin;
    address public pendingAdmin;
    uint private _actionsSetCounter;
    
    mapping(uint => ActionsSet) public actionsSets;
    mapping(bytes32 => bool) public queuedActions;

    function receiveFunds() external payable {}
    
    modifier onlyAdmin() {
        require(msg.sender == admin, 'Call must come from Admin.');
        _;
    }

    modifier onlyThis() {
        require(msg.sender == address(this), 'Call must come from Timelock.');
        _;
    }

    constructor(     
        uint delay_,
        uint gracePeriod_,
        uint minimumDelay_,
        uint maximumDelay_,
        address admin_
        )  {
        require(delay_ >= minimumDelay_, "Delay must exceed minimum delay.");
        require(delay_ <= maximumDelay_, "Delay must not exceed maximum delay.");
        delay = delay_;
        gracePeriod = gracePeriod_;
        minimumDelay = minimumDelay_;
        maximumDelay = maximumDelay_;
        admin = admin_;
    }

    function executeTransaction(uint actionsSetId) external override {
        require(getCurrentState(actionsSetId) == ActionsSetState.Queued, 'ONLY_QUEUED_ACTIONS');

        ActionsSet storage actionsSet = actionsSets[actionsSetId];
        require(block.timestamp >= actionsSet.executionTime, 'TIMELOCK_NOT_FINISHED');

        actionsSet.executed = true;
        uint actionCount = actionsSet.targets.length;

        bytes[] memory returnedData = new bytes[](actionCount);
        for (uint i = 0; i < actionCount; i++) {
        returnedData[i] = _executeTransaction(
            actionsSet.targets[i],
            actionsSet.values[i],
            actionsSet.signatures[i],
            actionsSet.calldatas[i],
            actionsSet.executionTime,
            actionsSet.withDelegatecalls[i]
        );
    }
    emit ActionsSetExecuted(actionsSetId, msg.sender, returnedData);
    }

    /// @notice permission to cancel will be done via admin contract to avoid cancel abuse
    /// @notice admin contract does not always require cancel functionality
    function cancelTransaction(uint actionsSetId) public override onlyAdmin {
      ActionsSetState state = getCurrentState(actionsSetId);
      require(state == ActionsSetState.Queued, 'ONLY_BEFORE_EXECUTED');

      ActionsSet storage actionsSet = actionsSets[actionsSetId];
      actionsSet.canceled = true;
      for (uint i = 0; i < actionsSet.targets.length; i++) {
        _cancelTransaction(
          actionsSet.targets[i],
          actionsSet.values[i],
          actionsSet.signatures[i],
          actionsSet.calldatas[i],
          actionsSet.executionTime,
          actionsSet.withDelegatecalls[i]
        );
      }

      emit ActionsSetCancelled(actionsSetId);
    }

    function queueActions(
        address[] memory targets,
        uint[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        bool[] memory withDelegatecalls
    ) public override onlyAdmin {
        require(targets.length != 0, 'INVALID_EMPTY_TARGETS');
        require(
            targets.length == values.length &&
                targets.length == signatures.length &&
                targets.length == calldatas.length &&
                targets.length == withDelegatecalls.length,
            'INCONSISTENT_PARAMS_LENGTH'
            );

            uint actionsSetId = _actionsSetCounter;
            uint executionTime = block.timestamp + delay;
            _actionsSetCounter++;

            for (uint256 i = 0; i < targets.length; i++) {
                bytes32 actionHash =
                    keccak256(
                        abi.encode(
                            targets[i],
                            values[i],
                            signatures[i],
                            calldatas[i],
                            executionTime,
                            withDelegatecalls[i]
                        )
                    );
                require(!isActionQueued(actionHash), 'DUPLICATED_ACTION');
                queuedActions[actionHash] = true;
            }

            ActionsSet storage actionsSet = actionsSets[actionsSetId];
            actionsSet.targets = targets;
            actionsSet.values = values;
            actionsSet.signatures = signatures;
            actionsSet.calldatas = calldatas;
            actionsSet.executionTime = executionTime;

            emit ActionsSetQueued(
            actionsSetId,
            targets,
            values,
            signatures,
            calldatas,
            withDelegatecalls,
            executionTime
        );
    }

    function getActionsSetById(uint actionsSetId)
        external
        view
        override
        returns (ActionsSet memory)
    {
        return actionsSets[actionsSetId];
    }

    function getCurrentState(uint actionsSetId) public view override returns (ActionsSetState) {
        require(_actionsSetCounter > actionsSetId, 'INVALID_ACTION_ID');
        ActionsSet storage actionsSet = actionsSets[actionsSetId];
        if (actionsSet.canceled) {
        return ActionsSetState.Canceled;
        } else if (actionsSet.executed) {
        return ActionsSetState.Executed;
        } else if (block.timestamp > actionsSet.executionTime+(gracePeriod)) {
        return ActionsSetState.Expired;
        } else {
        return ActionsSetState.Queued;
        }
    }

    function isActionQueued(bytes32 actionHash) public view override returns (bool) {
        return queuedActions[actionHash];
    }

    function acceptAdmin() external override {
        require(msg.sender == pendingAdmin, "Call must come from pendingAdmin.");
        emit AdminUpdate(admin, pendingAdmin);

        admin = msg.sender;
        pendingAdmin = address(0);      
    }

    function setPendingAdmin(address pendingAdmin_) external override onlyThis {
        pendingAdmin = pendingAdmin_;

        emit PendingAdminUpdate(pendingAdmin);
    }

    function setDelay(uint delay_) external override onlyThis {
        _validateDelay(delay_);
        emit DelayUpdate(delay, delay_);
        delay = delay_;
    }

    function setGracePeriod(uint gracePeriod_) external override onlyThis {
        emit GracePeriodUpdate(gracePeriod, gracePeriod_);
        gracePeriod = gracePeriod_;
    }

    function setMinimumDelay(uint minimumDelay_) external override onlyThis {
        uint previousMinimumDelay = minimumDelay;
        minimumDelay = minimumDelay_;
        _validateDelay(delay);
        emit MinimumDelayUpdate(previousMinimumDelay, minimumDelay_);
    }
    
    function setMaximumDelay(uint maximumDelay_) external override onlyThis {
        uint previousMaximumDelay = maximumDelay;
        maximumDelay = maximumDelay_;
        _validateDelay(delay);
        emit MaximumDelayUpdate(previousMaximumDelay, maximumDelay_);
    }

    function _validateDelay(uint delay_) internal view {
        require(delay_ >= minimumDelay, 'DELAY_SHORTER_THAN_MINIMUM');
        require(delay_ <= maximumDelay, 'DELAY_LONGER_THAN_MAXIMUM');
    }


    function _executeTransaction(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint executionTime,
        bool withDelegatecall
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'NOT_ENOUGH_CONTRACT_BALANCE');

    bytes32 actionHash =
      keccak256(abi.encode(target, value, signature, data, executionTime, withDelegatecall));
    queuedActions[actionHash] = false;

    bytes memory callData;
    if (bytes(signature).length == 0) {
      callData = data;
    } else {
      callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
    }

    bool success;
    bytes memory resultData;
    if (withDelegatecall) {
      (success, resultData) = this.executeDelegateCall{value: value}(target, callData);
    } else {
      // solium-disable-next-line security/no-call-value
      (success, resultData) = target.call{value: value}(callData);
    }
    return _verifyCallResult(success, resultData);
  }

  function _cancelTransaction(
    address target,
    uint256 value,
    string memory signature,
    bytes memory data,
    uint256 executionTime,
    bool withDelegatecall
  ) internal {
    bytes32 actionHash =
      keccak256(abi.encode(target, value, signature, data, executionTime, withDelegatecall));
    queuedActions[actionHash] = false;
  }

  /**
   * @dev target.delegatecall cannot be provided a value directly and is sent
   * with the entire available msg.value. In this instance, we only want each proposed action
   * to execute with exactly the value defined in the proposal. By splitting executeDelegateCall
   * into a seperate function, it can be called from this contract with a defined amout of value,
   * reducing the risk that a delegatecall is executed with more value than intended
   * @return success - boolean indicating it the delegate call was successfull
   * @return resultdata - bytes returned by the delegate call
   **/
  function executeDelegateCall(address target, bytes calldata data)
    external
    payable
    onlyThis
    returns (bool, bytes memory)
  {
    bool success;
    bytes memory resultData;
    // solium-disable-next-line security/no-call-value
    (success, resultData) = target.delegatecall(data);
    return (success, resultData);
  }


  function _verifyCallResult(bool success, bytes memory returndata)
    private
    pure
    returns (bytes memory)
  {
    if (success) {
      return returndata;
    } else {
      // Look for revert reason and bubble it up if present
      if (returndata.length > 0) {
        // The easiest way to bubble the revert reason is using memory via assembly

        // solhint-disable-next-line no-inline-assembly
        assembly {
          let returndata_size := mload(returndata)
          revert(add(32, returndata), returndata_size)
        }
      } else {
        revert('FAILED_ACTION_EXECUTION');
      }
    }
  }
    
}