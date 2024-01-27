// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

contract Hoopoe is ERC20, ERC20Burnable, Ownable, ERC20Permit {
    using Math for uint256;

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    constructor()
        ERC20("HOOPOE", "HOOP")
        Ownable(msg.sender)
        ERC20Permit("HOOPOE")
    {
        _mint(msg.sender, 8_000 * (10**decimals()));
    }

    function getCirculatingSupply()
        public
        view
        returns (uint256 circulatingSupply)
    {
        (bool success, uint256 cSupply) = totalSupply().trySub(balanceOf(DEAD));
        if (success) {
            circulatingSupply = cSupply;
        }
    }
}
