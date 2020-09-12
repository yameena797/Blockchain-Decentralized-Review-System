pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;

contract Bln {
    /*bytes32 i;
    
    function setbln(bytes32 _i) public{
        i = _i;
    }
    
    function getbln() public view returns (bytes32) {
        return i;
    }*/
    address payable ServiceProviderEA;
    address payable ReviewerAddress;
    uint256 Incentive = 1 ether;
    mapping (address => uint256) Ticket;
    mapping (address => uint256) ipfsval;
    uint ReviewNo;
    uint256 ticket;
    mapping (address => uint) private balances;
    uint value;
    //bytes ipfsHash = '';
    bytes[] ipfshash;
    
    event TicketGeneration(address commentor, uint256 ticketno, string s);
    //event TicketGenerationFailed(address commentor, string s);
    event LogDepositMade(address indexed accountAddress, uint amount, string s);
    //event LogDepositFailed(address indexed accountAddress, uint amount, string s);
    
    event ReviewPub(address rev, bytes ipfs, string s);
    
    event RewardSent(address payable ReviewrAddr, uint256 Incentive, string s);
    
    modifier ServiceProviderOnly {
        require(msg.sender == ServiceProviderEA);
        _;
    }
    
    constructor() public {
        ServiceProviderEA = msg.sender;
        //Incentive = 1 ether;
        ReviewNo = 0;
    }
    
    /*function get() public view returns (address) {
        return ServiceProviderEA;
    }*/
    
    function TicketGenerator(address payable commentor) ServiceProviderOnly public {
        require(commentor != msg.sender && address(this).balance >= Incentive && Ticket[commentor] == 0x0, "Token Generation Failed");
        ticket = uint256(keccak256(abi.encodePacked(block.timestamp, commentor, ReviewNo)));
        Ticket[commentor] = ticket;
        ipfsval[commentor] = ticket;
        ReviewerAddress = commentor;
        emit TicketGeneration(commentor, ticket, "Token Generated Succesfully");
    }
    
    function GetTicket() public view returns (uint256) {
        return ticket;
    }
   
   function FundsDeposit() ServiceProviderOnly public payable {
        require(msg.value == 2 ether, "2 ether initial funding required");
        balances[ServiceProviderEA] += msg.value;
        emit LogDepositMade(msg.sender, msg.value, "Funds Succesfully Deposited!");
    }
    
    function showbalance() public view returns (uint) {
        return address(this).balance;
    }

    function Validate(address payable addr) public returns (bool){
        if( Ticket[addr] != 0x0 && ipfsval[addr] ==  Ticket[addr]){
        ReviewerAddress = addr;
        return true;
        }
        return false;
    }
    
    function StoreRevHash(bytes memory ipfs, address payable addr) public {
        require(Validate(addr), "Error Posting Review");
        ipfshash.push(ipfs);
        Ticket[ReviewerAddress] = 0x0;
        ReviewNo ++;
        emit ReviewPub(ReviewerAddress, ipfs, "Review Successfully Published");
    }
    
    function GetHashAtIndex(uint i) public view returns (bytes memory) {
         return ipfshash[i];
    }
    
    function GetArrayLen() public view returns (uint) {
         return ipfshash.length;
    }
    
    function RewardGiven() public payable{
        require(address(this).balance >= Incentive, "Error Sendind Reward");
        ReviewerAddress.transfer(Incentive);
        emit RewardSent(ReviewerAddress, Incentive, "Reward has been Deposited");        
    }    
}
