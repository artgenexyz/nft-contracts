import fs from 'fs';
import { generateMnemonic } from 'bip39';

// generate mnemonic 24 words

const mnemonic = generateMnemonic();

console.log(mnemonic);
