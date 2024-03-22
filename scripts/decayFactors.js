const Decimal = require("decimal.js");
Decimal.set({ toExpPos: 40, precision: 40 });


function main() {
  if (process.argv.length !== 3) {
    console.error('Provide the half life of your slowlock in days.');
    process.exit(1);
  }

  const halfLifeDays = parseInt(process.argv[2]);
  const halfLifeSeconds = halfLifeDays * 24 * 60 * 60;
  const Q96 = Decimal(2).pow(96);
  const numDecayFactors = 32;

  for (let i = 0; i < numDecayFactors; i++) {
    const elapsedTime = Decimal(2).pow(i);
    const decayFactor = Decimal(2).pow(elapsedTime.negated().div(halfLifeSeconds));
    const decayFactorX96 = decayFactor.times(Q96).floor();
    console.log(`decayFactorsX96[${i}] = ${decayFactorX96};`);
  }

}

main();
