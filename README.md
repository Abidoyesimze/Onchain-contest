# On-Chain Contest System

A simple Solidity smart contract for managing on-chain contests where participants pay an entry fee to join.

## Overview

This contract implements a basic contest system where:
- Contest creators can set up contests with an entry fee and maximum participant limit
- Participants can join contests by paying the required entry fee in native tokens (ETH)
- Prize pools accumulate from entry fees
- Contests can be closed by their creators

## Contract Structure

### Core Components

**ContestData Struct:**
- `contestId`: Unique identifier for each contest
- `entryFee`: Amount required to join (in wei)
- `maxParticipants`: Maximum number of participants allowed
- `currentParticipants`: Current number of participants
- `status`: Open or Closed
- `prizePool`: Accumulated entry fees
- `creator`: Address that created the contest

### Key Functions

**`createContest(uint256 _entryFee, uint256 _maxParticipants)`**
- Creates a new contest with specified parameters
- Returns the new contest ID
- Validates that entry fee and max participants are greater than zero

**`joinContest(uint256 _contestId)`**
- Allows a participant to join a contest by paying the entry fee
- Validates contest exists, is open, not full, correct fee amount, and participant hasn't already joined
- Updates participant count and prize pool
- Follows checks-effects-interactions pattern

**`closeContest(uint256 _contestId)`**
- Allows contest creator to close a contest
- Prevents new participants from joining

## Design Decisions

### Payment Method
- Uses native token (ETH) for simplicity
- Entry fee validation ensures exact payment amount
- ERC20 support could be added as an extension but was kept out of scope

### Security Considerations
- Checks-effects-interactions pattern: all state changes happen after external calls
- Reentrancy protection through proper state updates before any potential external interactions
- Input validation on all user-provided parameters
- Access control for contest closure (creator-only)

### Gas Optimization
- Uses `storage` reference for contest updates to minimize SLOAD operations
- Single storage slot updates where possible
- Events for off-chain indexing without additional gas cost for queries

### State Management
- Auto-incrementing contest IDs prevent collisions
- Participant mapping prevents duplicate entries efficiently
- Status enum allows for future state extensions if needed

## Assumptions

1. **Native Token Only**: Entry fees are paid in ETH/native token. ERC20 support is out of scope.

2. **No Automatic Closure**: Contests don't auto-close when full. Creator must manually close or implement external logic.

3. **Prize Distribution**: Prize pool accumulation is tracked but distribution logic is out of scope.

4. **No Refunds**: Once a participant joins, there's no mechanism to withdraw or refund entry fees.

5. **Creator Privileges**: Only the creator can close a contest. No admin or multi-sig controls.

6. **No Time Limits**: Contests don't have start/end times. This would require oracle integration (out of scope).

## Testing

Run tests with:
```bash
forge test
```

Test coverage includes:
- Contest creation with valid parameters
- Successful participant joining
- Validation failures (wrong fee, full contest, already joined, closed contest)
- Contest closure functionality

## Usage Example

```solidity
// Create a contest
uint256 contestId = contest.createContest(1 ether, 10);

// Join the contest
contest.joinContest{value: 1 ether}(contestId);

// Close the contest
contest.closeContest(contestId);
```

## Future Enhancements (Out of Scope)

- ERC20 token support for entry fees
- Automatic contest closure when full
- Prize distribution mechanisms
- Time-based contest windows
- Scoring and ranking systems
- Oracle integration for external data

## License

MIT
