var WETH9 = artifacts.require("./WETH9.sol");
var Exchange = artifacts.require("./Exchange.sol");
var TokenTransferProxy = artifacts.require("./TokenTransferProxy.sol");
var OnChain_Relayer = artifacts.require("./OnChain_Relayer.sol");

module.exports = function(deployer){
  deployer.deploy(WETH9);
  deployer.deploy(Exchange);
  deployer.deploy(OnChain_Relayer);
  deployer.deploy(TokenTransferProxy);
}