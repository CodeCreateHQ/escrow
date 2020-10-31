pragma solidity >=0.4.17 <0.7.0;

contract EscrowFactory {
    address[] public deployedEscrows;

    function createCampaign(address _seller) public payable {
        address newEscrow = new Escrow(msg.sender, _seller);
        deployedEscrows.push(newEscrow);
    }

    function getDeployedEscrows() public view returns (address[]) {
        return deployedEscrows;
    }
}

contract Escrow {
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE }

    address public buyer;
    address public seller;

    uint public balance;
    State public currState = State.AWAITING_PAYMENT;

    constructor(address _buyer, address _seller) public {
        buyer = _buyer;
        seller = _seller;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this method");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }

    function deposit() onlyBuyer external payable {
        require(currState == State.AWAITING_DELIVERY, "Already awaiting delivery");
        currState = State.AWAITING_DELIVERY;
    }

    function confirmDelivery() onlySeller external {
        require(currState == State.COMPLETE, "Delivery already complete");
        seller.transfer(address(this).balance);
        currState = State.COMPLETE;
    }
}