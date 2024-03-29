// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Crowdfunding {
    address public owner;

    struct Campaign {
        uint256 campaignId;
        address owner;
        string name;
        string description;
        uint256 amountCollected;
        uint256 deadline;
         bool isActive;
    }
    uint256 public numberOfCampaigns;
    mapping(uint256 => Campaign) public idToCampaign;
    mapping(uint256 => uint256[]) public donations;
    mapping(uint256 => address[]) public donators;

    constructor() {
        owner = msg.sender;
    }

    function createCampaign(
        string memory _name,
        string memory _description,
        uint256 _amountCollected,
        uint256 _deadline
    ) public returns (uint) {
        require(_deadline > block.timestamp);
        numberOfCampaigns++;

        idToCampaign[numberOfCampaigns] = Campaign(
            numberOfCampaigns,
            msg.sender,
            _name,
            _description,
            _amountCollected,
            _deadline,
            true
        );

        return numberOfCampaigns;
    }

    function donateToCampaign(uint _campaignId) public payable {
        require(msg.value > 0, "donation should greaterthan 0");
        Campaign storage campaign = idToCampaign[_campaignId];
                require(campaign.isActive ==true);

        donations[_campaignId].push(msg.value);
        donators[_campaignId].push(msg.sender);
        campaign.amountCollected += msg.value;
         (bool success, ) = payable(address(this)).call{value: msg.value}("");
            require(success, "Transfer failed");

    }

    function endCampaign( uint256 _campaignId) public  {
        Campaign storage campaign = idToCampaign[_campaignId];
        require( block.timestamp > campaign.deadline);
        require(campaign.isActive == true);   

        campaign.isActive = false;           
    }

   function getAllCampaigns () public view returns (Campaign[] memory){
       Campaign[] memory campaign = new Campaign[](numberOfCampaigns);
        uint256 count =1;
          for (uint i = 0; i <numberOfCampaigns; i++) {
            if (idToCampaign[count].isActive == true &&  idToCampaign[count].deadline > block.timestamp ) {
                 campaign[i] = idToCampaign[count];
               count++;
            }
            
          }
          return campaign; 
   }
   function getCampaign(uint256 _campaignId) public  view returns(Campaign memory) {
    Campaign storage campaign = idToCampaign[_campaignId];
    require(campaign.isActive == true &&  campaign.deadline > block.timestamp);
    return campaign;
   }
   function getDonatorsForCampaign(uint256 _campaignId ) public view returns(address[] memory) {
             
             return donators[_campaignId];   
   }
   function getDonationsForCampaign(uint256 _campaignId ) public view returns(uint256[] memory) {
             
             return donations[_campaignId];
   }

   function withdraw(uint _campaignId) public  {
      Campaign storage campaign = idToCampaign[_campaignId];
      require( campaign.owner == msg.sender,"only owner can withdraw the funds");
       require(block.timestamp > campaign.deadline, "Campaign deadline has not been reached.");
       uint256 amount = campaign.amountCollected;
         campaign.amountCollected = 0;

   (bool success,) = payable(campaign.owner).call{value : amount}("");
          require(success, "withdraw failed");
        
         }
    
}
