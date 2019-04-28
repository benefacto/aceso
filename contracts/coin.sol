pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}

contract Coin {
    // Public variables of the token
    address public collectivePot;
    string public name;
    string public symbol;
    uint8 public feeDenominator = 20;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value, address indexed collective, uint256 transferFee);

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        uint256 initialSupply,
        uint8 calculateFeeDenominator,
        address collectivePotAddress,
        string memory tokenName,
        string memory tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        feeDenominator = calculateFeeDenominator;
        collectivePot = collectivePotAddress                // Set the address of the collectivePot from parameter for now
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }

    /**
     * Internal calculation of amount to be transferred to collectivePot
     */
    function _calculateCollectivePotFee(uint _value)
    {
        // check for overflows
        require(_numerator * 10 > _numerator);
        uint _numerator  = _value * 10;
        // with rounding of last digit
        uint _quotient =  ((_numerator / calculateFeeDenominator) + 5) / 10;
        return ( _quotient);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        // calculate transfer fee
        uint transferFee = _calculateCollectivePotFee(_value);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to] + balanceOf[collectivePot];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Subtract transfer fee from the sender
        balanceOf[_from] -= transferFee;
        // Add the same to the collectivePot
        balanceOf[collectivePot] += transferFee;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value, collectivePot, transferFee);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] + balanceOf[collectivePot] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
}
