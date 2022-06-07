// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";
import "solmate/auth/Owned.sol";
import "solmate/utils/SafeTransferLib.sol";

error BookSingleChain__InvalidToken(address token);
error BookSingleChain__FeePctTooHigh(uint256 fee);
error BookSingleChain__SameToken();
error BookSingleChain__NewFeePctTooHigh();
error BookSingleChain__ZeroAmount();
// the recipient of a transfer was the 0 address
error BookSingleChain__SentToBlackHole();

/**
 * @title BookSingleChain
 * @notice A basic RFQ book implementation, where users request trades and off-chain relayers fill them.
 * To ensure relayers fill trades at "fair" price, there is a block range in which trades can be disputed and voided.
 * If a trade is not disputed within the dispute period, the relayer can call `refund` to obtain the other side of the trade it filled.
 * @notice This implementation gives immense power to the owner of the contract, and only allows one relayer / disputer. This is not intended for production use, but rather for a small scale test.
 */
contract BookSingleChain is Owned {
    using SafeTransferLib for ERC20;

    // Number of trades done so far. Used to generate trade ids.
    uint128 public numberOfTrades = 0;
    // The amount of blocks in which a trade can be disputed.
    uint256 public safeBlockThreshold;
    // The maximum % off the optimal quote allowed. 1e18 is 100%.
    uint128 public maxFeePct;
    // A mapping with the tokens that are supported by this contract.
    mapping(address => bool) public whitelistedTokens;
    // A mapping from a trade id to a boolean indicating wether the trade has been filled.
    mapping(bytes32 => bool) public isFilled;
    // A mapping from a trade id to a boolean indicating who filled the trade.
    mapping(bytes32 => uint256) public filledAtBlock;
    // A mapping from a trade id to the relayer filling it.
    mapping(bytes32 => address) public filledBy;

    /****************************************
     *                EVENTS                *
     ****************************************/

    event SafeBlockThresholdChanged(uint256 newSafeBlockThreshold);
    event MaxFeePctChanged(uint128 newMaxFeePct);
    event TokenWhitelisted(address indexed token, bool whitelisted);
    event TradeRequested(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amount,
        uint256 feePct,
        address to,
        uint256 indexed tradeIndex
    );

    /**
     * @notice Constructs the order book.
     * @param _safeBlockThreshold The number of blocks in which a trade can be disputed.
     */
    constructor(uint256 _safeBlockThreshold) Owned(msg.sender) {
        safeBlockThreshold = _safeBlockThreshold;
        emit SafeBlockThresholdChanged(safeBlockThreshold);
        maxFeePct = 0.25 * 1e18;
        emit MaxFeePctChanged(maxFeePct);
    }

    /**************************************
     *          ADMIN FUNCTIONS           *
     **************************************/

    /**
     * @notice Changes the safe block threshold.
     * @param newSafeBlockThreshold The new safe block threshold.
     */
    function setSafeBlockThreshold(uint256 newSafeBlockThreshold)
        public
        onlyOwner
    {
        safeBlockThreshold = newSafeBlockThreshold;
        emit SafeBlockThresholdChanged(safeBlockThreshold);
    }

    /**
     * @notice Adds a token to the whitelist.
     * @param token The token to add to the whitelist.
     * @param whitelisted If `true` whitelists the token, if `false` it removes it.
     */
    function whitelistToken(address token, bool whitelisted) public onlyOwner {
        whitelistedTokens[token] = whitelisted;
        emit TokenWhitelisted(token, whitelisted);
    }

    /**
     * @notice Changes the maximum fee percentage.
     * @param newMaxFeePct The new maximum fee percentage.
     */
    function setMaxFeePct(uint128 newMaxFeePct) public onlyOwner {
        if (newMaxFeePct >= 1e18) {
            revert BookSingleChain__NewFeePctTooHigh();
        }
        maxFeePct = newMaxFeePct;
        emit MaxFeePctChanged(maxFeePct);
    }

    /**************************************
     *         TRADING FUNCTIONS        *
     **************************************/

    /**
     * @notice Requests to trade `amount` of `tokenIn` for `tokenOut` with `feePct` fee off the optimal quote at execution time. Users deposit `tokenIn` to the contract.
     * @param tokenIn The token to be sold.
     * @param tokenOut The token to be bought.
     * @param amount The amount of `tokenIn` to be sold.
     * @param feePct The fee percentage. This is to be interpreted as a "distance" from the optimal execution price.
     * @param to The address to receive the tokens bought.
     */
    function requestTrade(
        address tokenIn,
        address tokenOut,
        uint256 amount,
        uint256 feePct,
        address to
    ) external {
        if (!whitelistedTokens[tokenIn]) {
            revert BookSingleChain__InvalidToken(tokenIn);
        }
        if (!whitelistedTokens[tokenOut]) {
            revert BookSingleChain__InvalidToken(tokenOut);
        }
        if (tokenIn == tokenOut) {
            revert BookSingleChain__SameToken();
        }
        if (feePct > maxFeePct) {
            revert BookSingleChain__FeePctTooHigh(feePct);
        }
        if (amount == 0) {
            revert BookSingleChain__ZeroAmount();
        }
        if (to == address(0)) {
            revert BookSingleChain__SentToBlackHole();
        }

        ERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amount);

        emit TradeRequested(
            tokenIn,
            tokenOut,
            amount,
            feePct,
            to,
            numberOfTrades
        );

        numberOfTrades++;
    }
}
