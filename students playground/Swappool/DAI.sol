// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;
import "@prb/contracts/token/erc20/ERC20.sol";
import "@prb/contracts/token/erc20/ERC20Permit.sol";

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20Permit.sol";
contract DAI is ERC20, ERC20Permit{
    constructor (
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20Permit (name_, symbol_, decimals_) {}

    function mint(address beneficiary, uint256 amount) public {
        mintInternal(beneficiary, amount);  
    }

    function burn(address beneficiary, uint256 amount) public {
        burnInternal(beneficiary, amount);  
    }
}