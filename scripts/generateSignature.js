const { ethers } = require("ethers");

require("dotenv").config();

async function generateSignature() {

  const provider = new ethers.JsonRpcProvider('http://localhost:8545');

  const privateKey = process.env.PRIVATE_KEY;

  if (!privateKey) {
    console.error("Private key is not defined in the environment variables.");
    return;
  }

  const wallet = new ethers.Wallet(privateKey, provider);  // Create a wallet instance with the private key

  const name = "TestToken";
  const symbol = "TTK";
  const nonce = 1;
  const contractAddress = "0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f";
  const msgSender = "0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496";

  const message = ethers.solidityPackedKeccak256(
    ["string", "string", "uint256", "address", "uint256", "address"],
    [name, symbol, nonce, contractAddress, 31337, msgSender]
  );

  console.log("message   ",message)

  const signature = await wallet.signMessage(ethers.toBeArray(message));

  console.log("Generated Signature:", signature);
}

generateSignature();
