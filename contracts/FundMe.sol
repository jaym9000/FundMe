// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error NotOwner();

library PriceConverter{
function getPrice() internal view returns(uint256) {
// 0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF

AggregatorV3Interface priceFeed = AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF);
(,int256 price,,,) = priceFeed.latestRoundData();
return uint256(price) * 1e10;
}

function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
uint256 ethPrice = getPrice();
uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
return ethAmountInUSD;
}


}



contract FundMe{
using PriceConverter for uint256;

uint256 public constant MINIMUM_USD = 5e18;

address[] public funders;
mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

address public immutable i_owner;

function fund() public payable {

require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH"); // 1e18 = 1 ETH
funders.push(msg.sender);
addressToAmountFunded[msg.sender] += msg.value;
}

function getVersion() public view returns (uint256) {
return AggregatorV3Interface(0xfEefF7c3fB57d18C5C6Cdd71e45D2D0b4F9377bF).version();
}


constructor(){
i_owner = msg.sender;
}

function withdraw() public onlyOwner {
for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
address funder = funders[funderIndex];
addressToAmountFunded[funder] = 0;

}
funders = new address[] (0);

// // transfer below
// payable(msg.sender).transfer(address(this).balance);


// // Send below
// bool sendSuccess = payable(msg.sender).send(address(this).balance); // doesn't automatically revert
// require(sendSuccess, "Send failed");

// Call below
(bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
require(callSuccess, "Call failed");
}

modifier onlyOwner(){
// require(msg.sender == i_owner, NotOwner());
if(msg.sender != i_owner){ revert NotOwner();}
_;
}

receive() external payable{
fund();
}

fallback() external payable {
fund();
}

}
