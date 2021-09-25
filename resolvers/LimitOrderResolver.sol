pragma ton-solidity >= 0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import '../LimitOrder.sol';

contract LimitOrderResolver {
    TvmCell _codeOrder;

    function resolveCodeHash() public view returns (uint256 codeHash) {
        return tvm.hash(_buildOrderCode(address(this)));
    }

    function resolveOrder(
        uint256 id
    ) public view returns (address addrOrder) {
        TvmCell code = _buildOrderCode(address(this));
        TvmCell state = _buildOrderState(code, id);
        uint256 hashState = tvm.hash(state);
        addrOrder = address.makeAddrStd(0, hashState);
    }

    function _buildOrderCode(address addrRoot) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(addrRoot);
        return tvm.setCodeSalt(_codeOrder, salt.toCell());
    }

    function _buildOrderState(
        TvmCell code,
        uint256 id
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: LimitOrder,
            varInit: {_id: id},
            code: code
        });
    }
}