// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant INITIAL_BALANCE = 10 ether;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();     
        vm.deal(USER, INITIAL_BALANCE);   
    }

    modifier funded(){
        vm.prank(USER);
        fundMe.fund{ value: SEND_VALUE}();
        _;
    }


    function testDemo() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        console.log(fundMe.MINIMUM_USD());
    }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.i_owner());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testOnlyOwnerCanWithdrawCheaply() public {
     uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 0;

        for (uint160 i = startingFunderIndex  ; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{ value: SEND_VALUE}();
        }
        
        uint256 startingFunderBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFunderBalance + startingFundMeBalance == fundMe.getOwner().balance);

        /*for (uint160 i = startingFunderIndex ; i < numberOfFunders; i++){
            console.log(address(i), fundMe.getOwner().balance);
        }*/   
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testAmountFundedIsMoreThan5() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testAmountFundedIsEqualToUpdatedDataStruct() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testFundersArrayIsUpdated () public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
        console.log(funder);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawalsAreWorkingForSingleFunder() public funded {

        uint256 startingFunderBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingFunderBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(endingFunderBalance, startingFunderBalance + startingFundMeBalance);


        console.log(startingFunderBalance, startingFundMeBalance, endingFunderBalance, endingFundMeBalance);
        //console.log(endingFunderBalance);
        //console.log(startingFundMeBalance);
        //console.log(endingFundMeBalance);

    }

    function testWithdrawalsAreWorkingForMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 0;

        for (uint160 i = startingFunderIndex  ; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{ value: SEND_VALUE}();
        }
        
        uint256 startingFunderBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFunderBalance + startingFundMeBalance == fundMe.getOwner().balance);

        /*for (uint160 i = startingFunderIndex ; i < numberOfFunders; i++){
            console.log(address(i), fundMe.getOwner().balance);
        }*/
    }
}
