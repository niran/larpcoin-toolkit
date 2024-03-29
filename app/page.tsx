"use client";
import ConnectWalletButton from "./components/ConnectWalletButton";
import DelegateButton from "./components/DelegateButton";
import GamePieceCard from "./components/GamePieceCard";
import LarpcoinBalance from "./components/LarpcoinBalance";
import SlowlockStreamRate from "./components/SlowlockStreamRate";
import config from "./config";

export default function Home() {
  return (
    <div className="bg-base-200">
      <div className="navbar bg-base-100">
        <div className="navbar-start"></div>
        <div className="navbar-end">
          <ConnectWalletButton />
        </div>
      </div>

      <div className="container mx-auto bg-base-200">
        <div className="hero bg-base-200">
          <div className="hero-content flex-col lg:flex-row">
            <div className="text-center lg:text-left text-green-500 min-w-[300px]">
              <h1 className="text-5xl font-bold">$CRAFT</h1>
              <p className="py-6">The testnet memecoin for builders and friends</p>
            </div>
            <div className="card shrink-0 w-full max-w-sm shadow-2xl bg-base-100">
              <form className="card-body flex-col items-center">
                <div className="form-control mt-6">
                  <a target="_blank" href={`https://app.uniswap.org/swap?outputCurrency=${config.larpcoinAddress}&chain=${config.uniswapChain}`} className="btn btn-primary">
                    Swap for $CRAFT
                  </a>
                </div>
                <div className="text-green-500">
                  <a target="_blank" className="underline" href="https://sepolia.etherscan.io/token/0xaab56a449b0345ec064caccf161e06613437bc83">
                    $CRAFT is on Sepolia
                  </a>
                </div>
                <LarpcoinBalance />
              </form>
            </div>
          </div>
        </div>
        <div className="hero bg-base-200">
          <div className="hero-content flex-col lg:flex-row">
            <div className="text-center lg:text-left text-green-500 min-w-[300px]">
              <h1 className="text-5xl font-bold">Play With Us</h1>
              <p className="py-6">One Pickaxe lets you play for 30 days.</p>
            </div>
            <GamePieceCard />
          </div>
        </div>
        <div className="text-green-500">
          <h2 className="text-3xl font-bold">Ways To Play</h2>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          <div className="card shadow-2xl">
              <div className="card-body">
                <h2 className="card-title">Earn $CRAFT</h2>
                <p>The best crafters are great builders. Build great stuff to earn $CRAFT awards from the current players.</p>
              </div>
            </div>
            <div className="card shadow-2xl">
              <div className="card-body">
                <h2 className="card-title">Give $CRAFT</h2>
                <p>
                  Find great builders and make sure they get the $CRAFT they need to play with us.
                  You can give out your own $CRAFT or vote in
                  the <a target="_blank" className="underline" href="https://www.tally.xyz/gov/crafters">House of Crafters</a> to
                  award $CRAFT from the stream. One player, one vote.
                  $CRAFT is currently streaming at <SlowlockStreamRate /> $CRAFT per month, and the stream slows exponentially as it runs out.
                </p>
                <DelegateButton governor="GamePiece" />
              </div>
            </div>
            <div className="card shadow-2xl">
              <div className="card-body">
                <h2 className="card-title">Configure the Game</h2>
                <p>
                  The <a className="underline" target="_blank" href="https://www.tally.xyz/gov/future-crafters">House of Future Crafters</a> controls
                  settings like the cost of each Pickaxe. One $CRAFT, one vote.
                </p>
                <DelegateButton governor="Larpcoin" />
              </div>
            </div>
            <div className="card shadow-2xl">
              <div className="card-body">
                <h2 className="card-title">$CRAFT on Farcaster</h2>
                <p>
                  Join the conversation in the <a className="underline" target="_blank" href="https://warpcast.com/~/channel/crafters">/crafters channel on Farcaster</a>.
                </p>
              </div>
            </div>
          </div>
          <div className="text-center italic my-4 underline">
            <p><a href="https://github.com/niran/larpcoin-toolkit">learn more about larpcoins</a></p>
          </div>
        </div>
      </div>
    </div>
  );
}
