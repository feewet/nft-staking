import {expect, use} from 'chai'
import {Contract, constants} from 'ethers'
import {deployContract, MockProvider, solidity} from 'ethereum-waffle'
import Pair from '../build/Pair.json'

use(solidity);

describe('Pair', () => {
  const [owner, account1, account2, account3, account4, account5] = new MockProvider().getWallets()
  let pair: Contract

  beforeEach(async () => {
    pair = await deployContract(owner, Pair)
  })

  describe('Setup', () => {
    it('next pair is zero address', async () => {
      expect(await pair.nextPair()).to.equal(constants.AddressZero)
    })
  })

  describe('Match and Resolve 2 players', () => {
    beforeEach(async () => {
      // 1 player joins
      await pair.connect(account1).join()
    })

    describe('One Player Joins', () => {
      it('emits event', async () => {
        expect(await pair.connect(account2).join())
          .to.emit(pair, 'PairFound')
          .withArgs(account1.address, account2.address)
      })

      it('first player has no match', async () => {
        expect(await pair.pair(account1.address)).to.equal(constants.AddressZero)
      })

      it('next pair is first player', async () => {
        expect(await pair.nextPair()).to.equal(account1.address)
      })

      it('first player cannot join again', async () => {
        await expect(pair.connect(account1).join())
          .to.be.revertedWith('Sender is already waiting for a pair.')
      })
    })

    describe('Match 2 Players', () => {
      beforeEach(async () => {
        // Second player joins
        await pair.connect(account2).join()
      })

      it('emits event', async () => {
        expect(await pair.connect(account1).resolve(account1.address))
          .to.emit(pair, 'PairResolved')
          .withArgs(account1.address, account2.address, account1.address)
      })

      it('first and second player are matched', async () => {
        expect(await pair.pair(account1.address)).to.equal(account2.address)
        expect(await pair.pair(account2.address)).to.equal(account1.address)
        expect(await pair.nextPair()).to.equal(constants.AddressZero)
      })

      it('second player cannot join again', async () => {
        await expect(pair.connect(account2).join())
          .to.be.revertedWith('Sender is already paired.')
      })
    })

    describe('Resolve 2 Players', () => {
        beforeEach(async () => {
          // join and resolve match
          await pair.connect(account2).join()
          await pair.connect(account1).resolve(account1.address)
        })

        it('first player has no match', async () => {
          expect(await pair.pair(account1.address)).to.equal(constants.AddressZero)
        })

        it('second player has no match', async () => {
          expect(await pair.pair(account2.address)).to.equal(constants.AddressZero)
        })

        it('next pair is zero address', async () => {
          expect(await pair.nextPair()).to.equal(constants.AddressZero)
        })
      })
  })
})







