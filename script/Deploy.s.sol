// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {W3Token} from "../src/W3Token.sol";
import {BatchDistributor} from "../src/BatchDistributor.sol";
import {AllowanceVault} from "../src/AllowanceVault.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Workaround for Forge VM limitation: vm.envAddress() reverts if the env variable is empty,
        // which prevents simple fallback behavior in scratchpad environments. We load as string first.
        address hrAdmin;
        string memory hrEnv = vm.envOr("HR_ADMIN_ADDRESS", string(""));
        if (bytes(hrEnv).length > 0) {
            hrAdmin = vm.parseAddress(hrEnv);
        } else {
            hrAdmin = vm.addr(deployerPrivateKey);
        }

        address financeAdmin;
        string memory finEnv = vm.envOr("FINANCE_ADMIN_ADDRESS", string(""));
        if (bytes(finEnv).length > 0) {
            financeAdmin = vm.parseAddress(finEnv);
        } else {
            financeAdmin = vm.addr(deployerPrivateKey);
        }

        vm.startBroadcast(deployerPrivateKey);

        // Deploy the main ERC20 Token Engine
        W3Token token = new W3Token();

        // Deploy BatchDistributor for handling lembur and uang makan bulk distributions
        BatchDistributor distributor = new BatchDistributor(address(token));

        // Deploy AllowanceVault for quarterly performance allocations
        AllowanceVault vault = new AllowanceVault(address(token));

        // Configure admin roles for corporate HR and Finance wallets
        token.setHR(hrAdmin, true);
        token.setFinance(financeAdmin, true);

        // Authorize distributor contract to perform batch mint activities for lembur
        token.setHR(address(distributor), true);

        // Authorize vault contract to manage allowance distribution roles
        token.setFinance(address(vault), true);

        vm.stopBroadcast();
    }
}
