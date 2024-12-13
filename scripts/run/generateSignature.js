const { ethers } = require("ethers");

require("dotenv").config();

async function generateSignature() {
  const provider = new ethers.JsonRpcProvider(process.env.SEPOLIA_RPC);

  const privateKey = process.env.PRIVATE_KEY_SIGNER;

  if (!privateKey) {
    console.error("Private key is not defined in the environment variables.");
    return;
  }

  const wallet = new ethers.Wallet(privateKey, provider); // Create a wallet instance with the private key

  const name = "TestToken";
  const symbol = "TTK";
  const nonce = 1;
  const factoryAddress = process.env.FACTORY_ADDRESS;
  const msgSenderOfCreateToken = process.env.DEPLOYER;
  const tokenURI = "test token uri";
  const chainId = 11155111;

  const message = ethers.solidityPackedKeccak256(
    ["string", "string", "string", "uint256", "address", "uint256", "address"],
    [
      name,
      symbol,
      tokenURI,
      nonce,
      factoryAddress,
      chainId,
      msgSenderOfCreateToken,
    ]
  );

  const signature = await wallet.signMessage(ethers.toBeArray(message));

  console.log("Generated Signature:", signature);
}

generateSignature();
