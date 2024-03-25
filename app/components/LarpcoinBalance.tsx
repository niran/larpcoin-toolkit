import { useEffect } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { formatUnits } from 'viem';
import { useAccount, useBlockNumber, useReadContracts } from 'wagmi';

import config from "../config";
import LarpcoinMetadata from "../contracts/Larpcoin.json";


export default function LarpcoinBalance() {
  const queryClient = useQueryClient();
  const { data: blockNumber } = useBlockNumber({ watch: true });
  const account = useAccount();

  // Query the user's allowance for the GamePiece contract.
  const result = useReadContracts({
    contracts: [{
      address: config.larpcoinAddress as `0x${string}`,
      abi: LarpcoinMetadata.abi,
      functionName: "balanceOf",
      args: [account.address],
    }, {
      address: config.larpcoinAddress as `0x${string}`,
      abi: LarpcoinMetadata.abi,
      functionName: "decimals",
    }]
  });

  // Fetch data every polling interval.
  useEffect(() => { 
    queryClient.invalidateQueries({ queryKey: result.queryKey }); 
  }, [blockNumber, queryClient, result.queryKey]);

  const resultValues = result.data ? result.data.map(x => x.result as bigint) : [undefined, undefined];
  let balance;
  if (resultValues.every(x => x !== undefined)) {
    balance = Number(formatUnits(resultValues[0] as bigint, Number(resultValues[1]))).toLocaleString();
  }

  return (
    <div className="text-green-500">
      {balance !== undefined && `You have ${balance} ${config.larpcoinName}`}
    </div>
);
}
