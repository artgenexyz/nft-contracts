import zlib from "zlib";
import fs from "fs";

const filePath = process.argv[2];

const shouldCompress = process.argv[3] === "--compress";

// Read the HTML file
const fileContents = fs.readFileSync(filePath, "utf8");

// Compress the HTML using gzip
const compressed = zlib.deflateSync(fileContents);

const format = process.argv[4] == '--hex' ? 'hex' : 'base64';

// Encode the compressed HTML as base64
const base64Encoded = shouldCompress
  ? compressed.toString(format)
  : Buffer.from(fileContents).toString(format);

// Output the base64-encoded, gunzipped HTML
console.log(base64Encoded);
