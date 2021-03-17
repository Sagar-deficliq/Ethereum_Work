pragma solidity ^0.4.24;

 /**
 * Token Smart contract for Staking Platform
 * Token Name: Cliq Token
 * Token Symbol: CLIQ
 * Decimal: 18
 * Initial Supply : 1000000000000
 */

 /**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b,"Calculation error");
        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the qu
    * otient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256){
        // Solidity only automatically asserts when dividing by 0
        require(b > 0,"Calculation error");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256){
        require(b <= a,"Calculation error");
        uint256 c = a - b;
        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256){
        uint256 c = a + b;
        require(c >= a,"Calculation error");
        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256){
        require(b != 0,"Calculation error");
        return a % b;
    }
}

 /**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

 /**
 * @title CLIQ Contract
 */
 contract CLIQ is IERC20 {

    using SafeMath for uint256;

    address private _owner;                         // Variable for Owner of the Contract.
    string  private _name;                          // Variable for Name of the token.
    string  private _symbol;                        // Variable for symbol of the token.
    uint256 private _decimals;                      // variable to maintain decimal precision of the token.
    uint256 private _totalSupply;                   // Variable for total supply of token.
    address private _tokenStakePoolAddress;         // Stake Pool Address to manage Staking user's Token.
    address private _tokenPurchaseAddress;          // Address for managing token for token purchase.
    uint256 private _tokenPriceBNB;                 // variable to set price of token with respect to BNB.
    uint256 public airdropcount = 0;                // variable to keep track on number of airdrop
    
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    constructor (string memory name, string memory symbol, uint8 decimals, uint256 totalSupply, address owner, address tokenStakePoolAddress) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _totalSupply = totalSupply*(10**uint256(decimals));
        _balances[owner] = _totalSupply;
        _owner = owner;
        _tokenStakePoolAddress = tokenStakePoolAddress;
    }
 
     /*
     * ----------------------------------------------------------------------------------------------------------------------------------------------
     * Functions for owner
     * ----------------------------------------------------------------------------------------------------------------------------------------------
     */

    /**
    * @dev get address of smart contract owner
    * @return address of owner
    */
    function getowner() public view returns (address) {
      return _owner;
    }

    /**
    * @dev modifier to check if the message sender is owner
    */
    modifier onlyOwner() {
        require(isOwner(),"You are not authenticate to make this transfer");
        _;
    }

    /**
     * @dev Internal function for modifier
    */
    function isOwner() internal view returns (bool) {
      return msg.sender == _owner;
    }

    /**
     * @dev Transfer ownership of the smart contract. For owner only
     * @return request status
    */
    function transferOwnership(address newOwner) public onlyOwner returns (bool){
      _owner = newOwner;
      return true;
    }

     /*
     * ----------------------------------------------------------------------------------------------------------------------------------------------
     * View only functions
     * ----------------------------------------------------------------------------------------------------------------------------------------------
     */

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
      return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
      return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint256) {
      return _decimals;
    }

    /**
     * @dev Total number of tokens in existence.
     */
    function totalSupply() public view returns (uint256) {
      return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return A uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
      return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
      return _allowed[owner][spender];
    }

   /*
   * ----------------------------------------------------------------------------------------------------------------------------------------------
   * Transfer, allow, mint and burn functions
   * ----------------------------------------------------------------------------------------------------------------------------------------------
   */

    /**
     * @dev Transfer token to a specified address.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
      _transfer(msg.sender, to, value);
      return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
      _transfer(from, to, value);
      _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
      return true;
    }

    /**
     * @dev Transfer token for a specified addresses.
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
      require(from != address(0),"Invalid from Address");
      require(to != address(0),"Invalid to Address");
      require(value > 0, "Invalid Amount");
      _balances[from] = _balances[from].sub(value);
      _balances[to] = _balances[to].add(value);
      emit Transfer(from, to, value);
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
      _approve(msg.sender, spender, value);
      return true;
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
      require(spender != address(0),"Invalid address");
      require(owner != address(0),"Invalid address");
      require(value > 0, "Invalid Amount");
      _allowed[owner][spender] = value;
      emit Approval(owner, spender, value);
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
      _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
      return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
      _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
      return true;
    }
    
    /**
     * @dev Airdrop function to airdrop tokens. Best works upto 50 addresses in one time. Maximum limit is 200 addresses in one time.
     * @param _addresses array of address in serial order
     * @param _amount amount in serial order with respect to address array
     */
    function airdropByOwner(address[] memory _addresses, uint256[] memory _amount) public onlyOwner returns (bool){
      require(_addresses.length == _amount.length,"Invalid Array");
        uint256 count = _addresses.length;
        for (uint256 i = 0; i < count; i++){
            _transfer(msg.sender, _addresses[i], _amount[i]);
            airdropcount = airdropcount + 1;
        }
        return true;
    }

    /**
     * @dev Internal function that burns an amount of the token of a given account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
      require(account != address(0),"Invalid account");
      require(value > 0, "Invalid Amount");
      _totalSupply = _totalSupply.sub(value);
      _balances[account] = _balances[account].sub(value);
      emit Transfer(account, address(0), value);
    }

    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public onlyOwner {
      _burn(msg.sender, value);
    }

    /**
     * Function to mint tokens
     * @param value The amount of tokens to mint.
     */
    function mint(uint256 value) public onlyOwner returns(bool){
      require(value > 0,"The amount should be greater than 0");
      _balances[msg.sender] = _balances[msg.sender].add(value);
      _totalSupply = _totalSupply.add(value);
      emit Transfer(address(0), msg.sender, value);
      return true;
    }
    
    //Get BNB balance from this contract 
    function getContractBNBBalance() public view returns(uint256){
      return(address(this).balance);
    }

  /*
  * ----------------------------------------------------------------------------------------------------------------------------------------------
  * Staking logic, mapping and functions
  * ----------------------------------------------------------------------------------------------------------------------------------------------
  */

  //---------------------------------------------------Variable, Mapping for Token Staking------------------------------------------------------//

  // mapping for users with id => address Staking Address
  mapping (uint256 => address) private _tokenStakingAddress;

  // mapping for users with id => Staking Time
  mapping (uint256 => uint256) private _tokenStakingStartTime;

  // mapping for users with id => End Time
  mapping (uint256 => uint256) private _tokenStakingEndTime;

  // mapping for users with id => Tokens 
  mapping (uint256 => uint256) private _usersTokens;
  
  // mapping for users with id => Status
  mapping (uint256 => bool) private _TokenTransactionstatus;    
  
  // mapping to track purchased token
  mapping(address=>uint256) private _myPurchasedTokens;
  
  // mapping for open order BNB
  mapping(address=>uint256) private _BNBAmountByAddress;
  
  // mapping to keep track of final withdraw value of staked token
  mapping(uint256=>uint256) private _finalTokenStakeWithdraw;
  
  // mapping to keep track total number of staking days
  mapping(uint256=>uint256) private _tokenTotalDays;
  
  // penalty amount after staking time
  uint256 private _penaltyAmountAfterStakingTime;
  
  // variable to keep count of Token Staking
  uint256 private _tokenStakingCount = 0;

  // variable for Total BNB
  uint256 private _totalBNB;
  
  // variable for time management
  uint256 private _tokentime;
  
  // variable for token staking pause and unpause mechanism
  bool public tokenPaused = false;
  
  // events to handle staking pause or unpause
  event Paused();
  event Unpaused();
  

  //---------------------------------------------------Variable, Mapping for BNB Staking------------------------------------------------------//
  
  // variable to keep count of BNB Staking
  uint256 private _bnbStakingCount = 0;

  // variable for time management
  uint256 private _bnbTime;

  // mapping for users with id => Staking Time
  mapping (uint256 => uint256) private _bnbStakingStartTime;

  // mapping for users with id => End Time
  mapping (uint256 => uint256) private _bnbStakingEndTime;

  // mapping for users with id => address Staking Address
  mapping (uint256 => address) private _bnbStakingAddress;
  
  // mapping for users with id => BNB
  mapping (uint256 => uint256) private _usersBNB;

  // mapping for BNB deposited by user 
  mapping(address=>uint256) private _bnbStakedByUser;

  // mapping to keep track total number of staking days
  mapping(uint256=>uint256) private _bnbTotalDays;

  // mapping for users with id => Status
  mapping (uint256 => bool) private _bnbTransactionstatus;   
  
  // variable for BNB staking pause and unpause mechanism
  bool public BNBPaused = false;


  // modifier to check the user for staking || Re-enterance Guard
  modifier tokenStakeCheck(uint256 tokens, uint256 timePeriod){
    require(tokens > 0, "Invalid Token Amount, Please Try Again!!! ");
    require(tokens <= 1e20, "Invalid Amount, Select amount less than 100 and try again!!!");
    require(timePeriod == 30 || timePeriod == 60 || timePeriod == 90, "Enter the Valid Time Period and Try Again !!!");
    _;
  }
  
  // modifier to check time for BNB Staking 
  modifier BNBStakeCheck(uint256 timePeriod){
    require(timePeriod == 30 || timePeriod == 60 || timePeriod == 90, "Enter the Valid Time Period and Try Again !!!");
      _;
  }
  // modifier to check for the payable amount for purchasing the tokens
  modifier payableCheck(){
    require(msg.value > 0 && balanceOf(_tokenPurchaseAddress) > 0, "Cannot buy tokens, either amount is less or no tokens for sale");
    _;
  }

  /*
  * ----------------------------------------------------------------------------------------------------------------------------------------------
  * Owner functions of get value, set value and withdraw Functionality
  * ----------------------------------------------------------------------------------------------------------------------------------------------
  */

  // function to set Token Stake Pool address
  function setTokenStakePoolAddress(address add) public onlyOwner returns(bool){
    require(add != address(0),"Invalid Address");
    _tokenStakePoolAddress = add;
    return true;
  }
  
  // function to get Token Stake Pool address
  function getTokenStakePoolAddress() public view returns(address){
    return _tokenStakePoolAddress;
  }

  // funtion to set _purchaseableTokensAddress
  function setpurchaseableTokensAddress(address add) public onlyOwner returns(bool){
    require(add != address(0),"Invalid Address");
    _tokenPurchaseAddress = add;
    return true;
  }

  // function to get _purchaseableTokensAddress
  function getpurchaseableTokensAddress() public view returns(address){
    return _tokenPurchaseAddress;
  }

  // function to Set the price of each token for BNB purchase
  function setPriceToken(uint256 tokenPrice) external onlyOwner returns (bool){
    require(tokenPrice >0,"Invalid Amount");
    _tokenPriceBNB = tokenPrice;
    return(true);
  }
    
  // function to get price of each token for BNB purchase
  function getPriceToken() public view returns(uint256) {
    return _tokenPriceBNB;
  }
  
//   // function to blacklist any stake
//   function blacklistStake(bool status,uint256 stakingId) external onlyOwner returns(bool){
//     _TokenTransactionstatus[stakingId] = status;
//   }

  // function to withdraw Funds by owner only
  function withdraw(uint256 amount) external onlyOwner returns(bool){
    msg.sender.transfer(amount);
    //msg.sender.transfer(address(this).balance);
    return true;
  }
  
  /*
  * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  * Function for purchase Token Functionality
  * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  */
  
  // function to perform purchased token
  function purchaseTokens() external payable payableCheck returns(bool){
    _myPurchasedTokens[msg.sender] = _myPurchasedTokens[msg.sender] + msg.value * _tokenPriceBNB;
    _BNBAmountByAddress[msg.sender] = msg.value;
    _totalBNB = _totalBNB + msg.value;
    return true;
  }
  
  // funtion to withdraw purchased token 
  function withdrawPurchaseToken() external returns(bool){
    require(_myPurchasedTokens[msg.sender]>0,"You do not have any purchased token");
    _myPurchasedTokens[msg.sender] = 0;
    _BNBAmountByAddress[msg.sender] = 0;
    _transfer(_tokenPurchaseAddress, msg.sender, _myPurchasedTokens[msg.sender]);
    _totalBNB  = _totalBNB.sub(_myPurchasedTokens[msg.sender]);
    return true;
  }
  
  // function to get purchased token 
  function getMyPurchasedTokens(address add) public view returns(uint256){
    return _myPurchasedTokens[add];
  }
  
  // function to get BNB deposit amount by address
  function getBNBAmountByAddress(address add) public view returns(uint256){
    return _BNBAmountByAddress[add];
  }
  
  // function to total BNB
  function getTotalBNB() public view returns(uint256){
    return _totalBNB;
  }
  
  /*
  * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  * Functions for Staking Functionality
  * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  */
  
   function stakeBNB(uint256 time) external payable BNBStakeCheck(time) returns(bool){
    require(BNBPaused == false, "BNB Staking is Paused, Please try after staking get unpaused!!!");
    _bnbTime = now + (time * 1 days);
    _bnbTotalDays[_bnbStakingCount] = time;
    _bnbStakingAddress[_bnbStakingCount] = msg.sender;
    _bnbStakingEndTime[_bnbStakingCount] = _bnbTime;
    _bnbStakingStartTime[_bnbStakingCount] = now;
    _usersBNB[_bnbStakingCount] = msg.value;
    _bnbStakedByUser[msg.sender] = _bnbStakedByUser[msg.sender ].add(msg.value);
    _bnbTransactionstatus[_bnbStakingCount] = false;
    _bnbStakingCount = _bnbStakingCount + 1 ;
    return true;
  }

  // function to get staking count
  function getBNBStakingCount() public view returns(uint256){
      return _bnbStakingCount;
  }

  // function to performs staking for user tokens for a specific period of time
  function stakeToken(uint256 tokens, uint256 time) public tokenStakeCheck(tokens, time) returns(bool){
    require(tokenPaused == false, "Staking is Paused, Please try after staking get unpaused!!!");
    _tokentime = now + (time * 1 days);
    _tokenTotalDays[_tokenStakingCount] = time;
    _tokenStakingAddress[_tokenStakingCount] = msg.sender;
    _tokenStakingEndTime[_tokenStakingCount] = _tokentime;
    _tokenStakingStartTime[_tokenStakingCount] = now;
    _usersTokens[_tokenStakingCount] = tokens;
    _transfer(msg.sender, _tokenStakePoolAddress, tokens);
    _TokenTransactionstatus[_tokenStakingCount] = false;
    _tokenStakingCount = _tokenStakingCount +1 ;
    return true;
  }

  // function to get staking count
  function getTokenStakingCount() public view returns(uint256){
      return _tokenStakingCount;
  }
  
  // function to get Rewards on the stake
  function getRewardDetailsByUserId(uint256 id) public view returns(uint256){
    if(_tokenTotalDays[id] == 30) {
        return ((_usersTokens[id]*10/100));
    } else if(_tokenTotalDays[id] == 60) {
               return ((_usersTokens[id]*20/100));
      } else if(_tokenTotalDays[id] == 90) { 
                 return ((_usersTokens[id]*30/100));
        } else{
              return 0;
          }
  }

  // function to calculate penalty for the message sender
  function getPenaltyDetailByUserId(uint256 id) public view returns(uint256){
     if(_tokenStakingEndTime[id] > now){
         if(_tokenTotalDays[id]==30){
             return ((_usersTokens[id]*3/100));
         } else if(_tokenTotalDays[id] == 60) {
               return ((_usersTokens[id]*6/100));
           } else if(_tokenTotalDays[id] == 90) { 
                 return ((_usersTokens[id]*9/100));
             } else {
                 return 0;
               }
     } else{
        return 0;
     }
  }
  
  // function for withdrawing staked tokens
  function withdrawStakedBNB(uint256 stakingId) public returns(bool){
    require(_bnbStakingAddress[stakingId] == msg.sender,"No staked token found on this address and ID");
    require(_bnbTransactionstatus[stakingId] != true,"Either tokens are already withdrawn or blocked by admin");
    require(now >= _bnbStakingStartTime[stakingId] + 1296000, "Unable to Withdraw Stake, Please Try after 15 Days from the date of Staking");
    _bnbTransactionstatus[stakingId] = true;
    _bnbStakingAddress[stakingId].transfer(_usersBNB[stakingId]);
    // if(now >= _tokenStakingEndTime[stakingId]){
    //     _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId] + getRewardDetailsByUserId(stakingId);
    //     _transfer(_tokenStakePoolAddress,msg.sender,_finalTokenStakeWithdraw[stakingId]);
    // } else {
    //     _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId] + getPenaltyDetailByUserId(stakingId);
    //     _transfer(_tokenStakePoolAddress,msg.sender,_finalTokenStakeWithdraw[stakingId]);
    //   }
    return true;
  }
  
  // function for withdrawing staked tokens
  function withdrawStakedTokens(uint256 stakingId) public returns(bool){
    require(_tokenStakingAddress[stakingId] == msg.sender,"No staked token found on this address and ID");
    require(_TokenTransactionstatus[stakingId] != true,"Either tokens are already withdrawn or blocked by admin");
    require(balanceOf(_tokenStakePoolAddress) > _usersTokens[stakingId], "Pool is dry or empty, transaction cannot be performed!!!");
    require(now >= _tokenStakingStartTime[stakingId] + 1296000, "Unable to Withdraw Stake, Please Try after 15 Days from the date of Staking");
    _TokenTransactionstatus[stakingId] = true;
    if(now >= _tokenStakingEndTime[stakingId]){
        _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId] + getRewardDetailsByUserId(stakingId);
        _transfer(_tokenStakePoolAddress,msg.sender,_finalTokenStakeWithdraw[stakingId]);
    } else {
        _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId] + getPenaltyDetailByUserId(stakingId);
        _transfer(_tokenStakePoolAddress,msg.sender,_finalTokenStakeWithdraw[stakingId]);
      }
    return true;
  }
  
  // function to get Final Withdraw Staked value
  function getFinalTokenStakeWithdraw(uint256 id) public view returns(uint256){
    return _finalTokenStakeWithdraw[id];
  }
  
  // function to pause Token Staking
  function pauseTokenStaking() public onlyOwner {
    tokenPaused = true;
    emit Paused();
    }

  // function to unpause Token Staking
  function unpauseTokenStaking() public onlyOwner {
    tokenPaused = false;
    emit Unpaused();
    }
    
  // function to pause BNB Staking
  function pauseBNBStaking() public onlyOwner {
    BNBPaused = true;
    emit Paused();
    }

  // function to unpause BNB Staking
  function unpauseBNBStaking() public onlyOwner {
    BNBPaused = false;
    emit Unpaused();
    }
    
  /*
  * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  * Functions for Stake Token Functionality
  * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  */

  // function to get Staking address by id
  function getTokenStakingAddressById(uint256 id) external view returns (address){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingAddress[id];
  }
  
  // function to get Staking Starting time by id
  function getTokenStakingStartTimeById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingStartTime[id];
  }
  
  // function to get Staking Ending time by id
  function getTokenStakingEndTimeById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingEndTime[id];
  }
  
  // function to get Staking Total Days by Id
  function getTokenStakingTotalDaysById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenTotalDays[id];
  }

  // function to get Staking tokens by id
  function getStakingTokenById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _usersTokens[id];
  }

  // function to get Token lockstatus by id
  function getTokenLockStatus(uint256 id) external view returns(bool){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _TokenTransactionstatus[id];
  }

  /*
  * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  * Functions for Stake BNB Functionality
  * ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  */

  // function to get Staking address by id
  function getBNBStakingAddressById(uint256 id) external view returns (address){
    require(id <= _bnbStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _bnbStakingAddress[id];
  }
  
  // function to get Staking Starting time by id
  function getBNBStakingStartTimeById(uint256 id) external view returns(uint256){
    require(id <= _bnbStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _bnbStakingStartTime[id];
  }
  
  // function to get Staking Ending time by id
  function getBNBStakingEndTimeById(uint256 id) external view returns(uint256){
    require(id <= _bnbStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _bnbStakingEndTime[id];
  }
  
  // function to get Staking Total Days by Id
  function getBNBStakingTotalDaysById(uint256 id) external view returns(uint256){
    require(id <= _bnbStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _bnbTotalDays[id];
  }
  
  // function to get Staking tokens by id
  function getBNBStakedById(uint256 id) external view returns(uint256){
    require(id <= _bnbStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _usersBNB[id];
  }

  // function to get Staking tokens by id
  function getBNBStakedByUser(address add) external view returns(uint256){
    require(add != address(0),"Invalid Address, Please try again!!");
    return _bnbStakedByUser[add];
  }

  // function to get Token lockstatus by id
  function getBNBLockStatus(uint256 id) external view returns(bool){
    require(id <= _bnbStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _bnbTransactionstatus[id];
  }
}
