pragma solidity ^0.8.10;

interface IWarMinter {
    event MintRatioUpdated(address oldMintRatio, address newMintRatio);
    event NewPendingOwner(address indexed previousPendingOwner, address indexed newPendingOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function acceptOwnership() external;
    function lockers(address) external view returns (address);
    function mint(address vlToken, uint256 amount, address receiver) external;
    function mint(address vlToken, uint256 amount) external;
    function mintMultiple(address[] memory vlTokens, uint256[] memory amounts) external;
    function mintMultiple(address[] memory vlTokens, uint256[] memory amounts, address receiver) external;
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function ratios() external view returns (address);
    function renounceOwnership() external;
    function setLocker(address vlToken, address warLocker) external;
    function setRatios(address newRatios) external;
    function transferOwnership(address newOwner) external;
    function war() external view returns (address);
}

