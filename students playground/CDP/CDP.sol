// SPDX-License-Identifier: MIT

pragma solidity >=0.8.4;
// import "@prb/contracts/token/erc20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../Swappool/DAI.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "hardhat/console.sol";


contract CDP {
    struct  Vault {
        uint256 collateral;
        uint256 debt;
    }


        
    address oracle; 
    address public token; 

    uint256 public constant RATIO= 175;//75e16; //75%  100%=1e18

    mapping (address => Vault) vaults;
    constructor (address _oracle){
        token = address (new DAI("Stablecoin", "SS",18));
        oracle= _oracle;
    }

    function depositCollateral (uint256 collateralAmount) external payable {
        require (collateralAmount >0);
        uint256 amountToMint = estimateTokenGeneration(collateralAmount, msg.sender);
        DAI(token).mint(msg.sender, amountToMint);
        vaults[msg.sender].collateral+= collateralAmount;
        vaults[msg.sender].debt += amountToMint;
        console.log ("collateralAmount", collateralAmount);
        console.log ("amountToMint", amountToMint);
        console.log ("new collateral", vaults[msg.sender].collateral);
        console.log ("new debt", vaults[msg.sender].debt);   
    }
    function estimateTokenGenerationForSender (uint256 amount) public view returns (uint256) {
        return estimateTokenGeneration(amount, msg.sender);
    }

    function getBalance(address user) public view returns (uint256, uint256) {
        return (vaults[user].collateral, vaults[user].debt) ;
    }

    function getSenderBalance () public view returns (uint256, uint256) {
           return getBalance(msg.sender) ;
    }

    function estimateTokenGeneration(uint256 amount, address user) public view returns(uint256) {
        uint256 collateral = vaults[user].collateral;
        uint256 ethPrice = Oracle(oracle).getEthPrice();
        // uint256 calculated = amount * 1e18 /ethPrice/RATIO;
        //Denis: there is some problem with this formula above
        uint256 calculated = amount*ethPrice/RATIO*100;
        uint256 returnVal = calculated > collateral ?calculated: collateral;
        console.log ("collateral=",collateral);
        console.log ("ethprice=",ethPrice);
        console.log ("calculated=",calculated);
        console.log ("returnVal", returnVal);
        return returnVal;
    }

    function withdraw (uint256 repaymentAmount) external payable {
        require (repaymentAmount >0);
        uint256 ethPrice = Oracle(oracle).getEthPrice();
        uint256 amountToWithdraw= repaymentAmount*RATIO/ethPrice/100;
        DAI(token).burn(msg.sender,repaymentAmount);
        console.log ("repaymentAmount", repaymentAmount);
        console.log ("amountToWithdraw", amountToWithdraw);
        vaults[msg.sender].collateral-= amountToWithdraw;
        vaults[msg.sender].debt -= repaymentAmount;
        // payable(msg.sender).transfer(amountToWithdraw);
        //Denis - there is some problem with this function above. It runs with small values and does not run with bigger values.
    
    }


}
contract Oracle {
    uint256 ethPrice;
    constructor (uint256 _ethPrice) {
        ethPrice=_ethPrice;
    }

    function getEthPrice () public view returns (uint256) {
         return ethPrice;
    }

    function setEthPrice (uint256 _ethPrice) public {
                ethPrice=_ethPrice;
    }
}