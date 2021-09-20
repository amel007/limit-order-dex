pragma ton-solidity >= 0.43.0;

interface ILimitOrderRoot {
    function createOrder(
        address addrOwner,
        address addrPair,
        uint8 directionPair,
        uint64 price,
        uint128 amount,
        address walletOwner
    ) external;
}
