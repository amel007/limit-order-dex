pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/LimitOrderResolver.sol';

import './interfaces/ILimitOrder.sol';

contract LimitOrderRoot is LimitOrderResolver, IndexResolver {

    uint256 _deployedNumber;

    constructor(TvmCell codeIndex, TvmCell codeOrder) public {
        tvm.accept();
        _codeIndex = codeIndex;
        _codeOrder = codeOrder;
    }

    // todo add rand salt to codeHash
    // todo add direction
    function createOrder(address addrOwner, address addrPair, uint64 price, uint128 amount) public {
        // todo check if msg.sender == addrRouter
        TvmCell codeOrder = _buildOrderCode(address(this));
        TvmCell stateOrder = _buildOrderState(codeOrder, _deployedNumber);
        new LimitOrder{stateInit: stateOrder, value: 1.2 ton}(addrOwner, _codeIndex, addrPair, price, amount);

        _deployedNumber++;
    }
}