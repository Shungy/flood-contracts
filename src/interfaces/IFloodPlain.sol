// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IFloodPlain {
    error InsufficientAmountPulled();

    event OrderFulfilled(
        bytes32 indexed orderHash,
        address indexed offerer,
        address indexed fulfiller
    );

    event OrderEtched(
        uint256 indexed orderId,
        bytes32 indexed orderHash,
        Order order,
        bytes signature
    );

    struct Order {
        address offerer;
        address zone;
        OfferItem[] offer;
        ConsiderationItem[] consideration;
        uint256 deadline;
        uint256 nonce;
    }

    struct OrderWithSignature {
        Order order;
        bytes signature;
    }

    struct OfferItem {
        address token;
        uint256 amount;
    }

    struct ConsiderationItem {
        bool isNative;
        address token;
        uint256 amount;
    }

    /**
     * @notice Fulfill an order with an arbitrary number of items for offer and consideration.
     *
     * @param order     The order to fulfill. Note that the offerer must first approve Permit2
     *                  contract to transfer any relevant tokens on their behalf.
     * @param signature The permit2 signature with the order as the witness.
     * @param fulfiller The address that will receive offer items, then source consideration items
     *                  for the offerer.
     * @param extraData Extra bytes passed to the Zone and Fulfiller.
     */
    function fulfillOrder(
        Order calldata order,
        bytes calldata signature,
        address fulfiller,
        bytes calldata extraData
    ) external;

    /**
     * @notice Fulfill an order with an arbitrary number of items for offer and consideration.
     *
     * @param orderId   The order to fulfill.
     * @param fulfiller The address that will receive offer items, then source consideration items
     *                  for the offerer.
     * @param extraData Extra bytes passed to the Zone and Fulfiller.
     */
    function fulfillEtchedOrder(
        uint256 orderId,
        address fulfiller,
        bytes calldata extraData
    ) external;

    /**
     * @notice Record an order on-chain to allow ease of use by other contracts.
     *
     * @param orderWithSignature The order and its signature to record.
     *
     * @return orderId Extra bytes passed to the Zone and Fulfiller.
     */
    function etchOrder(
        OrderWithSignature calldata orderWithSignature
    ) external returns (uint256 orderId);

    /**
     * @notice Retrieve the permit2 hash for a given order.
     *
     * @param order The components of the order.
     *
     * @return permitHash The permit2 hash as order as the witness.
     */
    function getPermitHash(Order calldata order) external view returns (bytes32 permitHash);

    /**
     * @notice Retrieve the order hash for a given order.
     *
     * @param order The components of the order.
     *
     * @return orderHash The order hash.
     */
    function getOrderHash(Order calldata order) external view returns (bytes32 orderHash);

    /**
     * @notice Check if the order can be fulfilled with the provided parameters. This does not
     *         check signature validity and token approvals.
     *
     * @param order     The components of the order.
     * @param fulfiller The address that will fulfill the order.
     * @param caller    The address that will call `fulfillOrder`.
     * @param extraData Extra bytes that will be passed to Zone and Fulfiller.
     *
     * @return isValid A boolean guaranteeing the order cannot be fulfilled with supplied
     *                 parameters if false.
     */
    function getOrderValidity(
        Order calldata order,
        address fulfiller,
        address caller,
        bytes calldata extraData
    ) external view returns (bool isValid);

    /**
     * @notice Check if the order deadline has passed or its nonce has been cancelled or used.
     *
     * @param order The components of the order.
     *
     * @return isValid A boolean guaranteeing the order cannot be fulfilled if false.
     */
    function getOrderStatus(Order calldata order) external view returns (bool isValid);

    /**
     * @notice Check if the nonce of a user is available.
     *
     * @param user  The address of the user to check the nonce of.
     * @param nonce The nonce of the user to check.
     *
     * @return isValid A boolean returning true if the nonce is not flipped.
     */
    function getNonceStatus(address user, uint256 nonce) external view returns (bool isValid);
}
