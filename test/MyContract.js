const { expect } = require("chai");
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");

describe("Mycontract contract", function () {
    async function deployMycontractFixture() {
        const MyContract = await ethers.getContractFactory("MyContract");
        const [owner, addr1, addr2] = await ethers.getSigners();
        const hardhatMyContract = await MyContract.deploy();
        const MyContractAddress = await hardhatMyContract.getAddress();
        console.log("合约地址==>", MyContractAddress);
        return { MyContract, hardhatMyContract, owner, addr1, addr2 };
    }
    describe("Deployment", function () {
        it("算数合约：", async function () {
            let A = 7990;
            let B = 27;
            let C = 23;

            const { hardhatMyContract } = await loadFixture(deployMycontractFixture);
            await hardhatMyContract.setA(A);
            await hardhatMyContract.setB(B);
            await hardhatMyContract.setC(C); 
            expect(await hardhatMyContract.getD()).to.equal(A+B-C -1 );
            expect(await hardhatMyContract.getE()).to.equal(A*B-C);


        });
    });
});