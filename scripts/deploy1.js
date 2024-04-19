async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    console.log("Account balance:", (await deployer.provider.getBalance(deployer.address)).toString());  

    const ERC20 = await ethers.getContractFactory("ERC20");
    const erc20 = await ERC20.deploy(0);
  
    console.log("erc20 address:", erc20.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });