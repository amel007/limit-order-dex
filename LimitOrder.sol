pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';

import './interfaces/ILimitOrder.sol';

import './libraries/Constants.sol';


contract LimitOrder is ILimitOrder, IndexResolver {
    address _addrRoot;
    address _addrOwner;

    address _addrPair;
    uint64 _price;
    uint128 _amount;

    constructor(address addrOwner, TvmCell codeIndex, address addrPair, uint64 price, uint128 amount) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrRoot) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrRoot);
        require(msg.value >= Constants.MIN_FOR_DEPLOY);
        tvm.accept();
        _addrRoot = addrRoot;
        _addrOwner = addrOwner;
        _codeIndex = codeIndex;

        _addrPair = addrPair;
        _price = price;
        _amount = amount;

        deployIndex();
    }

    // todo add random salt for codeHash
    function deployIndex() private {
        TvmCell codeIndexOwnerRoot = _buildIndexCode(_addrRoot, _addrOwner, address(0), 0);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: 0.3 ton}(_addrOwner, _amount);

        TvmCell codeIndexPair = _buildIndexCode(_addrRoot, address(0), _addrPair, 0);
        TvmCell stateIndexPair = _buildIndexState(codeIndexPair, address(this));
        new Index{stateInit: stateIndexPair, value: 0.3 ton}(_addrOwner, _amount);

        TvmCell codeIndexPairPrice = _buildIndexCode(_addrRoot, address(0), _addrPair, _price);
        TvmCell stateIndexPairPrice = _buildIndexState(codeIndexPairPrice, address(this));
        new Index{stateInit: stateIndexPairPrice, value: 0.3 ton}(_addrOwner, _amount);
    }

    function getInfo() public view override returns (
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint64 price,
        uint128 amount
    ) {
        addrRoot = _addrRoot;
        addrOwner = _addrOwner;
        addrPair = _addrPair;
        price = _price;
        amount = _amount;
    }
}