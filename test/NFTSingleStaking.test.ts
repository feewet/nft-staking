import {expect, use} from 'chai'
import {Contract, constants} from 'ethers'
import {deployContract, MockProvider, solidity} from 'ethereum-waffle'
import BasicNFT from '../build/BasicNFT.json'
import NFTSingleStaking from '../build/NFTSingleStaking.json'

use(solidity);

describe('NFTSingleStaking', () => {
  const [owner, account1, account2] = new MockProvider().getWallets()
  let nft: Contract
  let staking: Contract

  beforeEach(async () => {
    nft = await deployContract(owner, BasicNFT)
    staking = await deployContract(owner, NFTSingleStaking, [nft.address])
  })

  describe('setup', () => {
    it('owner is deployer', async () => {
      expect(await staking.owner()).to.equal(owner.address)
    })

    it('nft address is set correctly', async () => {
      expect(await staking.nft()).to.equal(nft.address)
    })
  })

  describe('Staking and Unstaking', () => {
    beforeEach(async () => {
      // mint 2 NFTs for account1 and 1 NFT for account 2
      await nft.connect(owner).mint(account1.address)
      await nft.connect(owner).mint(account1.address)
      await nft.connect(owner).mint(account2.address)
      await nft.connect(account1).approve(staking.address, 0)
      await nft.connect(account1).approve(staking.address, 1)
      await nft.connect(account2).approve(staking.address, 2)
      // account 1 stakes
      await staking.connect(account1).stake(0)
    })

    describe('Staking', () => {
      it('staking contract owns NFT after staking', async () => {
        expect(await nft.ownerOf(0)).to.equal(staking.address)
      })

      it('cannot stake more than one NFT from a single account', async () => {
        await expect(staking.connect(account1).stake(1))
          .to.be.revertedWith('Sender is already staked.')
      })

      it('cannot stake an NFT you do not own', async () => {
        await expect(staking.connect(account2).stake(1))
          .to.be.revertedWith('Sender is not owner of token.')
      })

      it('emits event', async () => {
        await expect(staking.connect(account2).stake(2))
          .to.emit(staking, 'Staked')
          .withArgs(account2.address, 2)
      })

      describe('data is stored correctly on staking', () => {
        it('stakers', async () => {
          expect(await staking.stakers(account1.address)).to.equal(0)
        })

        it('stakedTokens', async () => {
          expect(await staking.stakedTokens(0)).to.equal(account1.address)
        })

        it('isStaked', async () => {
          expect(await staking.isStaked(account1.address)).to.be.true
        })
      })
    })

    describe('Unstaking', () => {

      beforeEach(async () => {
        // account 1 unstakes
        await staking.connect(account1).unstake()
        // account 2 stakes
        await staking.connect(account2).stake(2)
      })

      it('owner owns NFT after unstaking', async () => {
        expect(await nft.ownerOf(0)).to.equal(account1.address)
      })

      it('can stake again after unstaking', async () => {
        await nft.connect(account1).approve(staking.address, 0)
        await staking.connect(account1).stake(0)
        expect(await staking.isStaked(account1.address)).to.be.true
      })

      it('emits event', async () => {
        await expect(staking.connect(account2).unstake())
          .to.emit(staking, 'Unstaked')
          .withArgs(account2.address, 2)
      })

      describe('data is reset after unstaking', () => {
        it('stakers', async () => {
          expect(await staking.stakers(account1.address)).to.equal(0)
        })

        it('stakedTokens', async () => {
          expect(await staking.stakedTokens(0)).to.equal(constants.AddressZero)
        })

        it('isStaked', async () => {
          expect(await staking.isStaked(account1.address)).to.be.false
        })
      })
    })
  })
})