[![Coverage Status](https://coveralls.io/repos/github/username/repository/badge.svg?branch=main)](https://coveralls.io/github/aliad10/bonding-fi?branch=main)

# ImagineFun Protocol

ImagineFun Protocol is a system built on Base Network that simplifies the creation, trading, and management of tokens with advanced mechanisms for decentralized exchange and migration. The system provides a modular and secure architecture, enabling users to create tokens, manage liquidity, and handle migrations seamlessly.

---

## Features

- **Token Creation**: Instantly deploy new tokens with customizable parameters.
- **Decentralized Trading**: Facilitates token purchases and sales with secure fee mechanisms.
- **Migration Support**: Automatically migrate tokens upon reaching thresholds.
- **Configurable Parameters**: Flexible settings for fees, thresholds, and limits.
- **Secure Signature Validation**: Protects against unauthorized token creation.

---

## Installation

1. **Clone Repository**:

```bash
git clone [GIT_REPOSITORY_URL]
cd imaginfun-contract
cp .env.example .env
```

2. **Install Dependencies**:

```bash
forge install
forge soldeer install
npm install
```

## Build

```bash
forge build --via-ir
```

## Test

```bash
forge test --via-ir
```

## Coverage

```bash
forge coverage --ir-minimum --report lcov && genhtml lcov.info --branch-coverage --output-dir coverage
```

## Deployment

```bash
forge script <FILE_PATH> --rpc-url <TARGET_CHAIN_RPC_URL> --broadcast --via-ir

#example: deploy ImagineFactory main version 25 ETH mCap
forge script ./scripts/deploy/ImagineFactory.deploy.sol --rpc-url rpc --broadcast --via-ir

#example: deploy ImagineFactory with 2.5 ETH mCap for testnet porposes
forge script ./scripts/deploy/ImagineFactoryTestNet.deploy.sol --rpc-url rpc --broadcast --via-ir

#example: CreateNewToken script
forge script ./scripts/run/CreateNewToken.script.sol --rpc-url rpc --broadcast --via-ir

```
