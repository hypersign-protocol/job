const HID = artifacts.require("HID");
const config = require('../config');
const BigNumber = require('bignumber.js')
module.exports = function(deployer) {
    deployer.deploy(
        ...config.vesting 
    );
};

