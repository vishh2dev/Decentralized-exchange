const {ethers} = require("hardhat");

async function main() {

  const dex = await ethers.getContractFactory("DecentralizedExchange");

  const dex_contract = await dex.deploy();
  console.log("Contract deployed to address:", dex_contract.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });