import { useEffect } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { formatUnits } from 'viem';
import { useReadContracts } from 'wagmi';

import config from "../config";
import LarpcoinMetadata from "../contracts/Larpcoin.json";
import SlowlockMetadata from "../contracts/Slowlock.json";

function formatNumberByThousands(num: number) {
  const magnitudes = ['', 'k', 'M', 'B'];
  for (let i = 0; i < magnitudes.length; i++) {
    if (num < 1000) {
      return num.toPrecision(3) + magnitudes[i];
    }
    num /= 1000;
  }

  return num.toPrecision(3) + 'T';
}

export default function SlowlockStreamRate() {
  const queryClient = useQueryClient();
  const inOneMonth = Math.floor(Date.now() / 1000) + 30 * 86400; 

  // Query the user's allowance for the GamePiece contract.
  const result = useReadContracts({
    contracts: [{
      address: config.slowlockAddress as `0x${string}`,
      abi: SlowlockMetadata.abi,
      functionName: "decayedBalanceAt",
      args: [inOneMonth],
    }, {
      address: config.larpcoinAddress as `0x${string}`,
      abi: LarpcoinMetadata.abi,
      functionName: "decimals",
    }]
  });

  if (result.data) {
    const decayValues = result.data[0].result as bigint[];
    const targetBalance = decayValues[0];
    const currentBalance = decayValues[1];
    const diff = formatUnits(currentBalance - targetBalance, Number(result.data[1].result));
    const monthlyRate = formatNumberByThousands(Number(diff));
    return (
      <span>{monthlyRate}</span>
    );
  }

  return (
    <span>...</span>
  );
}
