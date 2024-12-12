const { ethers } = require("ethers");

require("dotenv").config();

async function generateSignature() {

  const provider = new ethers.JsonRpcProvider('http://localhost:8545');

  const privateKey = process.env.PRIVATE_KEY_SIGNER;

  if (!privateKey) {
    console.error("Private key is not defined in the environment variables.");
    return;
  }

  const wallet = new ethers.Wallet(privateKey, provider);  // Create a wallet instance with the private key

  const name = "TestToken";
  const symbol = "TTK";
  const nonce = 1;
  const factoryAddress = "0x2e234DAe75C793f67A35089C9d99245E1C58470b";
  const msgSenderOfCreateToken = "0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496";
  const tokenURI = "test token uri";
  const chainId = 31337;

  const message = ethers.solidityPackedKeccak256(
    ["string", "string","string", "uint256", "address", "uint256", "address"],
    [name, symbol,tokenURI, nonce, factoryAddress, chainId, msgSenderOfCreateToken]
  );

  const signature = await wallet.signMessage(ethers.toBeArray(message));

  console.log("Generated Signature:", signature);
}

generateSignature();
