
/**
 * Copyright (c) 2018-present, Leap DAO (leapdao.org)
 *
 * This source code is licensed under the Mozilla Public License, version 2,
 * found in the LICENSE file in the root directory of this source tree.
 */

pragma solidity 0.5.2;

import "./Vault.sol";
import "./Bridge.sol";

contract DepositHandler is Vault {

  event NewDeposit(
    uint32 indexed depositId, 
    address indexed depositor, 
    uint256 indexed color, 
    uint256 amount
  );

  struct Deposit {
    uint64 time;
    uint16 color;
    address owner;
    uint256 amount;
  }

  uint32 public depositCount;

  mapping(uint32 => Deposit) public deposits;

  // Cryptonian
  event NewDepositState (
    uint32  indexed depositId,
    address indexed depositor,
    uint256 indexed color,
    uint256 tokenId,
    string target,
    string state
  );
  struct DepositState {
    uint64 time;
    uint16 color;
    address owner;
    uint256 tokenId;
    string target;
    string state;
  }
  // Cryptonian .. hm.. 굳이 deposit과 depositState 를 구별해서 관리할 필요가 있을까?
  uint32 public depositStateCount;
  mapping(uint32 => DepositState) public depositStates;

  // Cryptonian - deposit 함수를 따로 만들 필요는 없을 듯!!.. 
  //  현재 Non-Fungible Storage Token을 상대하기 위함인데.. 토큰 안에 있는 State를 Event로 보낼려고 하는 것이다.
  //  [Problem] 이럴 경우.. 각 NST 마다 어떤 State를 보내야하는지 결정해야하는 점이 존재한다..
      // 예를 들어 NaiveStorageToken 은 TokenID ==> map (key,value)인데.. 이걸 어찌 다보내는가?
      // PatriciaTree가 적용된 경우 TokenID ==> StorageRoot 인데.. StorageRoot 에 해당하는 트리는 어찌 보내는가??

   /**
   * @notice Add to the network `(_amountOrTokenId)` amount of a `(_color)` tokens
   * or `(_amountOrTokenId)` token id if `(_color)` is NFT.
   * @dev Token should be registered with the Bridge first.
   * @param _owner Account to transfer tokens from
   * @param _amountOrTokenId Amount (for ERC20) or token ID (for ERC721) to transfer
   * @param _color Color of the token to deposit
   */
  function deposit(address _owner, uint256 _amountOrTokenId, uint16 _color) public {
    TransferrableToken token = tokens[_color].addr;
    require(address(token) != address(0), "Token color not registered");
    token.transferFrom(_owner, address(this), _amountOrTokenId);

    bytes32 tipHash = bridge.tipHash();
    uint256 timestamp;
    (,,, timestamp) = bridge.periods(tipHash);

    depositCount++;
    deposits[depositCount] = Deposit({
      time: uint32(timestamp),
      owner: _owner,
      color: _color,
      amount: _amountOrTokenId
    });
    emit NewDeposit(
      depositCount, 
      _owner, 
      _color, 
      _amountOrTokenId
    );
  }


  //Cryptonian #2 Having a second thought.. we NEED depositState funtion to specify which data to be deposited..
  function depositState(
    address _owner, 
    uint256 tokenId, 
    string memory stateKey, 
    uint16 _color) public {
//  Cryptonian.. commented out : compile error [DeclarationError: Identifier already declared.]
//    NaiveStorageToken nsToken = token[_color].addr;

    TransferrableToken nsToken = tokens[_color].addr;
    require(address(nsToken) != address(0), "Token color not registered");
    require(_color >= 32769, "Not Non-Fungible Token..");
    nsToken.transferFrom(_owner, address(this), tokenId);

    //uint256 stateValue = nsToken.read(tokenId, stateKey);
    string memory stateValue = "0x000";

  
    bytes32 tipHash = bridge.tipHash();       // tipHash가 어떤의미인지 파악 필요.. copied from the above..
    uint256 timestamp;
    (,,, timestamp) = bridge.periods(tipHash);

    depositStateCount++;
   
    depositStates[depositStateCount] = DepositState({
      //time: uint32(timestamp),
      time: 0,
      color: _color,
      owner: _owner,
      tokenId: tokenId,
      target: stateKey,
      state: stateValue
    });

    emit NewDepositState(
      depositStateCount, 
      _owner, 
      _color,
      tokenId,
      stateKey,
      stateValue
    ); 
  }

  // solium-disable-next-line mixedcase
  uint256[50] private ______gap;
}