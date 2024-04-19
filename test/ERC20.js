const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("ERC20 contract", function () {
    async function deployERC20Fixture() {
        const ERC20 = await ethers.getContractFactory("ERC20");
        const [owner, addr1, addr2] = await ethers.getSigners();
        const hardhatERC20 = await ERC20.deploy(0);
        const ERC20Address = await hardhatERC20.getAddress();
        console.log("合约地址==>", ERC20Address);
        return { ERC20, hardhatERC20, owner, addr1, addr2 };
    }
    describe("Deployment", function () {
        it("owner余额应该等于铸造数量-销毁数量-转账数量", async function () {
            const { hardhatERC20, owner, addr1 } = await loadFixture(deployERC20Fixture);
            await hardhatERC20.mint(1000);
            expect(await hardhatERC20.balanceOf(owner)).to.equal(1000);

            await hardhatERC20.burn(30);
            expect(await hardhatERC20.balanceOf(owner)).to.equal(970);

            await hardhatERC20.transfer(addr1.getAddress(), 100); 
            expect(await hardhatERC20.balanceOf(owner)).to.equal(870);

        });
    });
});