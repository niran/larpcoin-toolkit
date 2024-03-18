larpcoin-toolkit
================

*Do you have what it takes to be a gamemaster?*

A larpcoin is a memecoin with a game you can play. To join the game, mint your game piece NFT. To keep playing, mint a new game piece NFT when your current one expires. The larpcoin is the only currency accepted for game piece NFTs, so if you're going to keep playing, you can hold larpcoins for the future.

Since memecoins themselves are already like a game, that means there are two ways you can play a larpcoin: play it like a memecoin that everyone already knows how to play, or go deeper and play the game within the game. 

`larpcoin-toolkit` contains everything you need to start your own larpcoin. Time is of the essence, gamemaster. You must hurry up and start your game!

## Objectives

The core objective of any larpcoin is to get as many people to play as possible. But beware, gamemaster: a larpcoin with growth as its only objective will never be fun enough to grow! The gamemaster's job is to start a game worth growing, and to make sure the players who join are well-equipped to make the game their own. When your work is done, the hope is that your players get as much joy from being promoted to gamemaster as you get from being promoted to player. 

Remember: great games benefit their players. The best games benefit the world around the game.

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

A typical larpcoin gamemaster mints the entire fixed supply to an account. From there, they put half in a liquidity pool and half in a slowlock. The larpcoin players will control the coins in the slowlock. The gamemaster keeps nothing, and never makes the first purchases from the liquidity pool.

## The Slowlock

The slowlock is like a timelock, but it releases larpcoins slowly over time. The gamemaster chooses a half-life time period for the slowlock, and every time that period passes, half of the remaining larpcoins will have been released. Larpcoins are continually released every second.

The half-life determines the effective larpcoin inflation rate at each level of supply, and strongly affects the time at which those levels will be reached. These are the relevant conditions when future players are deciding whether to hold larpcoins.

The ideal configuration for a slowlock is not yet understood, but here are some easy options:

* **Six months**: If your larpcoin hasn't taken off in six months, it's probably dead already.
* **Four years**: Bitcoin's half life is four years. If it's good enough for Bitcoin, maybe it's good enough for your larpcoin?

## Minting

The gamemaster sets an initial USD or ETH denominated price for the game piece NFT and a time period for expiration. Users pay with the currency they have. Behind the scenes, that currency is automatically swapped for larpcoins. The larpcoins are deposited in the slowlock, where they will be slowly released over time for the players to control together.

Unlike typical NFTs, the game piece NFTs at the core of a larpcoin are non-transferable and time-limited. However, players are encouraged to create more traditional NFTs that can also be minted using the larpcoin.

## Player Control

The gamemaster chooses how players will control the slowlock. The simplest options are:

* **House of Players**: Active players make decisions. Each game piece NFT gives them a vote until it expires. One person, one vote. By default, the House of Players can spend the larpcoins released from the slowlock.
* **House of Future Players**: Decisions are made by players who hold larpcoins to use in the future. One larpcoin, one vote. (Future players should be active players, too!) By default, the House of Future Players can modify the slowlock, modify the game piece NFT, and generally everything except spending larpcoins.

You should rename the houses to fit with the lore of your larpcoin!

## Tools

* [**Base**](https://www.base.org/): Larpcoins play well on Base because the fees are super low, it's easy to onboard new players, and it has access to [Coinbase Onchain Verifications](https://github.com/coinbase/verifications), which will make it easier for you to enforce one player, one vote.
* [**Tally**](https://www.tally.xyz/): Tally is the tool larpcoin players use to make decisions together.
* [**Governor**](https://docs.tally.xyz/knowledge-base/tally/governor-framework): Larpcoins are built with Governor contracts, which makes them compatible with Tally.
* [**Uniswap**](https://uniswap.org/): Uniswap v3's [single-sided liquidity](https://support.uniswap.org/hc/en-us/articles/20902968738317-What-is-single-sided-liquidity) allows the larpcoin to provide its own initial liquidity without any ETH.

## FAQ

* **Do larpcoins have a fixed supply?** Yes. The entire supply of a larpcoin is created on day one. The larpcoins spent by the House of Players aren't *new* tokens, they're tokens that have been freshly released from the slowlock.
* **Since players are spending USD and ETH to mint their game piece NFTs, does the House of Players receive USD and ETH to spend?** No. The House of Players only receives larpcoins from the slowlock. USD and ETH from minting is always automatically swapped and deposited back in the slowlock.
* **Does "one person, one vote" actually work onchain?** Not really! Someone can create a whole bunch of accounts, mint a bunch of game piece NFTs, and gain control of the House of Players. But it's not worth worrying about this until your players have proved that your larpcoin is worth playing. Once it is, there are a few ways you can make it more resilient:
    * Require [Coinbase Onchain Verifications](https://github.com/coinbase/verifications) to vote in the House of Players.
    * Transition from automatic membership rolls to manual ones that are updated periodically by the House of Players.
    * Spend larpcoins as quickly as possible in the House of Players. The fewer that accumulate, the less lucrative it is to attack.
    * Reconstitute the House of Players in a more resilient form. The House of Future Players has the authority to set the recipient of the slowlock to a new address. They can do this to respond to an attack, or as part of a planned transition in cooperation with the existing House of Players.
* **Does proposal-driven direct democracy actually work?** Probably not, but it's a great way to get started! Once a larpcoin has traction, it might be a good idea for players to transition to some form of representative democracy. If you go down this path, you probably want to avoid modeling representation on government or corporate models. Copy nonpartisan student governments instead—they've been larping for years!

## TODO

- [x] Token distribution script
- [x] Basic game piece NFT contract editable by owner
- [x] Deploy Governor contracts for both houses
- [ ] Update the game piece's ERC721Votes logic to count one vote per address, expire votes and lock voting NFTs
- [ ] Uniswap single-sided inital liquidity
- [ ] Goalposts contract for swapping incoming tokens for the larpcoin and depositing in recipient
- [ ] Slowlock contract as Goalposts recipient
- [ ] Basic next.js larpcoin landing page
- [ ] Mint from landing page
- [ ] Mint from Farcaster frame
- [ ] Buy larpcoin from landing page
- [ ] Buy larpcoin from Farcaster frame
- [ ] Admin: UI to accept larpcoins from goalposts
- [ ] PvP: Specify which faction's goalposts to credit when minting
- [ ] PvP: Sorting Hat contract for auto-assigning factions
- [ ] Separate examples for PvP and PvE
- [ ] Coinbase Onchain Verifications integration
