pragma solidity ^0.4.17;

interface Interface0x{

    function Exchange(address _zrxToken, address _tokenTransferProxy) ;
    
    function fillOrder(address[5] orderAddresses, uint[6] orderValues,uint fillTakerTokenAmount,bool shouldThrowOnInsufficientBalanceOrAllowance, uint8 v,bytes32 r, bytes32 s) public returns (uint filledTakerTokenAmount);
    
    function cancelOrder(address[5] orderAddresses,uint[6] orderValues,uint cancelTakerTokenAmount) public returns (uint) ;

    function fillOrKillOrder(address[5] orderAddresses,uint[6] orderValues,uint fillTakerTokenAmount,uint8 v,bytes32 r,bytes32 s) public;

    function batchFillOrders(address[5][] orderAddresses,uint[6][] orderValues, uint[] fillTakerTokenAmounts,bool shouldThrowOnInsufficientBalanceOrAllowance,uint8[] v,bytes32[] r,bytes32[] s)public ;

	function batchFillOrKillOrders(address[5][] orderAddresses,uint[6][] orderValues,uint[] fillTakerTokenAmounts,uint8[] v,bytes32[] r,bytes32[] s) public ;

	function fillOrdersUpTo(address[5][] orderAddresses,uint[6][] orderValues,uint fillTakerTokenAmount, bool shouldThrowOnInsufficientBalanceOrAllowance,uint8[] v,bytes32[] r,bytes32[] s) public returns (uint);

	function batchCancelOrders(address[5][] orderAddresses, uint[6][] orderValues,uint[] cancelTakerTokenAmounts) public;

    function getOrderHash(address[5] orderAddresses, uint[6] orderValues) public constant returns (bytes32);

    function isValidSignature(address signer,bytes32 hash,uint8 v, bytes32 r, bytes32 s) public constant returns (bool);

    function isRoundingError(uint numerator, uint denominator, uint target) public constant returns (bool);

    function getPartialAmount(uint numerator, uint denominator, uint target) public constant returns (uint);

    function getUnavailableTakerTokenAmount(bytes32 orderHash) public constant returns (uint);
}