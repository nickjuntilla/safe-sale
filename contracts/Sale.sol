pragma solidity ^0.4.11;
import "tokens/HumanStandardToken.sol";


contract Sale {

    /*
     * Events
     */

    event PurchasedTokens(address indexed purchaser, uint amount);

    /*
     * Storage
     */

    address public owner;
    address public wallet;
    HumanStandardToken public tokenReward;
    uint public price;
    uint public startBlock;
    uint public freezeBlock;
    bool public emergencyFlag = false;

    /*
     * Modifiers
     */

    modifier saleStarted {
        require(block.number >= startBlock);
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier notFrozen {
        require(block.number < freezeBlock);
        _;
    }

    modifier notInEmergency {
        assert(emergencyFlag == false);
        _;
    }

    /*
     * Public functions
     */

    /// @dev Sale(): constructor for Sale contract
    /// @param _owner the address which owns the sale, can access owner-only functions
    /// @param _wallet the sale's beneficiary address
    /// @param _tokenAddress address of token contract
    /// @param _price price of the token in Wei
    /// @param _startBlock the block at which this contract will begin selling its token balance
    function Sale(
        address _owner,
        address _wallet,
        address _tokenAddress,
        uint _price,
        uint _startBlock,
        uint _freezeBlock
    ) {
        owner = _owner;
        wallet = _wallet;
        tokenReward = HumanStandardToken(_tokenAddress);
        price = _price;
        startBlock = _startBlock;
        freezeBlock = _freezeBlock;
    }

    /// @dev purchaseToken(): function that exchanges ETH for tokens (main sale function)
    /// @notice You're about to purchase the equivalent of `msg.value` Wei in tokens
    function purchaseTokens()
        saleStarted
        payable
        notInEmergency
    {
        /* Calculate whether any of the msg.value needs to be returned to
           the sender. The tokenPurchase is the actual number of tokens which
           will be purchased once any excessAmount included in the msg.value
           is removed from the purchaseAmount. */
        uint excessAmount = msg.value % price;
        uint purchaseAmount = msg.value - excessAmount;
        uint tokenPurchase = purchaseAmount / price;

        // Cannot purchase more tokens than this contract has available to sell
        require(tokenPurchase <= tokenReward.balanceOf(this));

        // Return any excess msg.value
        if (excessAmount > 0) {
            msg.sender.transfer(excessAmount);
        }

        // Forward received ether minus any excessAmount to the wallet
        wallet.transfer(purchaseAmount);

        // Transfer the sum of tokens tokenPurchase to the msg.sender
        tokenReward.transfer(msg.sender, tokenPurchase);

        PurchasedTokens(msg.sender, tokenPurchase);
    }

    /*
     * Owner-only functions
     */

    function changeOwner(address _newOwner)
        onlyOwner
    {
        require(_newOwner != 0);
        owner = _newOwner;
    }

    function changePrice(uint _newPrice)
        onlyOwner
        notFrozen
    {
        require(_newPrice != 0);
        price = _newPrice;
    }

    function changeWallet(address _wallet)
        onlyOwner
        notFrozen
    {
        require(_wallet != 0);
        wallet = _wallet;
    }

    function changeStartBlock(uint _newBlock)
        onlyOwner
        notFrozen
    {
        require(_newBlock != 0);

        freezeBlock = _newBlock - (startBlock - freezeBlock);
        startBlock = _newBlock;
    }

    function emergencyToggle()
        onlyOwner
    {
        emergencyFlag = !emergencyFlag;
    }

    function extractTokens()
        onlyOwner
    {
        tokenReward.transfer(msg.sender, tokenReward.balanceOf(this));
    }

    // fallback function can be used to buy tokens
    function () payable
    {
      purchaseTokens();
    }

}
