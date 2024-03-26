How can you help?
1. Discuss ideas and/or opinions
2. Read code and find flaws
3. Help write code and test suites
4. Create Text Art for the contract
5. Prettify the contract and function name

You don't have to be a dev to contribute. Ask questions, and scrutinize, we only have 1 shot at this.

Essentials

SBT Contract: https://github.com/0xFueki/TheKabalSBT
Dew Minter Contract: https://polygonscan.com/address/0x9B2E0086e53112c8be56159F874C01eB0950Ecd8#code

Design Decisions
1. I implemented ERC6147 (https://eips.ethereum.org/EIPS/eip-6147) as our SBT. This gives us the ability to transfer SBTs in cases of compromised wallets.
2. Most of the contract is taken from Solmate's standard & audit contract.
3. There's an option to delegate metadata to external contracts, so we can add new features to our tokens in the future.
4. There's a Kabal Minter contract. This is so we can assign TokenIDs to the wallet following everybody's initiation number. Dew's minter contract doesn't have this ability.
5. I reserved the ability to enable trading, essentially making the SBT no longer an SBT.

Overall Mint Flow
1. Wallet Mint from Dew Launchpad
2. Dew Minter Contract talks to Kabal Minter Contract
3. Kabal Minter Contract finds the TokenID reserved for that wallet
4. Kabal Minter Contract mints the token on the Kabal Token Contract

To Do
1. Create Test Suites. The contract is untested at the moment, I will make one in the coming days.
2. Prettify Contract
3. Test on test net
4. Discuss design decisions

Topic of discussion
1. The ability to resume trading is a part of ERC6147. Do we want to keep this ability or no?
2. All power is currently held by the contract owner. Do we need multiple roles?