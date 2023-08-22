pragma solidity ^0.8.10;

interface IWarStaker {
    event AddedRewardDepositor(address indexed depositor);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event ClaimedRewards(address indexed reward, address indexed user, address indexed receiver, uint256 amount);
    event NewPendingOwner(address indexed previousPendingOwner, address indexed newPendingOwner);
    event NewRewards(address indexed rewardToken, uint256 amount, uint256 endTimestamp);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event Paused(address account);
    event RemovedRewardDepositor(address indexed depositor);
    event SetRewardFarmer(address indexed rewardToken, address indexed farmer);
    event SetUserAllowedClaimer(address indexed user, address indexed claimer);
    event Staked(address indexed caller, address indexed receiver, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Unpaused(address account);
    event Unstaked(address indexed owner, address indexed receiver, uint256 amount);

    struct UserClaimableRewards {
        address reward;
        uint256 claimableAmount;
    }

    struct UserClaimedRewards {
        address reward;
        uint256 amount;
    }

    struct UserRewardState {
        uint256 lastRewardPerToken;
        uint256 accruedRewards;
    }

    function acceptOwnership() external;
    function addRewardDepositor(address depositor) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function claimAllRewards(address receiver) external returns (UserClaimedRewards[] memory);
    function claimRewards(address reward, address receiver) external returns (uint256);
    function decimals() external view returns (uint8);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
    function farmerLastIndex(address) external view returns (uint256);
    function getRewardTokens() external view returns (address[] memory);
    function getUserAccruedRewards(address reward, address user) external view returns (uint256);
    function getUserRewardState(address reward, address user) external view returns (UserRewardState memory);
    function getUserTotalClaimableRewards(address user) external view returns (UserClaimableRewards[] memory);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function lastRewardUpdateTimestamp(address reward) external view returns (uint256);
    function name() external view returns (string memory);
    function owner() external view returns (address);
    function pause() external;
    function paused() external view returns (bool);
    function pendingOwner() external view returns (address);
    function queueRewards(address rewardToken, uint256 amount) external returns (bool);
    function removeRewardDepositor(address depositor) external;
    function renounceOwnership() external;
    function rewardDepositors(address) external view returns (bool);
    function rewardFarmers(address) external view returns (address);
    function rewardStates(address)
        external
        view
        returns (
            uint256 rewardPerToken,
            uint128 lastUpdate,
            uint128 distributionEndTimestamp,
            uint256 ratePerSecond,
            uint256 currentRewardAmount,
            uint256 queuedRewardAmount
        );
    function rewardTokens(uint256) external view returns (address);
    function setRewardFarmer(address rewardToken, address farmer) external;
    function stake(uint256 amount, address receiver) external returns (uint256);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function transferOwnership(address newOwner) external;
    function unpause() external;
    function unstake(uint256 amount, address receiver) external returns (uint256);
    function updateAllRewardStates() external;
    function updateRewardState(address reward) external;
    function warToken() external view returns (address);
}

