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
    

    function OnChain_Relayer() publci {
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
            require(safeMul(_amount,_price) == msg.value);
            Wrapped_Ether.delegatecall(bytes4(sha3("deposit(uint)")), msg.value);
            Wrapped_Ether.delegatecall(bytes4(sha3("approve(address,uint)"))zeroX_address, msg.value);
            require(Wrapped_Ether.allowance(msg.sender,zeroX_address,msg.value));
        }
        else{
            require(msg.value == 0);
            ERC20Token.delegatecall(bytes4(sha3("approve(address,uint)")), zeroX_address,msg.value);
            require(ERC20Token.allowance(msg.sender,zeroX_address,msg.value));
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
        NewOrder(hash,_amount,_price);
    }

    function cancelLimit(bytes32 _orderHash) public returns(bool success){
        removeOrder(_orderHash);
        (int _amount, uint _price, address _maker) = getInfo(_orderHash);
        CancelledOrder(_orderHash,_amount,_price);
        return true;

    }

    function takeOrder(bytes32 _orderHash) payable public returns(bool _success){
        (int _amount, uint _price, address _maker) = getInfo(_orderHash);
        (uint8 _v,bytes32 _r, bytes32 _s) = getSignature(_orderHash);
        address makerToken;address takerToken;uint makerTokenAmount;uint takerTokenAmount;
        if(_amount > 0){
            require(msg.value == 0);
            makerToken = wrapped_ether_address;
            takerToken = token_address;
            makerTokenAmount = safeMul(_amount,_price);
            takerTokenAmount = _amount;
            ERC20Token.delegatecall(bytes4(sha3("approve(address,uint)")), zeroX_address,msg.value);
            require(ERC20Token.allowance(msg.sender,zeroX_address,msg.value));
        }
        else {
            require(safeMul(_amount,_price) == msg.value);
            Wrapped_Ether.delegatecall(bytes4(sha3("deposit(uint)")), msg.value);
            Wrapped_Ether.delegatecall(bytes4(sha3("approve(address,uint)"))zeroX_address, msg.value);
            require(Wrapped_Ether.allowance(msg.sender,zeroX_address,msg.value));
            makerToken = token_address;
            takerToken = wrapped_ether_address;
            makerTokenAmount = _amount;
            takerTokenAmount = safeMul(_amount,_price);
        }
        address[5] orderAddresses = [_maker,msg.sender,makerToken,takerToken,owner];
        uint[6] orderValues = [makerTokenAmount,takerTokenAmount,0,0,safeAdd(block.timestamp + 86400),0];
        //zeroX.fillOrder(orderAddresses,orderValues,uint fillTakerTokenAmount,bool shouldThrowOnInsufficientBalanceOrAllowance, uint8 v,bytes32 r, bytes32 s);
        uint _taken = zeroX.fillOrder(orderAddresses,orderValues,takerTokenAmount,false,_v,_r,_s);
     if(_taken > 0){
        removeOrder(_orderHash);
        FilledOrder(_orderHash,_amount,_price);
        returns true;
     }
     else{
        cancelLimit(_orderHash);
        returns false ;
     }
    }

    function getInfo(bytes32 _hash)constant public returns(int _amount, uint _price, address _maker){
        returns(SpecificOrder[_hash].amount,SpecificOrder[_hash].price,SpecificOrder[_hash].maker);
    }

    function getSignature(bytes32 _hash) constant internal returns(uint8 _v,bytes32 _r, bytes32 _s){
        returns(SpecificOrder[_hash].v,SpecificOrder[_hash].r,SpecificOrder[_hash].s)
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
}