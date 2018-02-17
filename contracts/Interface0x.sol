pragma solidity ^0.4.17;

interface Interface0x{

    function Exchange(address _zrxToken, address _tokenTransferProxy) {}
    
    function fillOrder(address[5] orderAddresses, uint[6] orderValues,uint fillTakerTokenAmount,bool shouldThrowOnInsufficientBalanceOrAllowance, uint8 v,bytes32 r, bytes32 s) public returns (uint filledTakerTokenAmount){}
    
    function cancelOrder(address[5] orderAddresses,uint[6] orderValues,uint cancelTakerTokenAmount) public returns (uint) {}

    function fillOrKillOrder(address[5] orderAddresses,uint[6] orderValues,uint fillTakerTokenAmount,uint8 v,bytes32 r,bytes32 s) public{}

    function batchFillOrders(address[5][] orderAddresses,uint[6][] orderValues, uint[] fillTakerTokenAmounts,bool shouldThrowOnInsufficientBalanceOrAllowance,uint8[] v,bytes32[] r,bytes32[] s)public {}

	function batchFillOrKillOrders(address[5][] orderAddresses,uint[6][] orderValues,uint[] fillTakerTokenAmounts,uint8[] v,bytes32[] r,bytes32[] s) public {}

	function fillOrdersUpTo(address[5][] orderAddresses,uint[6][] orderValues,uint fillTakerTokenAmount, bool shouldThrowOnInsufficientBalanceOrAllowance,uint8[] v,bytes32[] r,bytes32[] s) public returns (uint){}

	function batchCancelOrders(address[5][] orderAddresses, uint[6][] orderValues,uint[] cancelTakerTokenAmounts) public{}

    function getOrderHash(address[5] orderAddresses, uint[6] orderValues) public constant returns (bytes32){}

    function isValidSignature(address signer,bytes32 hash,uint8 v, bytes32 r, bytes32 s) public constant returns (bool){}

    function isRoundingError(uint numerator, uint denominator, uint target) public constant returns (bool){}

    function getPartialAmount(uint numerator, uint denominator, uint target) public constant returns (uint){}

    function getUnavailableTakerTokenAmount(bytes32 orderHash) public constant returns (uint){}
}


contract Wrapped_Ether{


}


//if we make it for just one token pair...it get's way simpler
//We could just wrap their ETH for them...and unwrap it
contract OnChain_Relayer{

    struct data{
        address owner;
        uint amount;
        uint locked;
    }

    struct order{
        bytes32 orderHash;
        address _maker;
        uint amount_sell;
        uint amount_buy;
    }

    address zeroX_address;
    address token_address;
    Interface0x zeroX;

    modifier onlyOwner() {require(msg.sender == owner);_;}

    Interface0x zeroX;
    ERC20Interface Token;

    function OnChain_Relayer(){
        owner = msg.sender;
    }


    function placeLimit(bool _buy, uint _amount, uint _price) public returns(bytes32 _orderHash){

    }

    function cancelLimit(bytes32 _orderHash){

    }

    function takeOrder(bytes32 _orderHash){
        zeroX.fillOrder(address[5] orderAddresses, uint[6] orderValues,uint fillTakerTokenAmount,bool shouldThrowOnInsufficientBalanceOrAllowance, uint8 v,bytes32 r, bytes32 s);

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
    }

    function depositToken(uint _amount) {
      //remember to do: approve(address(this), _amount)
      require(msg.value == 0 && token_add != address(0) && _amount !=0);
      require(Token(token).transferFrom(msg.sender, this, amount));
      tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
      Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
    }

    function withdrawToken(uint _amount) {
      require(msg.value == 0 && token_add != address(0) && _amount !=0);
      require(tokens[token][msg.sender] >= _amount);
      tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);
      if (!Token(token).transfer(msg.sender, amount)) throw;
      Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
    }

    function setToken(address _tokenAddress) public onlyOwner() {
        token_address = _tokenAddress;
    }

    function set0x_address(address _0x) public onlyOwner(){
        zeroX = Interface0x(_0x);
    }

    function setOwner(address _newOwner) public onlyOwner(){
        owner = _newOwner;
    }

}


contract testData{

    bids[] Bids;
    asks[] Asks;

    function placeOrders(){

    }
}