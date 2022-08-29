async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying contracts with the account:", deployer.address);
  
    const weiAmount = (await deployer.getBalance()).toString();
  
    console.log("Account balance:", (await ethers.utils.formatEther(weiAmount)));
  
    // make sure to replace the "GoofyGoober" reference with your own ERC-20 name!
    const Token = await ethers.getContractFactory("Token");
    const token = await Token.deploy();
    await token.deployed()
  
    const NFTCOLLECTION = await ethers.getContractFactory("NFT");
    const myNFT = await NFTCOLLECTION.deploy(token.address,"ipfs://ThisIsHiddenCID/","ipfs://ThisIsCID/")
    await myNFT.deployed()
  


    console.log("Token address:", token.address);
    console.log("Contract deployed to address:", myNFT.address)
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
  });
