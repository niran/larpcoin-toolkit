Tests
=====

```
forge test --fork-url https://ethereum-sepolia-rpc.publicnode.com -vv
```

Deploying
=========

Get an Etherscan API key if you don't have one.

```
export ETHERSCAN_API_KEY=...
```

Edit `--rpc-url` to match the chain you're deploying on.
```
forge script script/DeployLarpcoinGameFactory.sol --rpc-url https://ethereum-sepolia-rpc.publicnode.com -i 1 

# Verify the output of the script, then broadcast the transactions.
forge script script/DeployLarpcoinGameFactory.sol --rpc-url https://ethereum-sepolia-rpc.publicnode.com -i 1 --broadcast --verify
```

Update the LarpcoinGameFactory address in `scripts/LaunchLarpcoin$CHAIN.sol`.

To launch a larpcoin instance, edit the arguments as desired in `scripts/LaunchLarpcoin$CHAIN.sol`, then run the script with `--rpc-url` pointing at the desired chain.

```
forge script script/LaunchLarpcoinSepolia.sol --rpc-url https://ethereum-sepolia-rpc.publicnode.com -i 1 

# Verify the output of the script, then broadcast the transactions.
forge script script/LaunchLarpcoinSepolia.sol --rpc-url https://ethereum-sepolia-rpc.publicnode.com -i 1 --broadcast --verify
```

Deploying on Base
=================

Basescan uses separate accounts and servers from Etherscan. You'll need to get a separate API key.


```
forge script script/DeployPieceCollectorFactories.sol --rpc-url https://mainnet
.base.org/ -i 1 --broadcast --verify
```
