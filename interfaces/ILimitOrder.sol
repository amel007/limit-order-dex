pragma ton-solidity >= 0.43.0;

interface ILimitOrder {
    function getInfo() external view returns (
        address addrRoot,
        address addrOwner,
        address addrPair,
        uint64 price,
        uint128 amount
    );
}
