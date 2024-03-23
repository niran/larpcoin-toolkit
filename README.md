larpcoin-toolkit
================

*Do you have what it takes to be a gamemaster?*

A larpcoin is a memecoin with a game you can play. To join the game, mint your game piece NFT to play for one round. To keep playing, mint a new game piece NFT each round. The larpcoin is the only currency accepted for game piece NFTs, so if you're going to keep playing, you can hold larpcoins for the future.

Since memecoins themselves are already like a game, that means there are two ways you can play a larpcoin: play it like a memecoin that everyone already knows how to play, or go deeper and play the game within the game. 

`larpcoin-toolkit` contains everything you need to start your own larpcoin. Time is of the essence, gamemaster. You must hurry up and start your game! But make sure you're prepared for the power these games will have on you...

## Objectives

The core objective of any larpcoin is to get as many people to play as possible. But beware, gamemaster: a larpcoin with growth as its only objective will never be fun enough to grow! The gamemaster's job is to start a game worth growing, and to make sure the players who join are well-equipped to make the game their own.

To start playing with a memecoin, you buy it. That works with a larpcoin too, but since the players control a stream of larpcoins, new players can also *play* their way into the game. The current players decide what actions they want new players to take, and they distribute larpcoins from their stream to reward good players. These reward choices shape the whole game! Remember: great games benefit their players. The best games benefit the world around the game.

The way the gamemaster starts the game is crucial. Your choices must inspire your players to play well. What will you call your game and what imagery will you use? When you buy your own larpcoins, who will you give them away to and why? When your work is done, the hope is that your players get as much joy from being promoted to gamemaster as you get from being promoted to player.

## Gameplay

There are two gameplay modes for larpcoins: player versus environment (PvE) and player versus player (PvP).

### PvE

In PvE mode, all larpcoin players are working together to achieve the objectives. They succeed together and fail together.

**Example Concepts**

* Dungeons and Dragons
* Super Mario Brothers
* The Legend of Zelda
* Final Fantasy

### PvP

In PvP mode, larpcoin players are separated into factions that compete against each other to achieve the objectives. Each faction has its own goalposts, and their score increases each time their faction's NFTs are minted.

All players succeed when any faction succeeds, but the winning faction gets the glory. That makes this mode especially useful for early experimentation when there aren't many people who know how to play larpcoins well. They can learn through friendly competition rather than just losing to external competitors.

For some larpcoins, it makes sense for players to choose their own faction. For others, a whimsical hat should assign each player to a faction.

**Example Concepts**

* Hogwarts (Houses)
* World of Warcraft (Races)
* Civilization (Civilizations)
* The Olympics (Nations)
* [Crypto: The Game](https://www.cryptothegame.com/) (Tribes, battle royale)

## Distribution

A typical memecoin creator mints the entire fixed supply to an account and puts the rest in a liquidity pool. (The creator usually keeps some of the initial supply, but that's lame.)

A typical larpcoin gamemaster mints the entire fixed supply to an account. From there, they put half in a liquidity pool and half in a slowlock. The larpcoin players will control the coins in the slowlock. The gamemaster keeps nothing, and and often gives away larpcoins from the first purchases from the liquidity pool.

## Streaming from the Slowlock

The slowlock is like a timelock, but it streams larpcoins slowly forever. The stream lasts forever because it keeps slowing down as it drains. The gamemaster chooses a half-life time period for the slowlock, and every time that period passes, half of the remaining larpcoins will have been streamed. Larpcoins are continually streamed every second.

The half-life determines the effective larpcoin inflation rate at each level of supply, and strongly affects the time at which those levels will be reached. These are the relevant conditions when future players are deciding whether to hold larpcoins.

The ideal configuration for a slowlock is not yet understood, but here are some easy options:

* **Four years**: Bitcoin's half life is four years. If it's good enough for Bitcoin, maybe it's good enough for your larpcoin?
* **One year**: In most memecoins, the 50% of the supply devoted to liquidity usually circulates very quickly with a small portion remaining in Uniswap. With a half life of one year, it'll take a year for the slowlock to dilute that by half (25% of the total supply). Maybe that's conservative enough.

## Minting

The gamemaster sets an initial larpcoin-denominated cost for the game piece NFT and the length of one round. One game piece expires at the end of each round for each player. Users swap for the larpcoins they need, then mint their game piece. The NFT contract deposits incoming larpcoins into the slowlock, where they will be slowly streamed over time for the players to control together.

Game piece NFTs can be transferred without any restrictions until the player registers to vote with their game piece. After that, one game piece per round will be locked in the player's account, while the remaining can still be transferred.

Game piece NFTs are open editions: the supply is limited by time. The current generation of game pieces can be locked to disable further minting, and players continue the game with a new game piece NFT contract. Once the new game piece is active, the old piece can become a scarce collectible with no transfer restrictions.

## Choosing the Initial Mint Cost

Since you're creating a larpcoin from thin air, the larpcoin cost of your game pieces can feel like an arbitrary number. **It's not arbitrary.** It determines how easy it is to play your game. You don't want it to be too easy or too hard, but it's better for the game to start too hard and adjust over time.

The difficulty is determined by the number of larpcoins streamed each round versus the number of larpcoins needed to mint game pieces each round. Let's walk through an example. We'll set the game piece rounds to last for 30 days and the slowlock to a half-life of four years. [The math](https://www.omnicalculator.com/chemistry/half-life) tells us that 1.42% of the slowlock's larpcoins will be released in the first 30 days. Our players have to compete to earn those larpcoins or trade for circulating larpcoins to keep playing! If there are 1,000,000,000 larpcoins, that means 500,000,000 started in the slowlock, so 500,000,000 x 1.42% = 7,100,000 larpcoins will be streamed in the first month.

If you set your game piece cost to 1,000,000 larpcoins, that's a really hard game! Only 7 people can play their way in each month, and the rest have to trade to get in. That's too hard. But if you estimate that 70 will want to start playing your game in the first month, a cost of 100,000 larpcoins is still pretty high, but more reasonable. Keep in mind that game pieces need to be minted each round, so the higher the cost, the more frequently your players will need to earn rewards from the stream (or trade for larpcoins from someone else). Does it make sense for your players to try to earn rewards every round? Every other round? Every tenth round? Set your game piece cost accordingly.

On the other end of the spectrum, a game piece cost of 100 larpcoins for a game that expects 70 players is way too low. In the first few months, you'd be streaming enough larpcoins for 71,000 people to play! If only 70 people show up, you'll end up giving them enough larpcoins in one month to play for over 80 years! It'd be like getting $200,000 every time you pass "GO" in Monopoly. Paying rent on Boardwalk would never be a problem, so the game wouldn't go anywhere.

Estimate the number of players you expect and how often it makes sense to earn rewards in your game, then choose an initial game piece cost that fits your game. Your players will adjust the cost from there.

## Player Control

Once the gamemaster starts the game, the players become the gamemaster and control the game together. Here's the simplest setup that should work for most games:

* **House of Players**: Active players make decisions. Each game piece NFT gives them a vote until it expires. One person, one vote. By default, the House of Players can spend the larpcoins streamed from the slowlock.
* **House of Future Players**: Decisions are made by players who hold larpcoins to use in the future. One larpcoin, one vote. (Future players should be active players, too!) By default, the House of Future Players can modify the slowlock, modify the game piece NFT, and generally everything except spending larpcoins.

You should rename the houses to fit with the lore of your larpcoin!

## Tools

* [**Base**](https://www.base.org/): Larpcoins play well on Base because the fees are super low, it's easy to onboard new players, and it has access to [Coinbase Onchain Verifications](https://github.com/coinbase/verifications), which will make it easier for you to enforce one player, one vote.
* [**Snapshot**](https://snapshot.org/): Snapshot is the polling tool players use to gauge sentiment on upcoming issues.
* [**Tally**](https://www.tally.xyz/): Tally is the tool larpcoin players use to make binding decisions together onchain.
* [**Governor**](https://docs.tally.xyz/knowledge-base/tally/governor-framework): Larpcoins are built with Governor contracts, which makes them compatible with Tally.
* [**Uniswap**](https://uniswap.org/): Uniswap v3's [single-sided liquidity](https://support.uniswap.org/hc/en-us/articles/20902968738317-What-is-single-sided-liquidity) allows the larpcoin to provide its own initial liquidity without any ETH.
* [**Party**](https://www.party.app/): If you use Party to launch your larpcoin, you can avoid some of the pitfalls of typical memecoins. The early participants often end up with a huge portion of the token supply, which makes the whole game very ruggable. If you "fair launch" your larpcoin by [splitting the early token supply with several people](https://twitter.com/john_c_palmer/status/1769179600502833569), it might be less ruggable.

## FAQ

* **Do larpcoins have a fixed supply?** Yes. The entire supply of a larpcoin is created on day one. The larpcoins spent by the House of Players aren't *new* tokens, they're tokens that have been freshly streamed from the slowlock.
* **Does "one person, one vote" actually work onchain?** Not really! Someone can create a whole bunch of accounts, mint a bunch of game piece NFTs, and gain control of the House of Players. But it's not worth worrying about this until your players have proved that your larpcoin is worth playing. Once it is, there are a few ways you can make it more resilient:
    * Require [Coinbase Onchain Verifications](https://github.com/coinbase/verifications) to vote in the House of Players.
    * Transition from automatic membership rolls to manual ones that are updated periodically by the House of Players.
    * Spend larpcoins as quickly as possible in the House of Players. The fewer that accumulate, the less lucrative it is to attack.
    * Reconstitute the House of Players in a more resilient form. The House of Future Players has the authority to set the recipient of the slowlock to a new address. They can do this to respond to an attack, or as part of a planned transition in cooperation with the existing House of Players.
* **Does proposal-driven direct democracy actually work?** Probably not, but it's a great way to get started! Once a larpcoin has traction, it might be a good idea for players to transition to some form of representative democracy. If you go down this path, you probably want to avoid modeling representation on government or corporate models. Copy nonpartisan student governments instead—they've been larping for years!
* **I already have a token. Can I turn it into a larpcoin?** I dunno, probably? Try deploying a GamePiece, GamePieceGovernor and an empty Slowlock, and get your community members to play! It's more fun when the House of Players has the ability to reward good players, so you might need to put more of your token supply in the slowlock.

## TODO

- [x] Token distribution script
- [x] Basic game piece NFT contract editable by owner
- [x] Deploy Governor contracts for both houses
- [x] Update the game piece's ERC721Votes logic to count one vote per address, expire votes and lock voting NFTs
- [x] Uniswap single-sided inital liquidity
- [x] Mint GamePiece with larpcoins
- [x] Slowlock contract to receive tokens from minting
- [ ] Burn liquidity position NFT
- [ ] Basic next.js larpcoin landing page
- [ ] Mint from landing page
- [ ] Buy larpcoin from landing page
- [ ] Register to vote from landing page
- [ ] Coinbase Onchain Verifications integration
- [ ] Mint from Farcaster frame
- [ ] Buy larpcoin from Farcaster frame

**Factions**

- [ ] Goalposts contract to accept incoming larpcoins, ETH or USDC, swaps for the larpcoin and deposits in slowlock
- [ ] FactionGamePiece contract that lets minters support a specific factionw with their mint 
- [ ] Admin: UI to accept larpcoins from goalposts
- [ ] PvP: Specify which faction's goalposts to credit when minting
- [ ] PvP: Sorting Hat contract for auto-assigning factions
- [ ] Separate examples for PvP and PvE
