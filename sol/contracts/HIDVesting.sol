// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract HIDVesting is Ownable {
    
    using SafeERC20 for IERC20;

    IERC20 public hidToken;

    event TokensReleased(address token, uint256 amount);
    event TokenVestingRevoked(address token);

    // beneficiary of tokens after they are released
    address private beneficiary;

    // Durations and timestamps are expressed in UNIX time, the same units as block.timestamp.
    uint256 private cliff;
    uint256 private start;
    uint256 private duration;
    uint256 private waitTime;

    bool private revocable;

    mapping(address => uint256) private released;
    mapping(address => bool) private _revoked;

    struct VestingSchedule {
        uint256 unlockTime;
        uint256 unlockPercentage;
    }

    struct Vesting {
        VestingSchedule[] vestingSchedules;
        uint256 numberOfVestingPeriods;
        uint256 totalUnlockedAmount;
        uint256 lastUnlockedTime;
    }

    uint256 PERCENTAGE_MULTIPLIER = 100;
    uint256 totalReleasedAmount = 0;

    mapping(address => Vesting) private beneficiaryVestingScheduleRegistry;
    Vesting[] vestings;

    /**
     * @notice Only allow calls from the beneficiary of the vesting contract
     */
    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary);
        _;
    }

    constructor(
        IERC20 _token, // HID token address
        address _beneficiary, // address of beneficiary
        uint256 _startTime, // start time in seconds (epoch time)
        uint256 _cliffDuration, // cliff duration in seconds
        uint256 _waitDuration, // wait duration after cliff in seconds
        uint256 _payOutPercentage, // % (in multiple of 100 i.e 12.50% = 1250) funds released in each interval.
        uint256 _payOutInterval, // intervals (in seconds) at which funds will be released
        bool _revocable
    ) {
        

        //Preparing vesting schedule
        uint256 numberOfPayouts = (100 * PERCENTAGE_MULTIPLIER) /
            _payOutPercentage;

        uint256 st = _startTime + _cliffDuration + _waitDuration;

        Vesting storage vesting = vestings.push();
        for (uint256 i = 0; i < numberOfPayouts; i++) {
            vesting.vestingSchedules.push(
                VestingSchedule({
                    unlockPercentage: (i + 1) * _payOutPercentage,
                    unlockTime: st + (i * _payOutInterval)
                })
            );
        }

        vesting.numberOfVestingPeriods = numberOfPayouts;
        vesting.totalUnlockedAmount = 0;
        vesting.lastUnlockedTime = 0;

        beneficiaryVestingScheduleRegistry[_beneficiary] = vesting;

        start = _startTime;
        cliff = start + _cliffDuration;
        waitTime = cliff + _waitDuration;
        hidToken = _token;
        beneficiary = _beneficiary;
        revocable = _revocable;
    }

    function getBenificiaryVestingSchedules(
        address _beneficiary,
        uint256 _index
    ) public view returns (uint256, uint256) {
        return (
            beneficiaryVestingScheduleRegistry[_beneficiary]
                .vestingSchedules[_index]
                .unlockTime,
            beneficiaryVestingScheduleRegistry[_beneficiary]
                .vestingSchedules[_index]
                .unlockPercentage
        );
    }

    function getBeneVestingDetails(address _beneficiary)
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            beneficiaryVestingScheduleRegistry[_beneficiary]
                .numberOfVestingPeriods,
            beneficiaryVestingScheduleRegistry[_beneficiary]
                .totalUnlockedAmount,
            beneficiaryVestingScheduleRegistry[_beneficiary].lastUnlockedTime
        );
    }

    function getBalance() public view returns (uint256) {
        return hidToken.balanceOf(address(this));
    }

    function release(address _beneficiary) public onlyBeneficiary {
        //
        require(
            block.timestamp > cliff,
            "No funds can be released during cliff period"
        );

        // no funds to be released before waitTime
        require(
            block.timestamp >= waitTime,
            "No funds can be released during waiting period"
        );

        Vesting storage v = beneficiaryVestingScheduleRegistry[_beneficiary];

        // Figure out the slot : index for % payout & payout time
        uint256 index;
        if (v.lastUnlockedTime == 0) {
            index = 0;
        } else {
            for (uint256 i = 1; i <= v.vestingSchedules.length; i++) {
                if (
                    block.timestamp > v.lastUnlockedTime &&
                    block.timestamp <= v.vestingSchedules[i].unlockTime
                ) {
                    index = i;
                    break;
                }
            }
        }

        uint256 unreleased = getReleasableAmount(_beneficiary, index);

        v.lastUnlockedTime = v.vestingSchedules[index].unlockTime;
        v.totalUnlockedAmount += unreleased;
        totalReleasedAmount += unreleased;

        hidToken.safeTransfer(_beneficiary, unreleased);
    }

    function getReleasableAmount(address _beneficiary, uint256 _index)
        public
        view
        returns (uint256)
    {
        Vesting memory v = beneficiaryVestingScheduleRegistry[_beneficiary];
        return getVestedAmount(_beneficiary, _index) - v.totalUnlockedAmount;
    }

    function getVestedAmount(address _beneficiary, uint256 _index)
        public
        view
        returns (uint256)
    {
        Vesting storage v = beneficiaryVestingScheduleRegistry[_beneficiary];

        uint256 currentBalance = hidToken.balanceOf(address(this));
        uint256 totalBalance = currentBalance + v.totalUnlockedAmount; // this was the initial balance

        VestingSchedule memory vs = v.vestingSchedules[_index];
        return
            (totalBalance * vs.unlockPercentage) /
            (100 * PERCENTAGE_MULTIPLIER);
    }
}
