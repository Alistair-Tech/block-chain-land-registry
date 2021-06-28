const LandRegistration = artifacts.require("./LandRegistration.sol");

module.exports = function (deployer) {
  deployer.deploy(LandRegistration);
};
