import { useEffect } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import Image from "next/image";
import { formatUnits } from 'viem';
import { useAccount, useBlockNumber, useReadContracts } from 'wagmi';

import config from "../config";
import LarpcoinMetadata from "../contracts/Larpcoin.json";
import GamePieceMetadata from "../contracts/GamePiece.json";
import GamePieceMintButton from "./GamePieceMintButton";


export default function GamePieceCard() {
  const queryClient = useQueryClient();
  const { data: blockNumber } = useBlockNumber({ watch: true });
  const account = useAccount();

  // Query the user's allowance for the GamePiece contract.
  const result = useReadContracts({
    contracts: [{
      address: config.gamePieceAddress as `0x${string}`,
      abi: GamePieceMetadata.abi,
      functionName: "cost",
    }, {
      address: config.larpcoinAddress as `0x${string}`,
      abi: LarpcoinMetadata.abi,
      functionName: "decimals",
    }, {
      address: config.gamePieceAddress as `0x${string}`,
      abi: GamePieceMetadata.abi,
      functionName: "playerRecords",
      args: [account.address],
    }, {
      address: config.gamePieceAddress as `0x${string}`,
      abi: GamePieceMetadata.abi,
      functionName: "balanceOf",
      args: [account.address],
    }, {
      address: config.gamePieceAddress as `0x${string}`,
      abi: GamePieceMetadata.abi,
      functionName: "roundLength",
    }]
  });

  // Fetch data every polling interval.
  useEffect(() => { 
    queryClient.invalidateQueries({ queryKey: result.queryKey }); 
  }, [blockNumber, queryClient, result.queryKey]);

  const costValues = result.data ? result.data.slice(0, 2).map(x => x.result as bigint) : [undefined, undefined];
  let costData;
  if (costValues.every(x => x !== undefined)) {
    costData = {
      cost: costValues[0] as bigint,
      decimals: costValues[1] as bigint,
    };
  }

  const playerRecord = result.data ? result.data[2].result as [bigint, bigint, bigint, boolean] : undefined;
  const balance = result.data ? result.data[3].result as bigint: undefined;
  const roundLength = result.data ? result.data[4].result as bigint : undefined;
  let activeUntil;
  if (playerRecord !== undefined && balance !== undefined && roundLength !== undefined && balance > 0) {
    const usableBalance = balance - playerRecord[2];
    activeUntil = new Date(Number(playerRecord[1] + usableBalance * roundLength) * 1000);
  }

  let cost;
  if (costData !== undefined) {
    cost = Number(formatUnits(costData.cost, Number(costData.decimals))).toLocaleString();
  }

  return (
    <div className="card shrink-0 w-full max-w-sm shadow-2xl bg-base-100">
      <form className="card-body flex-col items-center">
        <Image src="/pickaxe.png" alt="Pickaxe" width="250" height="250" />
        <GamePieceMintButton />
        <div className="text-green-500">
          {cost !== undefined && `${cost} ${config.larpcoinName}`}
        </div>
        <div className="text-green-500">
          {balance !== undefined && balance > 0 && `You have ${balance} ${config.gamePieceName}${balance > 1 ? "s" : ""}. `}
          {balance !== undefined && Number(balance) === 0 && `You have no ${config.gamePieceName}s. `}
          {activeUntil !== undefined && `You can play until ${activeUntil.toDateString()}.`}
        </div>
      </form>
    </div>
  );
}
