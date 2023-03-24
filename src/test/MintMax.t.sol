// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

import "../../lib/ds-test/test.sol";
import "../../lib/utils/Console.sol";
import "../../lib/utils/VyperDeployer.sol";

import "../IMintMax.sol";

contract MintMaxTest is DSTest {
    ///@notice create a new instance of VyperDeployer
    VyperDeployer vyperDeployer = new VyperDeployer();
    IMintMax mintMax;

    uint256 minAmount = 100*(10**18);

    function setUp() public {
        mintMax = IMintMax(
            vyperDeployer.deployContract("MintMax", abi.encode(0x1Cb059b7e74fD21665968C908806143E744D5F30))
        );
    }

    function testSet() public {
        mintMax.setMinMint(minAmount);
        require(minAmount = mintMax.minMint(msg.sender) == minAmount);
    }
    
    function testMint() public {
        mintMax.setMinMint(minAmount);
        mintMax.mint(msg.sender);
        require(SNX.balanceOf(msg.sender) >= minAmount);
    }
}