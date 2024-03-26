import { useModal } from 'connectkit';
import { useCallback, useEffect, useState } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { useAccount, useBlockNumber, useReadContracts, useWaitForTransactionReceipt, useWriteContract } from 'wagmi';

import config from "../config";
import LarpcoinMetadata from "../contracts/Larpcoin.json";
import GamePieceMetadata from "../contracts/GamePiece.json";
import { hexToBigInt, isAddressEqual } from 'viem';


export default function DelegateButton({ governor }: { governor: "Larpcoin" | "GamePiece"}) {
  const queryClient = useQueryClient();
  const { data: blockNumber } = useBlockNumber({ watch: true });
  const account = useAccount();
  const delegateContractAddress = (governor === "Larpcoin" ? config.larpcoinAddress : config.gamePieceAddress) as `0x${string}`;

  // Query the user's allowance for the GamePiece contract.
  const larpcoinBalanceRequest = {
    address: config.larpcoinAddress as `0x${string}`,
    abi: LarpcoinMetadata.abi,
    functionName: "balanceOf",
    args: [account.address],
  };
  const gamePieceBalanceRequest = {
    address: config.gamePieceAddress as `0x${string}`,
    abi: GamePieceMetadata.abi,
    functionName: "balanceOf",
    args: [account.address],
  };
  const result = useReadContracts({
    contracts: [
      // Vote balance
      governor === "Larpcoin" ? larpcoinBalanceRequest : gamePieceBalanceRequest,
      // Current delegate
      {
        address: delegateContractAddress as `0x${string}`,
        abi: LarpcoinMetadata.abi,
        functionName: "delegates",
        args: [account.address],
      },
    ],
  });

  // Fetch data every polling interval.
  useEffect(() => { 
    queryClient.invalidateQueries({ queryKey: result.queryKey }); 
  }, [blockNumber, queryClient, result.queryKey]);

  const [isDelegating, setIsDelegating] = useState(false);
  const { writeContract, data: hash } = useWriteContract();
  const delegateResult = useWaitForTransactionReceipt({
    hash: hash,
  });

  useEffect(() => {
    if (isDelegating && delegateResult.status !== "pending") {
      setIsDelegating(false);
    }
  }, [isDelegating, delegateResult]);

  let balance, delegate;
  if (result.data) {
    balance = result.data[0].result as bigint;
    delegate = result.data[1].result as `0x${string}`;
  }

  if (balance === undefined || balance === BigInt(0) || delegate === undefined) {
    return '';
  }

  const sendDelegate = () => {
    writeContract({
      address: delegateContractAddress,
      abi: LarpcoinMetadata.abi,
      functionName: "delegate",
      args: [account.address],
    }, {
      onError: () => setIsDelegating(false),
    });
  }

  console.log(delegate);
  if (hexToBigInt(delegate) === BigInt(0)) {
    return (
      <div className="form-control mt-6">
        <button className="btn btn-primary" onClick={sendDelegate}>
          Register to Vote
        </button>
      </div>
    );
  }

  return (
    <div className="text-green-500">
      You are registered to vote.
    </div>
  );
}
