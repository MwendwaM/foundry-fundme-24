//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, withdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeInteractions is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1; 

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run();     
        vm.deal(USER, INITIAL_BALANCE);   
    }

    function testUserCanFundFundMeAndWithdraw() public {
        FundFundMe fundFundMe = new FundFundMe();
        //vm.prank(USER);
        //vm.deal(USER, 1e18);
        fundFundMe.fundFundMe(address(fundMe));
        address funder = fundMe.getFunder(0);

        assertEq(funder, msg.sender);
        console.log(funder);

        withdrawFundMe WithDrawFundsFromFundMe = new withdrawFundMe();
        WithDrawFundsFromFundMe.withdrawFunds(address(fundMe));

        assert(address(fundMe).balance == 0);

    }

    function testUserCanWithDrawFromFundFundMe() public{
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        withdrawFundMe withdrawFundsInteractions = new withdrawFundMe();
        withdrawFundsInteractions.withdrawFunds(address(fundMe));

        assert(address(fundMe).balance == 0);

    }

}
