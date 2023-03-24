interface SNXAddressResolver:
    def getAddress(name: bytes32) -> address: view

interface Synthetix:
    def maxIssuableSynths(issuer: address) -> uint256: view
    def issueMaxSynthsOnBehalf(issueForAddress: address): nonpayable

# Synthetix's AddressResolver
AddressResolver: SNXAddressResolver

SYNTHETIX_KEY: constant(bytes32) = 0x53796E7468657469780000000000000000000000000000000000000000000000

# minimum amount to mint from specfic address
minMint: public(HashMap[address, uint256])

@external
def __init__(ResolverAddress: address):
    self.AddressResolver = SNXAddressResolver(ResolverAddress)

@external
def setMinMint(newAmount: uint256):
    self.minMint[msg.sender] = newAmount

@external
def mint(fromAddress: address):
    SNX: Synthetix = Synthetix(self.AddressResolver.getAddress(SYNTHETIX_KEY))
    assert SNX != Synthetix(empty(address)), "zero address"
    mintable: uint256 = SNX.maxIssuableSynths(fromAddress)
    assert self.minMint[fromAddress] < mintable, "not enough amount from mint"
    SNX.issueMaxSynthsOnBehalf(fromAddress)