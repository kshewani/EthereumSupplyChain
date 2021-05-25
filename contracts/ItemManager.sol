// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// import "@openzeppelin/contracts/access/Ownable.sol";
import "./Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable{
    enum Status {
        Created,
        Paid,
        Delivered
    }

    struct ItemStruct {
        Item _item;
        string _identifier;
        uint _price;
        Status _status;
    }

    mapping(uint => ItemStruct) public items;
    event SupplyChainStep(uint _itemIndex, uint _step, address _itemAddress);
    uint itemIndex;

    function createItem(string memory _itemIdentifier, uint _itemPrice) public onlyOwner {
        Item item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex]._item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex]._item = item;
        items[itemIndex]._identifier = _itemIdentifier;
        items[itemIndex]._price = _itemPrice;
        emit SupplyChainStep(itemIndex,
                             uint(items[itemIndex]._status),
                             address(items[itemIndex]._item));
        itemIndex++;
    }

    function triggerPayment() public payable onlyOwner {
        require(items[itemIndex]._price == msg.value, "Full amount must be paid at once.");
        require(items[itemIndex]._status == Status.Created, "Item is already paid.");
        items[itemIndex]._status = Status.Paid;
        emit SupplyChainStep(itemIndex,
                             uint(items[itemIndex]._status),
                             address(items[itemIndex]._item));
    }

    function triggerDelivery() public onlyOwner {
        require(items[itemIndex]._status == Status.Paid, "Item must be paid before delivery");
        items[itemIndex]._status = Status.Delivered;
        emit SupplyChainStep(itemIndex,
                             uint(items[itemIndex]._status),
                             address(items[itemIndex]._item));
    }
}