// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

interface IMintMax {
    function minMint(address fromAddress) external returns (uint256);
    function setMinMint(uint256 newAmount) external;
    function mint(address fromAddress) external;
}