import { useAccount, useBlockNumber, useReadContracts, useWriteContract } from 'wagmi';
import config from "../config";
import LarpcoinMetadata from "../contracts/Larpcoin.json";
import GamePieceMetadata from "../contracts/GamePiece.json";
import { useEffect, useState } from 'react';
import { useModal } from 'connectkit';
import { useQueryClient } from '@tanstack/react-query';


export default function GamePieceMintButton() {
  const queryClient = useQueryClient();
  const { data: blockNumber } = useBlockNumber({ watch: true });
  const account = useAccount();
  const { setOpen } = useModal();

  // Query the user's allowance for the GamePiece contract.
  const result = useReadContracts({
    contracts: [
      // Larpcoin balance
      {
        address: config.larpcoinAddress as `0x${string}`,
        abi: LarpcoinMetadata.abi,
        functionName: "balanceOf",
        args: [account.address],
      },
      // GamePiece allowance to spend larpcoins
      {
        address: config.larpcoinAddress as `0x${string}`,
        abi: LarpcoinMetadata.abi,
        functionName: "allowance",
        args: [account.address, config.gamePieceAddress],
      },
      // GamePiece cost
      {
        address: config.gamePieceAddress as `0x${string}`,
        abi: GamePieceMetadata.abi,
        functionName: "cost",
      }
    ],
  });

  // Fetch data every block.
  useEffect(() => { 
    queryClient.invalidateQueries({ queryKey: result.queryKey }); 
  }, [blockNumber, queryClient, result.queryKey]);

  const [balance, allowance, cost] = result.data ? result.data.map(x => x.result) as bigint[] : [undefined, undefined, undefined];
  const [mintState, setMintState] = useState<"viewing"|"approving"|"minting">("viewing");
  const { writeContract: writeContractApprove } = useWriteContract();
  const { writeContract: writeContractMint } = useWriteContract();

  const sendMint = () => {
    setMintState("minting");
    writeContractMint({
      address: config.gamePieceAddress as `0x${string}`,
      abi: GamePieceMetadata.abi,
      functionName: "mintAndPlay",
    }, {
      onSettled: () => setMintState("viewing"),
    });
  }
  
  const sendApprove = () => {
    setMintState("approving");
    writeContractApprove({
      address: config.larpcoinAddress as `0x${string}`,
      abi: LarpcoinMetadata.abi,
      functionName: "approve",
      args: [config.gamePieceAddress, cost],
    }, {
      onSuccess: sendMint,
      onError: () => setMintState("viewing"),
    });
  }
  
  async function mintGamePiece(e: React.FormEvent<HTMLButtonElement>) {
    e.preventDefault();
    if (cost === undefined || balance === undefined || allowance === undefined) {
      console.log("Initialization error: didn't fetch cost parameters. Showing ConnectKit modal");
      setOpen(true);
      return;
    }
    if (balance < cost) {
      // Not enough larpcoins to mint a game piece.
      alert(`You don't have enough ${config.larpcoinName} to mint a ${config.gamePieceName}.`);
      return;
    }

    if (allowance < cost) {
      sendApprove();
    } else {
      sendMint();
    }
  }

  return (
    <div className="form-control mt-6">
      <button className="btn btn-primary" onClick={mintGamePiece}>
        {mintState === "approving" && "Approving..."}
        {mintState === "minting" && "Minting..."}
        {mintState === "viewing" && `Mint a ${config.gamePieceName}`}
      </button>
    </div>
  );
}