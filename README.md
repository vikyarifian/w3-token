# w3-token

Internal corporate ERC-20 utility token contract system built on Solidity and Foundry. Designed for automating employee meal, overtime allowance distributions (`uang_makan` / `uang_lembur`), and scheduled quarterly performance bonus vault releases.

## Features

- **Role-Based Access**: AccessControl-restricted minting and burning for authorized HR and Finance wallets.
- **Batch Disbursement**: Single-transaction batch transfers to reduce gas costs during mass allowance distributions.
- **Emergency Pause & Freeze**: Ability to pause contract transfers for month-end financial reconciliation audits.
- **Time-Locked Vesting**: Vault module for holding and releasing quarterly performance allowances based on scheduled timestamps.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/): `forge`, `cast`, and `anvil` installed.

## Quick Start

### Build

Compile the smart contracts:

```bash
forge build
```

### Test

Run the test suite:

```bash
forge test
```

### Local Deployment

Deploy locally using Forge script:

```bash
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
export RPC_URL=http://localhost:8545

forge script script/Deploy.s.sol:DeployScript --rpc-url $RPC_URL --broadcast
```

## Smart Contract Structure

```text}
src/
├── AllowanceToken.sol  # ERC20 token with mint, burn, pause, and batch transfer capabilities
└── AllowanceVault.sol  # Time-locked vault for releasing quarterly performance allowances
script/
└── Deploy.s.sol        # Foundry deployment script
```

## Usage & Batch Transfer Example

To run a batch disbursement for employee meal allowances:

```bash
cast send <CONTRACT_ADDRESS> "batchTransfer(address[],uint256[])" "[0x123...,0x456...]" "[100000000000000000000,150000000000000000000]" --private-key $PRIVATE_KEY
```
