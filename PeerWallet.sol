pragma solidity ^0.4.2;

import "browser/SherryToken.sol";
contract AdminFunctions 
{
    //using Strings for string;
    
    SherryToken sherry = SherryToken(0x3f1e403af1f89c7a66dbe0513d9ae9f3b337aaa1); // deployed contract instantiating/ Ropsten
    address private creater;
    uint private MarketCapital;
    mapping (address => bool) private AddedAccounts;
    mapping (address => UserRegistration) private _Accounts;
    mapping (uint => InvestmentGroup) private _Groups;
    mapping (address => mapping(uint=>UserInvestment)) private _UserInvestments;
    uint private TotalGroupsAdded;

    
    event UserCreation( address _Address, string _name);
    event GroupAdded(uint _GroupID, string _GroupName, uint _Percentage);
    event InvestmentMade(uint _money);
    
    
    
    function AdminFunctions() public
    {
        
        creater = msg.sender;
        MarketCapital = 0;
        
    }
    
    modifier ContractOwner()
    {
        require(creater==msg.sender);
        _;
    }
    
    struct UserRegistration
    {
        string name;
        //address account;
        //uint wallet;
        uint TotalInvestment;
        bool IsActive; //will be implemented if deemed necessary
        
    }
    
    struct InvestmentGroup
    {
        uint GroupID;
        string GroupName;
        uint Percentage;
        bool Active;
        
    }
    
     struct UserInvestment
    {
        uint GroupID;
        address UserAccount;
        uint TotalInvestmentMade;
        
    }

    function setAllowedUsers(address AccountAddress) external ContractOwner returns(bool) {
        AddedAccounts[AccountAddress]=true;
        return true;
    }

    function containsAllowedUser(address AccountAddress) public view returns (bool){
        return AddedAccounts[AccountAddress];
    }
    
    function createUser(address _Address, string _name) public ContractOwner
    {
        if(containsAllowedUser(_Address) && !checkIfUserExists(_Address))
        {
            _Accounts[_Address].name = _name;
            _Accounts[_Address].IsActive = true;
            _Accounts[_Address].TotalInvestment = 0;
            
           emit UserCreation(_Address,_name); // in previous versions of web3 i.e, <1.0, it was used in the callbacks
        }
    }
    
    
    function getUserName(address _Address) public view returns(string) {
        if(_Accounts[_Address].IsActive)
        {
            return _Accounts[_Address].name;
        }
        else
            return "user does not exist";
            

    }
    
    function checkIfUserExists(address _Address) public view returns(bool)
    {
        return _Accounts[_Address].IsActive;
        
    }
    
    
    function RemoveAccount(address _Address) external ContractOwner {
        AddedAccounts[_Address]=false;
    }
    
    function RequestToChangeUserDetails(string _Name) internal
    {
        _Accounts[msg.sender].name = _Name;   
    }
    
     function RequestToMakeInvestment(uint _money) internal returns(bool)
    {

            for(uint i=0; i<TotalGroupsAdded+1; i++)
            {
                uint tempInvest;
                tempInvest = (_Groups[i].Percentage*_money)/100;
                _UserInvestments[msg.sender][_Groups[i].GroupID].GroupID = _Groups[i].GroupID;
                _UserInvestments[msg.sender][_Groups[i].GroupID].UserAccount = msg.sender;
                _UserInvestments[msg.sender][_Groups[i].GroupID].TotalInvestmentMade = tempInvest;
            }
            require(sherry.transfer(msg.sender, 10**uint(18)));
        
            return true;
            
            emit InvestmentMade(_money);
           

        return false;
         
    }
    
    function RequestToCheckInvestments(uint _GroupID) internal view returns(uint)
    {
        
            return (_UserInvestments[msg.sender][_GroupID].TotalInvestmentMade);
        
         
    }
    
    function SetGroup(uint _GroupID, string _GroupName, uint _Percentage) external ContractOwner
    {
        if(!checkIfGroupExists(_GroupID))
         {
            _Groups[_GroupID].GroupID = _GroupID;
            _Groups[_GroupID].GroupName = _GroupName;
            _Groups[_GroupID].Percentage = _Percentage;
            _Groups[_GroupID].Active = true;
            TotalGroupsAdded++;
            
            emit GroupAdded(_GroupID,_GroupName,_Percentage);
        }
    }
  
    function checkIfGroupExists(uint _GroupID) public view returns(bool)
    {    
        if(_Groups[_GroupID].Active)
            return true;
        else
            return false;      
    } 
}

contract UserFuntions is AdminFunctions {
    
    function EditUser(string _Name) public returns (string)
    {
        if(containsAllowedUser(msg.sender) && checkIfUserExists(msg.sender))
        {
            RequestToChangeUserDetails(_Name);
            return ("User has been Updated");
        }
        else
        {
            return ("User not found");
        }
    }
    
    function MakeInvestment() public payable returns(bool){
        if(checkIfUserExists(msg.sender))
        {
            uint _money = uint(msg.value);
            return RequestToMakeInvestment(_money);
        }
    }
    
    function CheckInvestments(uint _GroupID) public view returns(uint){
        if(checkIfUserExists(msg.sender))
        {
           return RequestToCheckInvestments(_GroupID);
        }
    }
}
