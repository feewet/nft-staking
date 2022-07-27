import {expect, use} from 'chai'
import {Contract} from 'ethers'
import {deployContract, MockProvider, solidity} from 'ethereum-waffle'
import BasicNFT from '../build/BasicNFT.json'

use(solidity);

describe('BasicNFT', () => {
  const [owner, account1, account2, walletTo] = new MockProvider().getWallets()
  let nft: Contract

  beforeEach(async () => {
    nft = await deployContract(owner, BasicNFT)
  })

  it('Owner is deployer', async () => {
    expect(await nft.owner()).to.equal(owner.address)
  })

  it('Mint one token to account with id = 0', async () => {
    await nft.mint(account1.address)
    expect(await nft.balanceOf(account1.address)).to.equal(1)
    expect(await nft.ownerOf(0)).to.equal(account1.address)
  })

  it('Check ID exists after minting', async () => {
    await nft.mint(account1.address)
    expect(await nft.exists(0)).to.be.true
  })

})