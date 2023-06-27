import zlib from "zlib";
import fs from "fs";
import { spawn } from "child_process";

const filePath = process.argv[2];

const shouldCompress = process.argv[3] === "--compress";

// Read the HTML file
const fileContents = fs.readFileSync(filePath, "utf8");

// TODO: THIS DOESNT WORK
// Use:
// gzip -c ./scripts/r1b2.js | xxd -p | tr -d '\n' > ./scripts/r1b2.js.gz

console.log("Use this command to compress the file instead:");
console.log(`\tgzip -c ${filePath} | xxd -p | tr -d '\\n' | pbcopy`);
console.log(`\tgzip -c ${filePath} | xxd -p | tr -d '\\n' > ${filePath}.gz`);

// spawn("gzip", ["-c", filePath]).stdout.pipe(process.stdout);

process.exit(0);

// Compress the HTML using gzip
const compressed = zlib.deflateSync(fileContents);

const format = process.argv[4] == '--hex' ? 'hex' : 'base64';

// Encode the compressed HTML as base64
const base64Encoded = shouldCompress
  ? compressed.toString(format)
  : Buffer.from(fileContents).toString(format);

// Output the base64-encoded, gunzipped HTML
console.log(base64Encoded);
