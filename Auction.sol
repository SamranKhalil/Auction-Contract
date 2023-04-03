// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

contract Auction {
    event Start();
    event End(address highestBidder, uint highestBid);
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);

    address payable public seller;

    bool public started;
    bool public ended;
    uint public endAt;

    uint public highestBid;
    address public highestBidder;
    mapping(address => uint) public bids;

    constructor() {
        seller = payable(msg.sender);
    }

    function start(uint startingBid) external {
        require(!started, "Auction already started!");
        require(msg.sender == seller, "You did not start the auction! "); 
        started = true;
        endAt = block.timestamp + 1 days;
        highestBid = startingBid;
        emit Start();
    }

    function bid() external payable{
        require(started, "Not started yet!");
        require(block.timestamp < endAt, "Ended!");
        require(msg.value > highestBid, "Must bid more than highest bid");

        if (highestBidder != address(0)){
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        emit Bid(msg.sender, msg.value);
    }

    function end() external {
        require(started, "Auction hasn't been started!");
        require(block.timestamp > endAt, "Auction is still ongoing!");
        require(!ended, "Auction already ended!");
        ended = true;
        emit End(highestBidder, highestBid);
    }

    function withdraw() external payable {
        (bool sent, bytes memory data) = payable(msg.sender).call{value: bids[msg.sender]}("");
        require(sent, "Withdrawal failed");
        emit Withdraw(msg.sender, bids[msg.sender]);
    }

}