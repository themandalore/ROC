/*Tests to perform:
Place 10 bids/asks
Have a few takers trade on 0x
*/

var WETH9 = artifacts.require("WETH9");
var Exchange = artifacts.require("Exchange");
var TokenTransferProxy = artifacts.require("TokenTransferProxy");
var OnChain_Relayer = artifacts.require("OnChain_Relayer");
var DummyToken = artifacts.require("DummyToken");

contract('Contracts', function(accounts) {

	let wrapped_ether;
	let exchange;
	let tokenTransferProxy;
	let onchain_relayer;
	let dummyToken;

 it('Setup contracts', async function () {
 	dummyToken = await DummyToken.deployed();
  	console.log(dummyToken.address);
  	onchain_relayer = await OnChain_Relayer.deployed();
  	wrapped_ether = await WETH9.deployed();
  	exchange = await Exchange.deployed();
  	await onchain_relayer.setToken(dummyToken.address);
  	await onchain_relayer.setWrappedEther(wrapped_ether.address);
  	await onchain_relayer.set0x_address(exchange.address);
  	await dummyToken.transfer(accounts[1],500000,{from:accounts[0]});
  	await dummyToken.transfer(accounts[2],500000,{from:accounts[0]});
  	assert.equal(await onchain_relayer.zeroX_address.call(),exchange.address,"0x contract must be successfully set");
  	assert.equal(await dummyToken.balanceOf(accounts[1]),500000,"Account 2 should have 100,000 tokens");
  });
 it('Place Orders', async function () {

 	const ZRX_ADDRESS = await onchain_relayer.zeroX_address.call();
    const WETH_ADDRESS = await onchain_relayer.wrapped_ether_address.call();
    const TOKEN_ADDRESS = await onchain_relayer.token_address.call();
    const NULL_ADDRESS = '0x0000000000000000000000000000000000000000';
    const MAKER = accounts[3];
    const TAKER = '0x0000000000000000000000000000000000000000';
    const salt = web3.toBigNumber(Math.random() * 100000000000000000);

 	const orderHash = await web3.sha3(
      ZRX_ADDRESS, 
      MAKER,
      TAKER,  
      WETH_ADDRESS,
      TOKEN_ADDRESS,
      NULL_ADDRESS,
      web3.toWei(1,'ether'),
      1000,
      0,
      0,
      web3.toBigNumber(2**256 - 1),
      salt
    );
 	console.log(orderHash);
 	signature = await web3.eth.sign(accounts[0],orderHash);
 	const r = signature.slice(0, 64)
    const s = signature.slice(64, 128)
    const v = signature.slice(128, 130) 
 	await onchain_relayer.placeLimit(1000,web3.toWei(1,'ether'),orderHash,salt,v,r,s,{value: web3.toWei(1,'ether'),from:accounts[3]});

 });
 /* it('Fill Order', async function () {
  	await onchain_relayer.placeLimit(1000,web3.toWei(1,'ether'),hash,salt,v,r,s{value: web3.toWei(1,'ether'),from:accounts{3}});
  	await onchain_relayer.takeOrder(hash,amount,{from:accounts{1}});
  	assert.equal(await dummyToken.balanceOf(accounts[3]),1000,"Account 4 should have 1000 tokens now");
 });
   it('Cancel Orders', async function () {

  	await onchain_relayer.placeLimit(1000,web3.toWei(1,'ether'),hash,salt,v,r,s{value: web3.toWei(1,'ether'),from:accounts{3}});
  	await onchain_relayer.cancelLimit(1000,web3.toWei(1,'ether'),hash,salt,v,r,s{value: web3.toWei(1,'ether'),from:accounts{3}});
  	

 });
   it('Fill Partial', async function () {


 });

  it('Free for All!!', async function () {


 });
*/

});