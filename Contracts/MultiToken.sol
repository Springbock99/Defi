pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MultiToken
 * @dev This contract extends ERC1155 to include minting with cooldown and burning functionalities.
 * @notice Inherits from OpenZeppelin's ERC1155, ERC1155Burnable, and Ownable contracts.
 */
contract MultiToken is ERC1155, ERC1155Burnable, Ownable {
    /**
     * @dev Duration of the cooldown period in seconds.
     */
    uint256 public mintCooldown = 60;

    /**
     * @dev Boolean indicating whether the first mint has been performed.
     */
    bool public firstMintDone = false;

    /**
     * @dev Modifier to enforce minting cooldown.
     */
    modifier canMint() {
        require(
            mintCooldown == 0 || block.timestamp > mintCooldown,
            "Cooldown period not done"
        );
        _;
    }

    /**
     * @dev Constructor for the MultiToken contract.
     * @notice Initializes the contract with a base URI and mints initial tokens to the deployer.
     */
    constructor()
        ERC1155("ipfs://QmYPdi5nLPCrEugAZoxaqhK1RyEyoz3w4pb6tLuKqf5Sd7/")
        Ownable(msg.sender)
    {
        // Mint initial tokens with IDs 0 to 2 and amount 0 to the deployer
        for (uint256 tokenId = 0; tokenId <= 2; tokenId++) {
            _mint(msg.sender, tokenId, 0, "");
        }
    }

    /**
     * @dev Mints new tokens to a specified recipient.
     * @param recipient Address of the token recipient.
     * @param tokenId ID of the token to mint.
     * @param amount Amount of tokens to mint.
     * @notice Applies a cooldown period after the first mint.
     */
    function mint(
        address recipient,
        uint256 tokenId,
        uint256 amount
    ) external canMint {
        if (!firstMintDone) {
            // Set cooldown period of 60 seconds after the first mint
            mintCooldown = block.timestamp + 60;
            firstMintDone = true;
        }

        _mint(recipient, tokenId, amount, "");
    }

    /**
     * @dev Internal function to update the balances of token holders.
     * @param $from Address of the sender.
     * @param $to Address of the receiver.
     * @param $ids Array of token IDs involved in the transfer.
     * @param $values Array of amounts of tokens transferred for each ID.
     * @notice Overrides the ERC1155 _update function.
     */
    function _update(
        address $from,
        address $to,
        uint256[] memory $ids,
        uint256[] memory $values
    ) internal override(ERC1155) {
        super._update($from, $to, $ids, $values);
    }
}
