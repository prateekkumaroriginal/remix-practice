// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    uint256 public minUSD = 5e18;
    address public ETH_USD_address = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    function fund() public payable {
        require(getConversionRate(msg.value) > minUSD, "Didn't send required ETH!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            ETH_USD_address
        );
        (,int256 price,,,) = priceFeed.latestRoundData();

        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmt) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmtInUSD = (ethPrice * ethAmt) / 1e18;
        return ethAmtInUSD;
    }
}
