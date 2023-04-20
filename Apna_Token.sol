// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IPrivateSale{
    function lockToken(address) external view returns(uint256);
}

contract ApnaCastNew is Initializable, ERC20Upgradeable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    event PrivateSaleAddressChanged(address, address);
    address privateSale;

    modifier onlyUnlockedToken(uint256 amount) {
        uint256 transferableAmount = balanceOf(msg.sender) - amount;
        require(IPrivateSale(privateSale).lockToken(msg.sender) <= transferableAmount, "You can not transfer that much token before release.");
        _;
    }

    function initialize() initializer public {
        __ERC20_init("Test Apnacast", "TAPNA");
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount*(1 ether));
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function transfer(address to, uint256 amount) public onlyUnlockedToken(amount) override returns(bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function setPrivateSaleAddress(address pSaleAddress) external onlyOwner returns(bool){
        privateSale = pSaleAddress;
        emit PrivateSaleAddressChanged(msg.sender, pSaleAddress);
        return true;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    uint8[32] private __gap;
}