/* global artifacts */

const Sale = artifacts.require('./Sale.sol');
const fs = require('fs');
const BN = require('bn.js');

module.exports = (deployer) => {
  const saleConf = JSON.parse(fs.readFileSync('./conf/sale.json'));
  const tokenConf = JSON.parse(fs.readFileSync('./conf/token.json'));

  return deployer.deploy(Sale,
    saleConf.owner,
    saleConf.wallet,
    tokenConf.initialAmount,
    tokenConf.tokenName,
    tokenConf.decimalUnits,
    tokenConf.tokenSymbol,
    saleConf.price,
    saleConf.startBlock,
    saleConf.freezeBlock
  )
    .then((logs) => {
      if (!fs.existsSync('logs')) {
        fs.mkdirSync('logs');
      }
      fs.writeFileSync('logs/logs.json', JSON.stringify(logs, null, 2));
    });
};
