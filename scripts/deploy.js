const hardhat = require("hardhat");
async function main() {
    const [deployer, address1] = await ethers.getSigners();
    console.log("合约部署账户==>", await deployer.getAddress());
    console.log("接受者账户==>", await address1.getAddress());

    const ERC20 = await hardhat.ethers.getContractFactory("ERC20");
    const erc20 = await ERC20.deploy(0);
    console.log("erc20合约地址 ==> ", await erc20.getAddress())


    await erc20.mint(1000).then(res => {
        console.log("mint成功,区块号===>", res.blockNumber)
    });

    await erc20.burn(30).then(res => {
        console.log("burn成功,区块号===>", res.blockNumber)
    });

    await erc20.transfer(address1.getAddress(), 100).then(res => {
        console.log("transfer成功,区块号===>", res.blockNumber)
    });

    await erc20.balanceOf(deployer.getAddress()).then(res => {
        console.log("获取合约部署账户余额成功===>", res)
    });

    await erc20.balanceOf(address1.getAddress()).then(res => {
        console.log("获取接受者账户余额成功===>", res)
    });
}
main();