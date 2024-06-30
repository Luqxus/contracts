// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract Ticketz {
    struct Event {
        address owner; 
        uint eventId;
        string description;
        string title;
        string websiteUrl;
        uint total_tickets;
        uint sales;
        uint256 ticket_price;
        bytes32[] tickets; 
        // mapping (address => uint) buyers;
        bool isOpen;
    }

    struct Ticket {
        uint eventId;
        bytes32 ticketId;
        string title;
        string description;
        string websiteUrl;
        uint256 ticket_price;
        uint quantity;
    }

    mapping (address => Ticket[]) buyers;
    mapping (uint => Event) events;
    uint total_events = 0;
    mapping (uint => uint256) eventBalances; 


    function getEvents() external view returns (Event[] memory) {
        Event[] memory _events = new Event[](total_events);

        for (uint _i = 0; _i < total_events; _i++) {
            _events[_i] = events[_i];
        }
        return  _events;
    }


    function getEvent(uint _id) external view returns (Event memory) {
        return events[_id];
    }


    function buyTicket(uint _id, uint _quantity) public payable  {
        require(events[_id].eventId == _id, "404");
        require(events[_id].sales < events[_id].total_tickets);
        require(_quantity > 0, "405");
        require(msg.value >= events[_id].ticket_price, "500");
        bytes32 t_id = keccak256(abi.encodePacked(_id, msg.sender,buyers[msg.sender].length + 1));
        buyers[msg.sender].push(
            Ticket (
                _id,   
                t_id,
                events[_id].title,
                events[_id].description,
                events[_id].websiteUrl,
                events[_id].ticket_price,
                 _quantity
            )
        );
        
        
        // TODO: update sales count
        events[_id].sales += 1;
        events[_id].tickets.push(t_id);
        // TODO: update events' balance 
        eventBalances[_id] += msg.value;
    }

    function getTicket(bytes32 ticket_id) public view returns (Ticket memory) {
        
        bool isFound = false;

        Ticket memory t;

        for (uint _i = 0; _i < buyers[msg.sender].length; _i++) {
            if (buyers[msg.sender][_i].ticketId == ticket_id) {
                t = buyers[msg.sender][_i];
                break;
            }
        }

        require(isFound, "TICKET NOT FOUND");

        return t;
    }

    function getTickets() public view returns (Ticket[] memory) {
        return buyers[msg.sender];
    }


    function createEvent(
        string calldata _title,
        string calldata _description,
        string calldata _websiteUrl,
        uint _total_tickets,
        uint256 _ticket_price,
        bool _is_open
        ) public {

            Event memory e;
            uint _id =  total_events + 1;
            e.eventId = _id;
            e.title = _title;
            e.description = _description;
            e.websiteUrl = _websiteUrl;
            e.total_tickets = _total_tickets;
            e.ticket_price = _ticket_price;
            e.isOpen = _is_open;
            e.sales = 0;

            events[_id] = e;
            total_events += 1;
    }


    function confirmTicket(uint _id, bytes32 _ticket_id) public view returns (bool) {
        for (uint _i; _i < events[_id].tickets.length; _i++) {
            if (events[_id].tickets[_i] == _ticket_id) {
                return true;
            }
        }
        return false;
    }
}