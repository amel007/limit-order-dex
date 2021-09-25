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
        uint8 directionPair,
        uint128 price
    ) public view returns (uint256 codeHashIndex) {
        return tvm.hash(_buildIndexCode(addrRoot, addrOwner, addrPair, directionPair, price));
    }

    function resolveIndex(
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint128 price,
        address addrOrder
    ) public view returns (address addrIndex) {
        TvmCell code = _buildIndexCode(addrRoot, addrOwner, addrPair, directionPair, price);
        TvmCell state = _buildIndexState(code, addrOrder);
        uint256 hashState = tvm.hash(state);
        addrIndex = address.makeAddrStd(0, hashState);
    }

    function _buildIndexCode(
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint128 price
    ) internal virtual view returns (TvmCell) {
        TvmBuilder salt;
        salt.store(addrRoot);
        salt.store(addrOwner);
        salt.store(addrPair);
        salt.store(directionPair);
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
