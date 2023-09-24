// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply);
    }
}

contract DecentralizedExchange {
    address public owner;

    struct CreatedToken {
        address tokenAddress;
        string name;
        string symbol;
        uint256 initialSupply;
    }

    CreatedToken[] public createdTokens;

    mapping(address => mapping(address => uint256)) public tokenPrices;

    constructor() {
        owner = msg.sender;
    }

    function createMockToken(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) public {
        require(msg.sender == owner, "Only owner can create mock tokens");

        MockToken mockToken = new MockToken(_name, _symbol, _initialSupply);

        createdTokens.push(
            CreatedToken(address(mockToken), _name, _symbol, _initialSupply)
        );
    }

    function getCreatedTokens() public view returns (CreatedToken[] memory) {
        return createdTokens;
    }

    mapping(address => mapping(address => uint256)) public userBalances;

    function depositTokens(address _token, uint256 _amount) public payable {
        require(_amount > 0, "Amount must be greater than 0");
        require(tokenExists(_token), "Token does not exist");

        userBalances[msg.sender][_token] += _amount;
    }

    function getUserTokenBalance(
        address _user,
        address _token
    ) public view returns (uint256) {
        return userBalances[_user][_token];
    }

    function setTokenPrice(
        address _token1,
        address _token2,
        uint256 _price
    ) public {
        require(msg.sender == owner, "Only owner can set token prices");
        tokenPrices[_token1][_token2] = _price;
    }

    function getTokenPrice(
        address _token1,
        address _token2
    ) public view returns (uint256) {
        require(tokenPrices[_token1][_token2] > 0, "Token pair price not set");
        return tokenPrices[_token1][_token2];
    }

    function tokenExists(address _token) internal view returns (bool) {
        for (uint256 i = 0; i < createdTokens.length; i++) {
            if (createdTokens[i].tokenAddress == _token) {
                return true;
            }
        }
        return false;
    }

    function swapTokens(
        address _token1,
        address _token2,
        uint256 _amount
    ) public {
        require(_amount > 0, "Amount must be greater than 0");
        require(
            tokenExists(_token1) && tokenExists(_token2),
            "Token does not exist"
        );

        uint256 requiredToken2 = (_amount * getTokenPrice(_token1, _token2)) /
            1 ether;
        require(
            userBalances[msg.sender][_token2] >= requiredToken2,
            "Insufficient balance of _token2"
        );

        userBalances[msg.sender][_token1] += _amount;
        userBalances[msg.sender][_token2] -= requiredToken2;

        userBalances[msg.sender][_token2] += requiredToken2;
        userBalances[msg.sender][_token1] -= _amount;
    }
}
