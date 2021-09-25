pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/LimitOrderResolver.sol';
import './LimitOrderRouter.sol';

import './interfaces/ILimitOrder.sol';
import './interfaces/ILimitOrderRoot.sol';
import './interfaces/ILimitOrderRouter.sol';

import './libraries/Constants.sol';

contract LimitOrderRoot is LimitOrderResolver, IndexResolver, ILimitOrderRoot {

  uint256 _deployedNumber;
  address public _deployedAddress;
  address public _deployedRouter;

  modifier checkOwnerAndAccept {
    require(msg.pubkey() == tvm.pubkey(), 101);
    tvm.accept();
    _;
  }

  constructor(TvmCell codeIndex, TvmCell codeOrder, TvmCell codeRouter, address[] rootArr) public {
    require(address(this).balance >= Constants.FOR_ROUTER + (Constants.FOR_WALLET_DEPLOY + Constants.SEND_MSG) * uint128(rootArr.length), 102);
    tvm.accept();
    _codeIndex = codeIndex;
    _codeOrder = codeOrder;

    TvmCell stateInit = tvm.buildStateInit({
      contr: LimitOrderRouter,
      varInit: {rootLimitOrder:address(this)},
      code: codeRouter,
      pubkey: tvm.pubkey()
    });
    _deployedAddress = new LimitOrderRouter{
      stateInit: stateInit,
      flag: 0,
      bounce : false,
      value : Constants.FOR_ROUTER + (Constants.FOR_WALLET_DEPLOY + Constants.SEND_MSG)* uint128(rootArr.length)
    }(rootArr);

  }

  function deployRouterCallback(address router) public override {
    tvm.rawReserve(address(this).balance - msg.value, 2);
    require(msg.sender == _deployedAddress && router == _deployedAddress, 103);
    _deployedRouter = router;
  }

  function connectRouterToRoot(address root) public checkOwnerAndAccept {
    TvmCell body = tvm.encodeBody(ILimitOrderRouter(_deployedRouter).deployEmptyWalletFor, root);
    _deployedRouter.transfer({value: 0.1 ton + Constants.FOR_WALLET_DEPLOY + Constants.SEND_MSG, bounce:true, flag: 0, body:body});
  }

  function createOrder(
    address addrOwner,
    address addrPair,
    uint8 directionPair,
    uint128 price,
    uint128 amount,
    address walletOwnerRoot,
    address walletOwnerFrom,
    address walletOwnerTo
  ) public override {
    tvm.rawReserve(address(this).balance - msg.value, 2);
    require(msg.sender == _deployedRouter, 104);
    TvmCell codeOrder = _buildOrderCode(address(this));
    TvmCell stateOrder = _buildOrderState(codeOrder, _deployedNumber);
    new LimitOrder{stateInit: stateOrder, value: Constants.FOR_DEPLOY_ORDER}(
      _codeIndex,
      _deployedRouter,
      addrOwner,
      addrPair,
      directionPair,
      price,
      amount,
      walletOwnerRoot,
      walletOwnerFrom,
      walletOwnerTo
    );
    _deployedNumber++;
    addrOwner.transfer({value: 0, bounce:true, flag: 128});
  }

  function cancelOrder(
    uint256 id,
    uint128 amount,
    address walletOwnerRoot,
    address walletOwnerFrom
  ) public override {
    address addrData = resolveOrder(id);
    require(msg.sender == addrData);
    ILimitOrderRouter(_deployedRouter).cancelOrder{value: 0, flag: 64}(
      addrData,
      amount,
      walletOwnerRoot,
      walletOwnerFrom
    );
  }
}
