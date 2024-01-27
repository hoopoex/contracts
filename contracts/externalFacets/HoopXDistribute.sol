// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import "../libraries/LibMerkleProof.sol";

error InvalidMinter();
error InvalidAction();
error AlreadyClaimed();

contract HoopDistribute is Ownable, ReentrancyGuard {

    bytes32 merkleRoot;
    uint256 private pricePerMint;
    mapping(bytes32 => bool) private isClaimed;
    IERC20 public hoopToken;

    constructor(
        address _initialOwner,
        address _hoopToken
    ) Ownable(_initialOwner) {
        hoopToken = IERC20(_hoopToken);
        pricePerMint = 0.004 ether;
    }

    function distribute(
        address _address, 
        uint256 _nodeIndex, 
        uint256 _amount, 
        bytes32[] calldata _merkleProof
    ) 
        public 
        payable 
        nonReentrant 
    {
        if(msg.value != pricePerMint){
            revert InvalidAction();
        }
        bytes32 node = keccak256(abi.encodePacked(_nodeIndex, _address, _amount));
        require(LibMerkleProof.verify(_merkleProof, merkleRoot, node), "Invalid proof.");

        if(isClaimed[node]){
            revert AlreadyClaimed();
        }

        if(msg.sender != _address){
            revert InvalidAction();
        }
        isClaimed[node] = true;
        hoopToken.transfer(_address,_amount);
    }

    function setPricePerTransfer(
        uint256 _amount
    )
        public 
        onlyOwner 
    {
        pricePerMint = _amount;
    }

    function setMerkleRoot(
        bytes32 _merkleRoot
    ) 
        public 
        onlyOwner 
    {
        merkleRoot = _merkleRoot;
    }

    function withdrawEarnings(
        address _address
    ) 
        external 
        onlyOwner 
    {
        uint256 amount = address(this).balance;
        if(amount > 0){
            address to = _address;
            (bool success, ) = to.call{value: amount}(new bytes(0));
            require(success);
        }
    }

    function withdrawTokens(
        address _address
    )
        public 
        onlyOwner 
    {
        uint256 balance = hoopToken.balanceOf(address(this));
        hoopToken.transfer(_address,balance);
    }

    function getClaimFee(
    ) 
        public 
        view 
        returns(uint256)
    {
        return pricePerMint;
    }

    receive() external payable {}

}