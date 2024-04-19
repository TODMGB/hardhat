async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());  

    const MyContract = await ethers.getContractFactory("MyContract");
    const myContract = await MyContract.deploy();
  
    console.log("myContract address:", myContract.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });