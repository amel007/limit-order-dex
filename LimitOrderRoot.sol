pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/LimitOrderResolver.sol';

import './interfaces/ILimitOrder.sol';
import './interfaces/ILimitOrderRoot.sol';

contract LimitOrderRoot is LimitOrderResolver, IndexResolver, ILimitOrderRoot {

    uint256 _deployedNumber;

    constructor(TvmCell codeIndex, TvmCell codeOrder) public {
        tvm.accept();
        _codeIndex = codeIndex;
        _codeOrder = codeOrder;
    }

    function createOrder(
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint64 price,
        uint128 amount,
        address walletOwner
    ) public override {
        // todo check if msg.sender == addrRouter
        TvmCell codeOrder = _buildOrderCode(address(this));
        TvmCell stateOrder = _buildOrderState(codeOrder, _deployedNumber);
        new LimitOrder{stateInit: stateOrder, value: 1.2 ton}(_codeIndex, addrOwner, addrPair, directionPair, price, amount, walletOwner);

        _deployedNumber++;
    }
}