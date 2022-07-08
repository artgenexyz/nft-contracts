// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract PayoutControlUpgradeable is OwnableUpgradeable, IERC2981 {

    using Address for address;
    using SafeERC20 for IERC20;

    uint256 public royaltyFee;

    address public royaltyReceiver;
    address public payoutReceiver;
    uint256 public DEVELOPER_FEE; // of 10,000 = 5%

    bool public isPayoutChangeLocked;

    function __PayoutControlUpgradeable_init() internal onlyInitializing {
        DEVELOPER_FEE = 500;
    }

    modifier whenNotPayoutChangeLocked() {
        require(!isPayoutChangeLocked, "Payout change is locked");
        _;
    }

    // Lock changing withdraw address
    function lockPayoutChange() public onlyOwner {
        isPayoutChangeLocked = true;
    }

    function setRoyaltyFee(uint256 _royaltyFee) public onlyOwner {
        royaltyFee = _royaltyFee;
    }

    function setRoyaltyReceiver(address _receiver) public onlyOwner {
        royaltyReceiver = _receiver;
    }

    function setPayoutReceiver(address _receiver)
        public
        onlyOwner
        whenNotPayoutChangeLocked
    {
        payoutReceiver = payable(_receiver);
    }

    function royaltyInfo(uint256, uint256 salePrice)
        external
        view
        returns (address receiver, uint256 royaltyAmount)
    {
        // We use the same contract to split royalties: 5% of royalty goes to the developer
        receiver = royaltyReceiver;
        royaltyAmount = (salePrice * royaltyFee) / 10000;
    }

    function getPayoutReceiver()
        public
        view
        returns (address payable receiver)
    {
        receiver = payoutReceiver != address(0x0)
            ? payable(payoutReceiver)
            : payable(owner());
    }

    // ---- Allow royalty deposits from Opensea -----

    receive() external payable {}

    // ---- Withdraw -----

    modifier onlyBuildship() {
        require(payable(msg.sender) == DEVELOPER_ADDRESS(), "Caller is not Buildship");
        _;
    }

    function _withdraw() private {
        uint256 balance = address(this).balance;
        uint256 amount = (balance * (10000 - DEVELOPER_FEE)) / 10000;

        address payable receiver = getPayoutReceiver();
        address payable dev = DEVELOPER_ADDRESS();

        Address.sendValue(receiver, amount);
        Address.sendValue(dev, balance - amount);
    }

    function forceWithdrawBuildship() public virtual onlyBuildship {
        _withdraw();
    }

    function withdraw() public virtual onlyOwner {
        _withdraw();
    }

    function withdrawToken(address token) public virtual onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));

        uint256 amount = (balance * (10000 - DEVELOPER_FEE)) / 10000;

        address payable receiver = getPayoutReceiver();
        address payable dev = DEVELOPER_ADDRESS();

        IERC20(token).safeTransfer(receiver, amount);
        IERC20(token).safeTransfer(dev, balance - amount);
    }

    function DEVELOPER() public pure returns (string memory _url) {
        _url = "https://buildship.xyz";
    }

    function DEVELOPER_ADDRESS() public pure returns (address payable _dev) {
        _dev = payable(0x704C043CeB93bD6cBE570C6A2708c3E1C0310587);
    }

}
