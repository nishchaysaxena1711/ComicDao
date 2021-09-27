// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Comic is Ownable, ERC20 {

    event ComicMint(address to, uint amount);
    event ComicBurn(address from, uint amount);

    string constant TOKEN_NAME = 'Comic';
    string constant TOKEN_SYMBOL = 'COM';

    constructor(address _owner) ERC20(TOKEN_NAME, TOKEN_SYMBOL) {
        require(_owner != address(0), 'Invalid Address');
        transferOwnership(_owner);
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        super._mint(_to, _amount);
        emit ComicMint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyOwner {
        super._burn(_from, _amount);
        emit ComicBurn(_from, _amount);
    }
}