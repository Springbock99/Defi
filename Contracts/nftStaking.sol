// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title Lizards
 * @dev A simple ERC721 token contract for representing Lizard NFTs.
 */
error AlreadyStaked(address account, string reason);

contract Lizards is ERC721 {
    uint256 public _tokenIdCounter;
    using Strings for uint256;

    /**
     * @dev Constructor that initializes the Lizards contract.
     */
    constructor() ERC721("Lizard", "LZ") {}

    /**
     * @dev Mint a new Lizard NFT and assign it to the specified address.
     * @param to The address to assign the minted NFT to.
     */
    function mint(address to) external {
        _safeMint(to, _tokenIdCounter);
        _tokenIdCounter++;
    }

    /**
     * @dev Override of the ERC721 tokenURI function to include a base URI.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        _requireOwned(tokenId);
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string.concat(baseURI, tokenId.toString())
                : "";
    }

    /**
     * @dev Internal function to specify the base URI for token metadata.
     * @return The base URI for token metadata.
     */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmYPdi5nLPCrEugAZoxaqhK1RyEyoz3w4pb6tLuKqf5Sd7/";
    }
}

/**
 * @title StakingContract
 * @dev A staking contract allowing users to stake and unstake NFTs to earn rewards.
 */
contract StakingContract is IERC721Receiver {
    IERC20 public token;
    IERC721 public itemNFT;
    uint256 public constant rewardRate = 10;

    mapping(uint256 => address) public originalOwner;
    mapping(address => StakedeNFTs[]) public stakedNFT;
    mapping(address => bool) public ifStaked;
    mapping(address => uint256) public lastRewardTime;

    struct StakedeNFTs {
        uint256 tokenId;
        uint256 startTime;
    }

    /**
     * @dev Modifier to ensure that the staker is not already staked.
     */
    modifier alreadyStaked() {
        if (ifStaked[msg.sender])
            revert AlreadyStaked(msg.sender, "token already staked");
        _;
    }

    /**
     * @dev Constructor that initializes the StakingContract.
     * @param erc20 The ERC20 token used for rewards.
     * @param NFT The ERC721 token used for staking.
     */
    constructor(IERC20 erc20, IERC721 NFT) {
        token = erc20;
        itemNFT = NFT;
    }

    /**
     * @dev ERC721 receiver function to handle NFT deposits.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    /**
     * @dev Deposit an NFT into the staking contract.
     * @param tokenId The ID of the NFT to be deposited.
     */
    function depositNFT(uint256 tokenId) external {
        originalOwner[tokenId] = msg.sender;
        itemNFT.safeTransferFrom(msg.sender, address(this), tokenId);
    }

    /**
     * @dev Stake an NFT to start earning rewards.
     * @param tokenId The ID of the NFT to be staked.
     */
    function stake(uint256 tokenId) external alreadyStaked {
        originalOwner[tokenId] == msg.sender;
        stakedNFT[msg.sender].push(StakedeNFTs(tokenId, block.timestamp));
    }

    /**
     * @dev Unstake an NFT and claim rewards.
     * @param tokenId The ID of the NFT to be unstaked.
     */
    function unstakeAndClaimRewards(uint256 tokenId) external alreadyStaked {
        require(stakedNFT[msg.sender].length > 0, "No NFTs staked");
        uint256 indexToRemove;

        for (uint256 i = 0; i < stakedNFT[msg.sender].length; i++) {
            if (stakedNFT[msg.sender][i].tokenId == tokenId) {
                indexToRemove = i;
                break;
            }
        }

        require(
            indexToRemove < stakedNFT[msg.sender].length,
            "NFT not found in staked list"
        );

        _getRewards(msg.sender);

        itemNFT.safeTransferFrom(address(this), msg.sender, tokenId);

        for (
            uint256 i = indexToRemove;
            i < stakedNFT[msg.sender].length - 1;
            i++
        ) {
            stakedNFT[msg.sender][i] = stakedNFT[msg.sender][i + 1];
        }
        stakedNFT[msg.sender].pop();

        ifStaked[msg.sender] = false;
    }

    /**
     * @dev Internal function to calculate and transfer rewards to the user.
     * @param user The address of the user to receive the rewards.
     */
    function _getRewards(address user) internal {
        uint256 currentTime = block.timestamp;
        uint256 elapsedTime = currentTime - lastRewardTime[user];

        if (elapsedTime > 0) {
            uint256 earnedRewards = (elapsedTime * rewardRate) / (24 hours);
            lastRewardTime[user] = currentTime;

            token.transfer(user, earnedRewards);
        }
    }

    /**
     * @dev Claim rewards for a specific NFT.
     * @param tokenId The ID of the NFT for which rewards are to be claimed.
     */
    function getRewards(uint256 tokenId) external {
        require(originalOwner[tokenId] == msg.sender);
        _getRewards(msg.sender);
    }
}
