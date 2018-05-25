pragma solidity ^0.4.24;

contract Tickets {

  struct Ticket {
    bool paidFor;
    address owner;
  }

  mapping(bytes32 => Ticket) public tickets;
  mapping(address => uint) public pendingTransactions;
  bool public releaseEther;
  uint public ticketPrice;
  address public venueOwner;
  bytes32 public name;
  event TicketKey(bytes32 ticketKey);
  event CanPurchase(bool canPurchase);
  event PaidFor(bool paid);

  modifier onlyOwner() {
    require(msg.sender == venueOwner, "Must be called by owner");
    _;
  }

  modifier notOwner() {
    require(msg.sender != venueOwner, "Must not be called by owner");
    _;
  }

  modifier releaseTrue() {
    require(releaseEther);
    _;
  }

  constructor(uint price, bytes32 title) payable public {
    ticketPrice = price;
    name = title;
    venueOwner = msg.sender;
    releaseEther = false;
  }

  function () payable public {
    releaseEther = false;
  }

  function allowPurchase() onlyOwner public {
    releaseEther = true;
    emit CanPurchase(releaseEther);
  }

  function lockPurchase() onlyOwner public {
    releaseEther = false;
    emit CanPurchase(releaseEther);
  }

  function createTicket() payable notOwner public {
    if (msg.value == ticketPrice) {
      require(pendingTransactions[msg.sender] == 0, "ticket already reserved");
      pendingTransactions[msg.sender] = msg.value;
      bytes32 hash = keccak256(abi.encodePacked(msg.sender, "secret"));
      tickets[hash] = Ticket(false, msg.sender);
      emit TicketKey(hash);
    }
  }

  function unlockEther(bytes32 hash) releaseTrue notOwner public {
    uint amount = pendingTransactions[msg.sender];
    pendingTransactions[msg.sender] = 0;
    venueOwner.transfer(amount);
    tickets[hash].paidFor = true;
    emit PaidFor(true);
  }

  function checkPaidFor(bytes32 hash) constant public returns (bool) {
    return tickets[hash].owner == msg.sender;
  }

  function getTransaction() constant public returns (uint) {
    return pendingTransactions[msg.sender];
  }

  function getOwner(bytes32 hash) constant public returns (address) {
    return tickets[hash].owner;
  }

  function getPaidFor(bytes32 hash) constant public returns (bool) {
    return tickets[hash].paidFor;
  }

  function getTicketPrice() constant public returns (uint) {
    return ticketPrice;
  }

  function getOwnerAddress() onlyOwner constant public returns (address) {
    return venueOwner;
  }

  function getEventName() constant public returns (bytes32) {
    return name;
  }

}
