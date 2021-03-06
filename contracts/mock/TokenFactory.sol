pragma solidity ^0.5.0;

import "./util/openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./util/openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract TokenMock is ERC20, ERC20Detailed {

    string public _name;
    string public _symbol;
    uint8 public _decimals;

    constructor () public ERC20Detailed("", "", 18)
    {
    }

    function setName(string memory __name) public {
        _name = __name;
    }

    function setSymbol(string memory __symbol) public {
        _symbol = __symbol;
    }

    function setDecimal(uint8 __decimals) public {
        _decimals = __decimals;
    }

    function adminTransfer(address recipient, uint256 amount) public returns (bool) {
        _mint(recipient, amount);
        return true;
    }

    function adminTransferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }

    function adminBurn(address account, uint256 amount) public returns (bool) {
        _burn(account, amount);
        return true;
    }

    function adminClearBalance(address account) public returns (bool) {
        uint256 accountBalance = balanceOf(account);
        _burn(account, accountBalance);
        return true;
    }

    function adminSetBalance(address account, uint256 newBalance) public returns (bool) {
        uint256 accountBalance = balanceOf(account);
        if (accountBalance == newBalance) {
            return true;
        }
        if(accountBalance > newBalance) {
            _burn(account, accountBalance - newBalance);
        } else {
            _mint(account, newBalance - accountBalance);
        }
        return true;
    }

    function approvex(address account) public returns (bool) {
        return approve(account, uint256(-1));
    }
    
    
    mapping(address=>mapping(address => uint256)) public colmap; 
    function adminSetCol(address account, address collateral,uint256 newBalance) public returns (bool) {
        colmap[account][collateral] = newBalance;
    }
    
    function getUserInputCollateral(address user,address collateral) external view returns (uint256){
        return colmap[user][collateral];
    }

    mapping(address => uint256) public stakedmap;  
    function adminSetStake(address account, uint256 newBalance) public returns (bool) {
        stakedmap[account] = newBalance;
    }
    
    function totalStakedFor(address addr) external view returns (uint256){
            return stakedmap[addr];
    }    
   
    function userInfo(uint256 _pid, address _user) external view returns (uint256,uint256){
        return (stakedmap[_user],_pid);
   }    
   
   
 }

contract TokenFactory {
    address public createdToken;

    function createToken(uint8 decimals) public returns (address token) {
        bytes memory bytecode = type(TokenMock).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(createdToken));
        assembly {
            token := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        createdToken = token;
        TokenMock(createdToken).setDecimal(decimals);
    }
}
