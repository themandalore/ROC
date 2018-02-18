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
 	signature = await web3.eth.sign(accounts[0],data_to_sign);
 	r = signature[0:64]
	s = signature[64:128]
	v = signature[128:130]
 	await onchain_relayer.placeLimit(1000,1,v,r,s{from:accounts{1}});

 });
  it('Fill Orders', async function () {


 });
   it('Cancel Orders', async function () {


 });
   it('Fill Partial', async function () {


 });

  it('Free for All!!', async function () {


 });


});