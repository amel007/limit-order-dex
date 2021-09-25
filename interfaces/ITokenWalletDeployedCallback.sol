pragma ton-solidity >= 0.45.0;

interface ITokenWalletDeployedCallback {
    function notifyWalletDeployed(address root) external;
}
