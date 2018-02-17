var weth = artifacts.require("./WETH9.sol");
var Exchange = artifacts.require("./Exchange.sol");
var OnChain_Relayer = artifacts.require("./OnChain_Relayer.sol");

module.exports = function(deployer){
  deployer.deploy(WETH9.sol);
  deployer.deploy(Exchange.sol);
  deployer.deploy(OnChain_Relayer.sol);
}