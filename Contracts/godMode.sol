 /* @dev GodeMode is an ERC20 token with additional functionalities such as minting, burning, and blacklist management. It inherits from ERC20Capped and utilizes Ownable2Step for access control.
 */
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @dev Emitted when an operation is attempted by a non-owner.
 */
error notLord();

/**
 * @dev Emitted when an operation is attempted on a blacklisted address.
 */
error Blacklisted();

contract GodeMode is ERC20Capped, Ownable2Step {
    mapping(address => bool) private isBlacklisted;

    address ubsBank;
    address lord;

    /**
     * @dev Sets the initial token amount and maximum token supply.
     * @param amount The initial token amount to be minted.
     * @param maxSupply The maximum token supply.
     */
   constructor(uint256 amount, uint256 maxSupply)
        ERC20("Module1", "MDL")
        ERC20Capped(maxSupply) Ownable(msg.sender)
    {
        lord = msg.sender;
        _mint(lord, amount);
    }

    /**
     * @dev Modifier to check if the sender is the owner.
     */
    modifier onlyOwner() override {
        if (msg.sender != lord) revert notLord();
        _;
    }

    /**
     * @dev Modifier to check if an address is not blacklisted.
     * @param _address The address to check.
     */
    modifier notBlacklisted(address _address) {
        if (isBlacklisted[_address]) revert Blacklisted();
        _;
    }

    /**
     * @dev Mints tokens and assigns them to a specified address.
     * @param recipient The address to receive the minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mintTokensToAddress(address recipient, uint256 amount)
        external
        onlyOwner
    {
        _mint(recipient, amount);
    }

    /**
     * @dev Changes the balance of an address by minting or burning tokens.
     * @param target The address whose balance will be changed.
     * @param amount The amount by which the balance will be changed.
     */
    function changeBalanceAtAddress(address target, uint256 amount)
        external
        onlyOwner
    {
        uint256 currentBalance = balanceOf(target);
        if(amount > currentBalance){
            uint256 difference = amount - currentBalance;
            _mint(target, difference);
        } else if(amount < currentBalance){
            uint256 difference = currentBalance - amount;
            _burn(target, difference);
        }
    }

    /**
     * @dev Transfers tokens from one address to another, with additional checks for blacklisted addresses.
     * @param to The address to transfer tokens to.
     * @param value The amount of tokens to transfer.
     * @return A boolean indicating whether the transfer was successful.
     */
    function transfer(address to, uint256 value)
        public
        override
        notBlacklisted(msg.sender)
        notBlacklisted(to)
        returns (bool)
    {
        _transfer(msg.sender, to, value);
        _update(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Adds an address to the blacklist.
     * @param _address The address to be blacklisted.
     */
    function addToBlacklist(address _address) external onlyOwner {
        isBlacklisted[_address] = true;
    }

    /**
     * @dev Removes an address from the blacklist.
     * @param _address The address to be removed from the blacklist.
     */
    function removeFromBlacklist(address _address) external onlyOwner {
        isBlacklisted[_address] = false;
    }
}
