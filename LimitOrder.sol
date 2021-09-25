pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';

import './interfaces/ILimitOrder.sol';
import './interfaces/ILimitOrderRoot.sol';
import './libraries/Constants.sol';
import './interfaces/ILimitOrderRouter.sol';

contract LimitOrder is ILimitOrder, IndexResolver {
    address _addrRoot;
    address _addrRouter;
    address _addrOwner;

    address _addrPair;
    uint8 _directionPair;
    uint128 _price;
    uint128 _amount;
    address _walletOwnerRoot;
    address _walletOwnerFrom;
    address _walletOwnerTo;

    uint8 _status;

    uint256 static _id;

    modifier checkOwnerCanEdit {
        require(msg.sender == _addrOwner);
        require(_status == Constants.STATUS_ACTIVE);
        require(msg.value >= Constants.FOR_EDIT_ORDER);
        _;
    }

    modifier checkOwnerCanCancel {
        require(msg.sender == _addrOwner);
        require(_status == Constants.STATUS_ACTIVE);
        require(msg.value >= Constants.FOR_CANCEL_ORDER);
        _;
    }

    constructor(
        TvmCell codeIndex,
        address addrRouter,
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint128 price,
        uint128 amount,
        address walletOwnerRoot,
        address walletOwnerFrom,
        address walletOwnerTo
    ) public {
        optional(TvmCell) optSalt = tvm.codeSalt(tvm.code());
        require(optSalt.hasValue(), 101);
        (address addrRoot) = optSalt.get().toSlice().decode(address);
        require(msg.sender == addrRoot, 102);
        require(msg.value >= Constants.MIN_FOR_DEPLOY, 103);
        tvm.accept();
        _addrRoot = addrRoot;
        _addrOwner = addrOwner;
        _codeIndex = codeIndex;
        _addrRouter = addrRouter;
        _addrPair = addrPair;
        _directionPair = directionPair;
        _price = price;
        _amount = amount;
        _walletOwnerRoot = walletOwnerRoot;
        _walletOwnerFrom = walletOwnerFrom;
        _walletOwnerTo = walletOwnerTo;
        _status = Constants.STATUS_ACTIVE;

        deployIndexRoot();
    }

    function deployIndexRoot() private {
        deployIndexOwner();
        deployIndexPair();
        deployIndexPairPrice();
    }

    function deployIndexOwner() private {
        (address addrRoot, address addrOwner, address addrPair, uint8 directionPair, uint128 price) = getParamsIndexOwner();
        deployIndex(addrRoot, addrOwner, addrPair, directionPair, price);
    }

    function deployIndexPair() private {
        (address addrRoot, address addrOwner, address addrPair, uint8 directionPair, uint128 price) = getParamsIndexPair();
        deployIndex(addrRoot, addrOwner, addrPair, directionPair, price);
    }

    function deployIndexPairPrice() private {
        (address addrRoot, address addrOwner, address addrPair, uint8 directionPair, uint128 price) = getParamsIndexPairPrice();
        deployIndex(addrRoot, addrOwner, addrPair, directionPair, price);
    }

    function destructIndexOwner() private {
        (address addrRoot, address addrOwner, address addrPair, uint8 directionPair, uint128 price) = getParamsIndexOwner();
        destructIndex(addrRoot, addrOwner, addrPair, directionPair, price);
    }

    function destructIndexPair() private {
        (address addrRoot, address addrOwner, address addrPair, uint8 directionPair, uint128 price) = getParamsIndexPair();
        destructIndex(addrRoot, addrOwner, addrPair, directionPair, price);
    }

    function destructIndexPairPrice() private {
        (address addrRoot, address addrOwner, address addrPair, uint8 directionPair, uint128 price) = getParamsIndexPairPrice();
        destructIndex(addrRoot, addrOwner, addrPair, directionPair, price);
    }

    function deployIndex(
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint128 price
    ) private {
        TvmCell codeIndexOwnerRoot = _buildIndexCode(addrRoot, addrOwner, addrPair, directionPair, price);
        TvmCell stateIndexOwnerRoot = _buildIndexState(codeIndexOwnerRoot, address(this));
        new Index{stateInit: stateIndexOwnerRoot, value: Constants.FOR_DEPLOY_INDEX}();
    }

    function destructIndex(
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint128 price
    ) private {
        address oldIndex = resolveIndex(addrRoot, addrOwner, addrPair, directionPair, price, address(this));
        IIndex(oldIndex).destruct();
    }

    function getParamsIndexOwner() private view returns (
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint128 price
    ) {
        addrRoot = _addrRoot;
        addrOwner = _addrOwner;
        addrPair = address(0);
        directionPair = 0;
        price = 0;
    }

    function getParamsIndexPair() private view returns (
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint128 price
    ) {
        addrRoot = _addrRoot;
        addrOwner = address(0);
        addrPair = _addrPair;
        directionPair = _directionPair;
        price = 0;
    }

    function getParamsIndexPairPrice() private view returns (
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint128 price
    ) {
        addrRoot = _addrRoot;
        addrOwner = address(0);
        addrPair = _addrPair;
        directionPair = _directionPair;
        price = _price;
    }

    function applyOrder(uint128 receivedAmount, uint128 price, uint idCallback) public override {
        require(msg.sender == _addrRouter);
        uint128 checkAmount = receivedAmount/price;
        bool result;
        if (_amount >= checkAmount && _price == price && _status == Constants.STATUS_ACTIVE) {
            _status = Constants.STATUS_EXCHANGE;
            result = true;
        } else {
            result = false;
        }
        ILimitOrderRouter(_addrRouter).applyOrder{value: 0, flag: 64}(result, idCallback, checkAmount, _walletOwnerRoot, _walletOwnerTo);
    }

    function applyOrderCallback(bool result, uint128 amount, address originalGasTo) public override {
        require(msg.sender == _addrRouter);
        require(_status == Constants.STATUS_EXCHANGE);

        _status = Constants.STATUS_ACTIVE;
        if (result == true) {
            _amount -= amount;
        }

        if (_amount == 0) {
            destructOrder();
        }
        originalGasTo.transfer({value: 0, flag: 64});
    }

    function transferOwnership(
        address addrNewOwner,
        address walletNewOwnerFrom,
        address walletNewOwnerTo
    ) public override checkOwnerCanEdit {
        tvm.rawReserve(address(this).balance - msg.value, 2);
        destructIndexOwner();
        _addrOwner = addrNewOwner;
        _walletOwnerFrom = walletNewOwnerFrom;
        _walletOwnerTo = walletNewOwnerTo;
        deployIndexOwner();
        msg.sender.transfer({value: 0, flag: 128});
    }

    function changePrice(uint128 newPrice) public override checkOwnerCanEdit {
        tvm.rawReserve(address(this).balance - msg.value, 2);
        destructIndexPairPrice();
        _price = newPrice;
        deployIndexPairPrice();
        msg.sender.transfer({value: 0, flag: 128});
    }

    function cancelOrder() public override checkOwnerCanCancel {
        _status = Constants.STATUS_REMOVE;
        ILimitOrderRoot(_addrRoot).cancelOrder{value: 0, flag: 64}(
            _id,
            _amount,
            _walletOwnerRoot,
            _walletOwnerFrom
        );
    }

    function cancelOrderCallback() public override {
        require(msg.sender == _addrRouter);
        require(_status == Constants.STATUS_REMOVE);

        destructOrder();
    }

    function destructOrder() private {
        destructIndexOwner();
        destructIndexPair();
        destructIndexPairPrice();

        selfdestruct(_addrOwner);
    }

    function getInfo() public view override returns (
        address addrRoot,
        address addrRouter,
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint128 price,
        uint128 amount,
        address walletOwnerRoot,
        address walletOwnerFrom,
        address walletOwnerTo,
        uint8 status
    ) {
        addrRoot = _addrRoot;
        addrRouter = _addrRouter;
        addrOwner = _addrOwner;
        addrPair = _addrPair;
        directionPair = _directionPair;
        price = _price;
        amount = _amount;
        walletOwnerRoot = _walletOwnerRoot;
        walletOwnerFrom = _walletOwnerFrom;
        walletOwnerTo = _walletOwnerTo;
        status = _status;
    }
}
