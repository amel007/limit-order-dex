pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './interfaces/IIndex.sol';

contract Index is IIndex {
    address _addrRoot;
    address _addrOwner;
    uint128 _amount;
    address static _addrOrder;

    constructor(address owner, uint128 amount) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrRoot, address addrOwner, address addrPair, uint8 directionPair, uint64 price) = optSalt
            .get()
            .toSlice()
            .decode(address, address, address, uint8, uint64);
        require(msg.sender == _addrOrder);
        tvm.accept();
        _addrRoot = addrRoot;
        _addrOwner = owner;
        _amount = amount;
    }

    function getInfo() public view override returns (
        address addrRoot,
        address addrOwner,
        address addrOrder,
        uint128 amount
    ) {
        addrRoot = _addrRoot;
        addrOwner = _addrOwner;
        addrOrder = _addrOrder;
        amount = _amount;
    }

    // todo add destruct function
}