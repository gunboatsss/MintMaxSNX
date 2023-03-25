// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.13;

import "forge-std/Test.sol";
import "../../lib/utils/VyperDeployer.sol";
import "forge-std/Vm.sol";
import "forge-std/StdUtils.sol";
import "forge-std/interfaces/IERC20.sol";

import "../ISynthetix.sol";
import "../IAddressResolver.sol";
import "../IDelegateApprovals.sol";
import "../ITokenState.sol";

import "../IMintMax.sol";

contract MintMaxTest is Test {
    ///@notice create a new instance of VyperDeployer
    VyperDeployer vyperDeployer = new VyperDeployer();
    IMintMax mintMax;

    uint256 minAmount = 100e18;
    address somchai = address(69);
    address somsri = address(70);

    ISynthetix SNX;
    IERC20 sUSD;
    IAddressResolver AddressResolver;
    IDelegateApprovals DelegateApprovals;
    ITokenState SNXTokenState;

    function setUp() public {
        AddressResolver = IAddressResolver(0x1Cb059b7e74fD21665968C908806143E744D5F30);
        SNX = ISynthetix(AddressResolver.getAddress("Synthetix"));
        DelegateApprovals = IDelegateApprovals(AddressResolver.getAddress("DelegateApprovals"));
        sUSD = IERC20(AddressResolver.getAddress("ProxyERC20sUSD"));
        SNXTokenState = ITokenState(AddressResolver.getAddress("TokenStateSynthetix"));
        mintMax = IMintMax(
            vyperDeployer.deployContract("MintMax", abi.encode(address(0x1Cb059b7e74fD21665968C908806143E744D5F30)))
        );
        vm.deal(somchai, 1e18);
        vm.deal(somsri, 1e18);
        // deal(SNXAddress, somchai, 10000e18);
    }

    function test_Set() public {
        vm.prank(somchai);
        mintMax.setMinMint(minAmount);
        require(mintMax.minMint(somchai) == minAmount);
    }
    
    function test_Mint() public {
        vm.prank(address(SNX));
        SNXTokenState.setBalanceOf(somchai, 10000e18);
        vm.startPrank(somchai);
        // Somchai's action to activate max minting
        mintMax.setMinMint(minAmount);
        DelegateApprovals.approveIssueOnBehalf(address(mintMax));
        vm.stopPrank();
        vm.prank(somsri);
        mintMax.mint(somchai);
        require(sUSD.balanceOf(somchai) >= minAmount);
    }
    function testFail_Mint_notEnough() public {
        vm.prank(address(SNX));
        SNXTokenState.setBalanceOf(somchai, 1e18);
        vm.startPrank(somchai);
        // Somchai's action to activate max minting
        mintMax.setMinMint(minAmount);
        DelegateApprovals.approveIssueOnBehalf(address(mintMax));
        vm.stopPrank();
        vm.prank(somsri);
        mintMax.mint(somchai);
    }
}