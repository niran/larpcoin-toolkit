function main() {
  if (process.argv.length !== 4) {
    console.error('Provide the quantities of token0 and token1 that have equal value.');
    process.exit(1);
  }

  const token0 = parseInt(process.argv[2]);
  const token1 = parseInt(process.argv[3]);

  // https://blog.uniswap.org/uniswap-v3-math-primer
  const price = token1 / token0;
  const sqrtPrice = Math.sqrt(price);
  const sqrtPriceX96 = BigInt(sqrtPrice * 2**96);

  console.log(sqrtPriceX96);
}

main();
