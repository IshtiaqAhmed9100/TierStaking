
const { time } = require("console");
const { setServers } = require("dns");
const { ethers } = require("hardhat");
const { run } = require("hardhat");
async function verify(address, constructorArguments) {
  console.log(
    `verify  ${address} with arguments ${constructorArguments.join(",")}`
  );
  await run("verify:verify", {
    address,
    constructorArguments,
  });
}
async function main() {
  let _usdtTokenAddress = "0xDb592b20B4d83D41f9E09a933966e0AC02E7421B";
  let _ethPrice = "1100000000000000";
  let _usdtPrice = "1000000";

    const TokenBuyWithUsdt = await ethers.deployContract( 'TokenBuyWithUsdt' , [_usdtTokenAddress, _ethPrice, _usdtPrice]);

      console.log("Deploying TokenBuyWithUsdt...");
      await TokenBuyWithUsdt.waitForDeployment()

      console.log("TokenBuyWithUsdt deployed to:", TokenBuyWithUsdt.target);

      await new Promise(resolve => setTimeout(resolve, 10000));
  verify("0x1f5a331E7E2e1a4163a300389ea4bf23fb12af5b", [
    _usdtTokenAddress,
    _ethPrice,
    _usdtPrice,
  ]);
}
main();
