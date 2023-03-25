"""
@title MintMax
@license GPL-V3
@author GUNBOATs
@notice Contract to automate max minting in Synthetix
    WARNING:    THIS WILL PRETTY MUCH LOCK YOUR SNX FOREVER UNTIL YOU TURN IT OFF AND WAIT FOR 7 DAYS
                ALSO EXPOSE YOU TO THE DEBT WITHOUT HEDGING STRATEGY
                DON'T USE IT IF YOU DON'T KNOW WHAT DELTA-HEDGE MEANS
"""
interface SNXAddressResolver:
    def getAddress(name: bytes32) -> address: view

interface Synthetix:
    def maxIssuableSynths(issuer: address) -> uint256: view
    def issueMaxSynthsOnBehalf(issueForAddress: address): nonpayable

# Synthetix's AddressResolver
AddressResolver: immutable(SNXAddressResolver)

SYNTHETIX_KEY: constant(bytes32) = 0x53796E7468657469780000000000000000000000000000000000000000000000

# minimum amount to mint from specfic address
minMint: public(HashMap[address, uint256])

@external
def __init__(ResolverAddress: address):
    AddressResolver = SNXAddressResolver(ResolverAddress)

@external
def setMinMint(newAmount: uint256):
    """
    @notice Set minimum amount of sUSD receive before anyone can mint
    @param  newAmount the amount of sUSD
    """
    self.minMint[msg.sender] = newAmount

@external
def mint(fromAddress: address):
    """
    @notice Entry point to mint
    @param  fromAddress The address that has mint permission
            Set your Gelato automation to your address with this function
    """
    SNX: Synthetix = Synthetix(AddressResolver.getAddress(SYNTHETIX_KEY))
    assert SNX != Synthetix(empty(address)), "zero address"
    assert self.minMint[fromAddress] != 0, "minMint isn't setup on this address"
    mintable: uint256 = SNX.maxIssuableSynths(fromAddress)
    assert self.minMint[fromAddress] < mintable, "not enough amount from mint"
    SNX.issueMaxSynthsOnBehalf(fromAddress)