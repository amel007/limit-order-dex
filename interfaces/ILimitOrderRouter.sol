pragma ton-solidity >= 0.43.0;

interface ILimitOrderRouter {
  function applyOrder(
    bool result,
    uint idCallback,
    uint128 amount,
    address walletOwnerRoot,
    address walletOwnerTo
  ) external;
  function deployEmptyWalletFor(address root) external;
  function cancelOrder(
    address addrData,
    uint128 amount,
    address walletOwnerRoot,
    address walletOwnerFrom
  ) external;
}
