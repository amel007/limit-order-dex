pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './interfaces/IIndex.sol';

contract Index is IIndex {

    address static _addrOrder;

    constructor() public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrRoot, address addrOwner, address addrPair, uint128 price) = optSalt
            .get()
            .toSlice()
            .decode(address, address, address, uint128);
        require(msg.sender == _addrOrder);
        tvm.accept();
    }

    function getInfo() public view override returns (
        address addrOrder
    ) {
        addrOrder = _addrOrder;
    }

    function destruct() public override {
        require(msg.sender == _addrOrder);
        selfdestruct(_addrOrder);
    }
}
