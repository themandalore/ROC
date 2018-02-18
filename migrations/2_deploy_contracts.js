var WETH9 = artifacts.require("./WETH9.sol");
var Exchange = artifacts.require("./Exchange.sol");
var TokenTransferProxy = artifacts.require("./TokenTransferProxy.sol");
var OnChain_Relayer = artifacts.require("./OnChain_Relayer.sol");
var DummyToken = artifacts.require("./DummyToken.sol");

module.exports = function(deployer){
  deployer.deploy(WETH9);
  deployer.deploy(OnChain_Relayer);
  deployer.deploy(TokenTransferProxy).then(function(){
  	return deployer.deploy(DummyToken,1000000,"Unicorn Blood",18,"ROCS").then(function(){
  		return deployer.deploy(Exchange, DummyToken.address,TokenTransferProxy.address);
  	});
  });
}