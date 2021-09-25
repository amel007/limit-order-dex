pragma ton-solidity >= 0.43.0;

interface ILimitOrder {
    function applyOrder(uint128 receivedAmount, uint128 price, uint idCallback) external;
    function applyOrderCallback(bool result, uint128 amount, address originalGasTo) external;
    function transferOwnership(address addrNewOwner, address walletNewOwnerFrom, address walletNewOwnerTo) external;
    function changePrice(uint128 newPrice) external;
    function cancelOrder() external;
    function cancelOrderCallback() external;
    function getInfo() external view returns (
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
    );
}
