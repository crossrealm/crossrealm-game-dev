const hre = require("hardhat");

async function main() {
  console.log("Deploying CrossRealm contract...");

  // Deploy the contract
  const CrossRealm = await hre.ethers.getContractFactory("CrossRealm");
  const crossRealm = await CrossRealm.deploy();

  await crossRealm.deployed();

  console.log("CrossRealm deployed to:", crossRealm.address);

  // Add initial realms
  console.log("Adding initial realms...");
  const tx1 = await crossRealm.addRealm("fire");
  await tx1.wait();
  
  const tx2 = await crossRealm.addRealm("water");
  await tx2.wait();
  
  const tx3 = await crossRealm.addRealm("earth");
  await tx3.wait();
  
  console.log("Initial realms added successfully");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
