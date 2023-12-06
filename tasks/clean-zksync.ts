import { task } from "hardhat/config";

task(
  "clean-zksync",
  "Clears the zksync cache and artifacts",
  async (taskArgs, hre) => {
    const { rm } = require("fs/promises");
    const { join } = require("path");

    // dry run:
    console.log("delete", join(hre.config.paths.cache, "..", "cache-zk"));
    console.log(
      "delete",
      join(hre.config.paths.artifacts, "..", "artifacts-zk")
    );

    await rm(join(hre.config.paths.cache, "..", "cache-zk"), {
      recursive: true,
      force: true,
    });

    await rm(join(hre.config.paths.artifacts, "..", "artifacts-zk"), {
      recursive: true,
      force: true,
    });
  }
);
