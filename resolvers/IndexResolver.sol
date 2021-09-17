pragma ton-solidity >= 0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import '../Index.sol';

contract IndexResolver {
    TvmCell _codeIndex;

    function resolveCodeHashIndex(
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint64 price
    ) public view returns (uint256 codeHashIndex) {
        return tvm.hash(_buildIndexCode(addrRoot, addrOwner, addrPair, price));
    }

    function _buildIndexCode(
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint64 price
    ) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(addrRoot);
        salt.store(addrOwner);
        salt.store(addrPair);
        salt.store(price);
        return tvm.setCodeSalt(_codeIndex, salt.toCell());
    }

    function _buildIndexState(
        TvmCell code,
        address addrOrder
    ) internal virtual pure returns (TvmCell) {
        return tvm.buildStateInit({
            contr: Index,
            varInit: {_addrOrder: addrOrder},
            code: code
        });
    }
}