pragma ton-solidity >= 0.43.0;

library Constants {
    uint128 constant MIN_FOR_DEPLOY = 1.2 ton;
    uint128 constant FOR_DEPLOY_ORDER = 1.3 ton;
    uint128 constant SEND_MSG = 0.2 ton;
    uint128 constant FOR_ROUTER = 0.3 ton;
    uint128 constant FOR_DEPLOY_INDEX = 0.3 ton;
    uint128 constant FOR_EDIT_ORDER = 0.5 ton;
    uint128 constant FOR_CANCEL_ORDER = 0.7 ton;
    uint128 constant FOR_RETURN_TOKEN = 0.5 ton;
    uint128 constant TO_WALLET_BALANCE = 0.5 ton;
    uint128 constant FOR_WALLET_DEPLOY = 0.6 ton;

    uint8 constant STATUS_ACTIVE    = 1;
    uint8 constant STATUS_REMOVE    = 2;
    uint8 constant STATUS_EXCHANGE  = 3;
}
