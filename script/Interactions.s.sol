//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script{
    uint256 constant SEND_VALUE = 0.1 ether;
    //FundMe fundMe = new FundMe();

    function fundFundMe(address mostRecentDeployment) public {       
        vm.startBroadcast(); 
        FundMe(payable(mostRecentDeployment)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe contract with %s", SEND_VALUE);
    }


    function run() external {
        //vm.startBroadcast();
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        //vm.startBroadcast();
        fundFundMe(mostRecentDeployment);
        console.log("Funded FundMe contract with %s", SEND_VALUE);
        //vm.stopBroadcast();        
    }

}

contract  withdrawFundMe is Script {

    function withdrawFunds(address mostRecentDeployment) public {    
        
        vm.startBroadcast();    
        FundMe(payable(mostRecentDeployment)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrawn all funds (%s) from", address(mostRecentDeployment).balance, mostRecentDeployment ,"to");
        console.log(msg.sender, "and balance is", msg.sender.balance);
    }


    function run() external {
        address mostRecentDeployment = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        withdrawFunds(mostRecentDeployment);
    }
}