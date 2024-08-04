// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ERC20 is Initializable, ERC20Upgradeable {
   
   function initialize(string memory name, string memory symbol) external initializer {
    __ERC20_init(name, symbol);
    _mint(msg.sender, 1000 * 1e18);


   }
}
