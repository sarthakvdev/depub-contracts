const fs = require("fs");
const { ethers } = require("hardhat");

async function main() {
  // deploy the Story contract
  const Story = await ethers.getContractFactory("Story");
  const story = await Story.deploy();

  await story.deployed();

  console.log("Story contract deployed at", story.address);

  fs.writeFileSync(
    "./configStory.js",
    `export const storyContractAddress = "${
      story.address
    }"\nexport const storyOwnerAddress = "${await story.signer.getAddress()}"`
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
