pragma ton-solidity >= 0.43.0;

interface IIndex {
    function getInfo() external view returns (
        address addrRoot,
        address addrOwner,
        address addrOrder,
        uint128 amount
    );
}
