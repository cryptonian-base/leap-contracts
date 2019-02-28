/**
 * Copyright (c) 2018-present, Leap DAO (leapdao.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

const log = require('./utils/log');

const NativeToken = artifacts.require('NativeToken');
//Cryptonian
const StorageToken = artifacts.require('NaiveStorageToken')

module.exports = (deployer) => {
  deployer.then(async () => {
    const nativeToken = await deployer.deploy(NativeToken, "LeapToken", "LEAP", 18);
    log('Deployed LEAP Token at', nativeToken.address);

    //Cryptonian
    const nfStorageToken = await deployer.deploy(StorageToken, "StorageToken", "BASE");
    log('Deployed NaiveStorageToken at', nfStorageToken.address);
    
  });

};
