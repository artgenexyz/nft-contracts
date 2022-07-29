import minimist from 'minimist';
import { sfc32, xmur3 } from './lib';
const argv = minimist(process.argv.slice(2));

if (!argv.seed) {
    console.log(`Usage: node predictable-random --seed "Lorem ipsum" --run`)
    process.exit(-1);
}

const { seed } = argv;


const hash = xmur3(seed);

console.log('seed:', seed, ', hash:', hash());

// Pad seed with Phi, Pi and E.
// https://en.wikipedia.org/wiki/Nothing-up-my-sleeve_number
export const rand = sfc32(0x9E3779B9, 0x243F6A88, 0xB7E15162, hash());

// if argv has --run, run and output rand()

if (argv.run) {
    const n = argv.n || 1

    const str = Array(n).fill(null).map(i => rand().toString(16).slice(2)).join('')

    console.log(str)
}

