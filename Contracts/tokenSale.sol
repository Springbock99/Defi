 /* @dev TokenSale is an ERC20 token with functionalities for token minting, selling back tokens for Ether, and withdrawal of Ether. It inherits from ERC20Capped and utilizes Ownable2Step for access control.
 */
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

/**
 * @dev Emitted when an operation is attempted by a non-owner.
 */
error notOwner();

/**
 * @dev Emitted when an operation is attempted without sufficient funds.
 */
error noFunds();

/**
 * @dev Emitted when a negative value is encountered.
 */
error minusZ();

/**
 * @dev Emitted when an operation is attempted with an insufficient balance.
 */
error insufficientBalance();

/**
 * @dev Emitted when there's not enough Ether in the contract.
 */
error notEnoghEther();

contract TokenSale is ERC20Capped {
    address owner;
    uint256 public constant Token_Value = 1 ether;
    uint256 public constant Max_Value = 1000000 * 1e18;

    /**
     * @dev Sets the initial token amount and maximum token supply.
     * @param amount The initial token amount to be minted.
     * @param maxSupply The maximum token supply.
     */
    constructor(uint256 amount, uint256 maxSupply)
        ERC20("TokenSale", "MDL")
        ERC20Capped(maxSupply)
    {
        owner = msg.sender;
        _mint(owner, amount * 1e18);
    }

    /**
     * @dev Modifier to check if the sender is the owner.
     */
    modifier OnlyOwner() {
        if (msg.sender != owner) revert notOwner();
        _;
    }

    /**
     * @dev Mints tokens to the sender, requires a minimum amount of Ether, and checks if the maximum token supply is exceeded.
     */
    function mintTokens() external payable {
        if (msg.value <= Token_Value) revert noFunds();
        uint256 tokensToMint = 1000 * 1e18;
        if (balanceOf(address(this)) >= tokensToMint) {
            transfer(msg.sender, tokensToMint);
        } else {
            uint256 _tokenToBeMint = tokensToMint - balanceOf(address(this));
            if (balanceOf(address(this)) > 0) {
                transfer(msg.sender, balanceOf(address(this)));
            }
            _mint(msg.sender, _tokenToBeMint);
        }
    }

    /**
     * @dev Allows users to sell back tokens for Ether.
     * @param amount The amount of tokens to sell back.
     */
    function sellBack(uint256 amount) external payable {
        require(amount >= 0);
        if (amount <= 0) revert minusZ();
        if (balanceOf(msg.sender) <= amount) revert insufficientBalance();

        uint256 etherToTRansfer = (amount * 0.5 ether) / (1000 * 10 * 18);
        require(
            address(this).balance >= etherToTRansfer,
            "doesn't have enough Ether"
        );
        if (address(this).balance <= etherToTRansfer) revert notEnoghEther();

        transferFrom(msg.sender, address(this), amount);

        payable(msg.sender).transfer(etherToTRansfer);
    }

    /**
     * @dev Allows the owner to withdraw Ether from the contract.
     */
    function withdraw() public OnlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    /**
     * @dev Internal function to mint tokens, checks if the maximum token supply is exceeded.
     * @param account The account to mint tokens to.
     * @param amount The amount of tokens to mint.
     */
    function _mint(address account, uint256 amount) internal override {
        require(totalSupply() + amount <= Max_Value, "Exceeds maximum supply");
        super._mint(account, amount);
    }
}