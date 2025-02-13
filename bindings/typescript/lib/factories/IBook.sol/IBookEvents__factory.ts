/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IBookEvents,
  IBookEventsInterface,
} from "../../IBook.sol/IBookEvents";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint256",
        name: "feePct",
        type: "uint256",
      },
    ],
    name: "FeePctSet",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "uint256",
        name: "tradeIndex",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "bytes32",
        name: "tradeId",
        type: "bytes32",
      },
      {
        indexed: true,
        internalType: "address",
        name: "trader",
        type: "address",
      },
    ],
    name: "TradeCancelled",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "relayer",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tradeIndex",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint128",
        name: "amountOut",
        type: "uint128",
      },
      {
        indexed: true,
        internalType: "address",
        name: "trader",
        type: "address",
      },
    ],
    name: "TradeFilled",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "contract IERC20[]",
        name: "tokens",
        type: "address[]",
      },
      {
        indexed: false,
        internalType: "uint128[]",
        name: "amounts",
        type: "uint128[]",
      },
      {
        indexed: false,
        internalType: "address",
        name: "recipient",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tradeIndex",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "trader",
        type: "address",
      },
      {
        indexed: false,
        internalType: "bool",
        name: "unwrapOutput",
        type: "bool",
      },
      {
        indexed: false,
        internalType: "bool",
        name: "wrapInput",
        type: "bool",
      },
    ],
    name: "TradeRequested",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "relayer",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "tradeIndex",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "filledAtBlock",
        type: "uint256",
      },
      {
        indexed: true,
        internalType: "address",
        name: "trader",
        type: "address",
      },
    ],
    name: "TradeSettled",
    type: "event",
  },
] as const;

export class IBookEvents__factory {
  static readonly abi = _abi;
  static createInterface(): IBookEventsInterface {
    return new utils.Interface(_abi) as IBookEventsInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): IBookEvents {
    return new Contract(address, _abi, signerOrProvider) as IBookEvents;
  }
}
