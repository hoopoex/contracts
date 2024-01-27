// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

import "../libraries/LibMerkleProof.sol";

error InvalidMinter();
error InvalidAction();
error AlreadyClaimed();

contract HOOPNFT is ERC1155, Ownable, ERC1155Burnable, ERC1155Supply {

    uint256 public constant Tortullix=1e18;
    uint256 public constant Woolvenia=2e18;
    uint256 public constant Bouncebyte=3e18;
    uint256 public constant Stagora=4e18;
    uint256 public constant Honeyheart=5e18;
    uint256 public constant PiggyPrime=6e18;
    uint256 public constant HoopX=7e18;
    uint256 public constant PrimeBull=8e18;
    uint256 public constant Wolvenix=9e18;
    uint256 public constant Whalesong=10e18;

    struct TMembership {
        uint256 price;
        uint256 multiplier;
        uint256 tokenId;
        string name;
    }

    struct TMinterInfo {
        bool canMint;
    }

    uint256 private pricePerMint;

    string private _name;
    string private _symbol;

    address private royaltiesReceiver;
    bytes32 merkleRoot;

    mapping(uint256 => TMembership) private cardTypes;
    mapping(address => TMinterInfo) private minters;
    mapping(bytes32 => bool) private isClaimed;

    constructor() Ownable(msg.sender) ERC1155("ipfs://QmS8SQTt24Eqpkns6zFiPuW2W1KSN6E4gjHeUjgwDNb2BQ/{id}") {
        _name = "HOOPOE Membership NFT";
        _symbol = "HOOPOE";

        cardTypes[Tortullix] = TMembership({
            price:1 ether,
            multiplier:1,
            tokenId:Tortullix,
            name:"Tortullix"
        });

        cardTypes[Woolvenia] = TMembership({
            price:2 ether,
            multiplier:2,
            tokenId:Woolvenia,
            name:"Woolvenia"
        });

        cardTypes[Bouncebyte] = TMembership({
            price:3 ether,
            multiplier:3,
            tokenId:Bouncebyte,
            name:"Bouncebyte"
        });

        cardTypes[Stagora] = TMembership({
            price:4 ether,
            multiplier:4,
            tokenId:Stagora,
            name:"Stagora"
        });

        cardTypes[Honeyheart] = TMembership({
            price:5 ether,
            multiplier:5,
            tokenId:Honeyheart,
            name:"Honeyheart"
        });

        cardTypes[PiggyPrime] = TMembership({
            price:6 ether,
            multiplier:7,
            tokenId:PiggyPrime,
            name:"PiggyPrime"
        });

        cardTypes[HoopX] = TMembership({
            price:8 ether,
            multiplier:10,
            tokenId:HoopX,
            name:"HoopX"
        });

        cardTypes[PrimeBull] = TMembership({
            price:15 ether,
            multiplier:25,
            tokenId:PrimeBull,
            name:"PrimeBull"
        });

    
        cardTypes[Wolvenix] = TMembership({
            price:25 ether,
            multiplier:50,
            tokenId:Wolvenix,
            name:"Wolvenix"
        });

        cardTypes[Whalesong] = TMembership({
            price:40 ether,
            multiplier:100,
            tokenId:Whalesong,
            name:"Whalesong"
        });

        minters[msg.sender].canMint = true;
        royaltiesReceiver = msg.sender;
        pricePerMint = 0.0012 ether;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function updatePrice(uint256 _tokenId, uint256 _price) public onlyMinters(msg.sender){
        cardTypes[_tokenId].price = _price;
    }

    function updateMultiplier(uint256 _tokenId, uint256 _multiplier) public onlyMinters(msg.sender){
        cardTypes[_tokenId].multiplier = _multiplier;
    }

    function updateRoyaltiesReceiver(address _receiver) public onlyOwner{
        royaltiesReceiver = _receiver;
    }

    function addMinter(address _minter,bool _canMint) public onlyOwner{
        minters[_minter].canMint = _canMint;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner{
        merkleRoot = _merkleRoot;
    }

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    function getRoyaltiesReceiver() public view returns(address){
        return royaltiesReceiver;
    }

    function getTokenInfo(uint256 _tokenId) public view returns(TMembership memory){
        return cardTypes[_tokenId];
    }

    function getAllTokens() public view returns(TMembership[] memory){
        TMembership[] memory tokens = new TMembership[](10);
        for(uint256 i = 0; i < 10; i++) {
            uint256 tokenId = (i+1) * 1e18;
            tokens[i] = cardTypes[tokenId];
        }
        return tokens;
    }


    function royaltyInfo(uint256 tokenId, uint256 _salePrice) external view returns (address, uint256){
        uint256 royaltiesAmount = (_salePrice * 750) / 10000;
        return (royaltiesReceiver, royaltiesAmount);
    }

    modifier onlyMinters(address user) {
        if(!minters[user].canMint){
            revert InvalidMinter();
        }
        _;
    }

    function getClaimFee() public view returns(uint256){
        return pricePerMint;
    }
    function updatePricePerAction(uint256 _price) public onlyOwner{
        pricePerMint = _price;
    }

    function distribute(address _address, uint256 _nodeIndex, uint256 _tokenId, bytes32[] calldata _merkleProof) public payable{
        if(msg.value != pricePerMint){
            revert InvalidAction();
        }
        bytes32 node = keccak256(abi.encodePacked(_nodeIndex, _address, _tokenId));
        require(LibMerkleProof.verify(_merkleProof, merkleRoot, node), "Invalid proof.");
        if(isClaimed[node]){
            revert AlreadyClaimed();
        }

        if(msg.sender != _address){
            revert InvalidAction();
        }
        isClaimed[node] = true;
        _mint(_address, (_tokenId * 1e18), 1, "");
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyMinters(msg.sender){
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public   onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }


    function withdrawEarnings(address user) external onlyOwner{
        uint256 amount = address(this).balance;
        if(amount > 0){
            address to = user;
            (bool success, ) = to.call{value: amount}(new bytes(0));
            require(success);
        }
    }

}