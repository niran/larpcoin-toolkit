import Image from "next/image";
import GamePieceMintButton from "./GamePieceMintButton";


export default function GamePieceCard() {
  return (
    <div className="card shrink-0 w-full max-w-sm shadow-2xl bg-base-100">
      <form className="card-body flex-col items-center">
        <Image src="/pickaxe.png" alt="Pickaxe" width="250" height="250" />
        <GamePieceMintButton />
        <div className="text-green-500">250,000 $CRAFT</div>
      </form>
    </div>
  );
}
