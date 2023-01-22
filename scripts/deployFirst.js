const fs = require("fs");
const { ethers } = require("hardhat");

async function main() {
  // deploy the CreateActors contract
  const CreateActors = await ethers.getContractFactory("CreateActors");
  const createActors = await CreateActors.deploy();
  await createActors.deployed();

  console.log("CreateActors contract deployed at", createActors.address);

  fs.writeFileSync(
    "./config.js",
    `export const createActorsContractAddress = "${
      createActors.address
    }"\nexport const createActorsOwnerAddress = "${await createActors.signer.getAddress()}"`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
