pragma solidity ^0.4.17;

import "./WETH9.sol";
import "./Interface0x.sol";
import "./TokenTransferProxy.sol";
import "./SafeMath.sol"; 

contract OnChain_Relayer is SafeMath{


    struct SpecificOrder {
        int amount;
        uint price;
        address maker;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    mapping(bytes32 => SpecificOrder[]) order_details;
    mapping(bytes32 => uint) order_index;
    bytes32[] public orders;


    address public zeroX_address;
    address public token_address;
    address public wrapped_ether_address;
    address public token_transfer_proxy_address;
    Interface0x zeroX;
    Token ERC20Token;
    WETH9 Wrapped_Ether;
    TokenTransferProxy TTP;

    modifier onlyOwner() {require(msg.sender == owner);_;}

    event NewOrder(bytes32 _hash,int _amount,uint _price);
    event FilledOrder(bytes32 _hash, int _amount, uint _price);
    event CancelledOrder(bytes32 _hash,int _amount,uint _price);

    Interface0x zeroX;
    

    function OnChain_Relayer(){
        owner = msg.sender;
        order_details[0].push(SpecificOrder({
              amount: 0,
              price: 0,
              maker: address[0],
              v= 0,
              r=0,
              s=0
            }));
        orders.push(0);
    }


    function placeLimit(int _amount, uint _price,uint8 _v,bytes32 _r,bytes32 _s) payable public returns(bytes32 _orderHash){
        require(_amount !=0);
        if(_amount > 0){
            require(safeMul(_amount,_price) > msg.value);
            Wrapped_Ether.delegatecall(bytes4(sha3("deposit(uint)")), msg.value);
            Wrapped_Ether.delegatecall(bytes4(sha3("approve(address,uint)"))zeroX_address, msg.value);
        }
        else{
            ERC20Token.delegatecall(bytes4(sha3("approve(address,uint)")), zeroX_address,msg.value);
        }
        uint nonce = orders.length();
        bytes32 hash = keccak256(msg.sender,_amount,_price,now(),nonce);
        order_details[hash].push(SpecificOrder({
              amount: _amount,
              price: _price,
              maker: msg.sender,
              v= 0,
              r=0,
              s=0
            }));
        orders.push(hash);
    }

    function cancelLimit(bytes32 _orderHash) returns(bool success){
        removeOrder(_orderHash);
        return true;

    }

    function removeOrder(bytes32 _remove) internal {
    uint last_index = orders.length;
    bytes32 last_hash = orders[last_index];
    //If the hash we want to remove is the final hash in array
    if (last_hash != _remove) {
      uint remove_index = order_index[_remove];
      //Update the order index of the last hash to that of the removed hash index
      order_index[last_hash] = remove_index;
      //Set the order of the removed index to the order of the last hash
      orders[remove_index] = orders[last_index];
    }
    //Remove the order index for this address
    delete order_index[_remove];
    //Finally, decrement the order balances length
    orders.length = orders.length.sub(1);
  }

    function takeOrder(bytes32 _orderHash) public returns(bool _success){

        address[5] orderAddresses;
        uint[6] orderValues;

        bool success = zeroX.fillOrder(orderAddresses,orderValues,uint fillTakerTokenAmount,bool shouldThrowOnInsufficientBalanceOrAllowance, uint8 v,bytes32 r, bytes32 s);

            maker: orderAddresses[0],
            taker: orderAddresses[1],
            makerToken: orderAddresses[2],
            takerToken: orderAddresses[3],
            feeRecipient: orderAddresses[4],
            makerTokenAmount: orderValues[0],
            takerTokenAmount: orderValues[1],
            makerFee: orderValues[2],
            takerFee: orderValues[3],
            expirationTimestampInSec: orderValues[4],

     if(success){
        removeOrder(_orderHash);
        returns true;
     }
     else{
        returns false ;
     }
    }

    function setToken(address _tokenAddress) public onlyOwner() {
        token_address = _tokenAddress;
        ERC20Token = Token(token_address);
    }

    function setWrappedEther(address _tokenAddress) public onlyOwner() {
        wrapped_ether_address = _tokenAddress;
        Wrapped_Ether = WETH9(wrapped_ether_address);
    }

    function set0x_address(address _0x) public onlyOwner(){
        zeroX_address = _0x;
        zeroX = Interface0x(_0x);
    }

    function setTokenTransferProxy(address _ttp) public onlyOwner(){
        token_transfer_proxy_address = _ttp;
        TTP = TokenTransferProxy(_ttp);
    }

    function setOwner(address _newOwner) public onlyOwner(){
        owner = _newOwner;
    }

    function getInfo(bytes32 _hash)constant public returns(int _amount, uint _price, address _maker){
        returns(SpecificOrder[_hash].amount,SpecificOrder[_hash].price,SpecificOrder[_hash].maker);
    }
}