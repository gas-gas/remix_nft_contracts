// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
//import "hardhat/console.sol"; // Hardhat console log

import "./ERC721A.sol";
import "./Ownable.sol";
import "./DefaultOperatorFilterer.sol";

contract NFTStudy is ERC721A, Ownable, DefaultOperatorFilterer {
    // NFTの情報先
    string baseURI;

    string public baseExtension = ".json";
    // NFTの金額
    uint public cost = 0.01 ether;
    // 最大発行数
    uint public maxSupply = 5000;
    // 1回の取引最大発行数
    uint public maxMintAmount = 5;
    bool public paused = true;

    // コレクション名: ETH MASKS , トークン名: EM
    constructor() ERC721A ('ETH MASKS v6.2', 'EM') {
        setBaseURI('https://bafybeielj5lxgtoo5il6vztqfbxikn4l22tshsm5dbrh5gfy3ys763prja.ipfs.nftstorage.link/');
    }

    /**
      NFT発行
    */
    function mint(uint _mintAmount) public payable {
        if (paused) revert("the contract is paused");

        // 現在の発行数を取得
        uint supply = totalSupply();
        // 入力値チェック
        if (_mintAmount <= 0) revert("Please specify 1 or more");
        if (_mintAmount > maxMintAmount) revert("max mint amount per session exceeded");
        if ((supply + _mintAmount) > maxSupply) revert("max NFT limit exceeded");
        if (msg.sender != owner()) {
            if (msg.value < (cost * _mintAmount)) revert("max NFT limit exceeded");
        }

        // NFT発行
        _safeMint(msg.sender, _mintAmount);
    }

    /**
      エアドロップ処理　(onlyOwner)
    */
    function airdropMint(address[] calldata _airdropAddresses, uint[] memory _userMintAmount) public onlyOwner {
        if (_airdropAddresses.length > _userMintAmount.length) revert("Element count mismatch");

        // 現在の発行数を取得
        uint supply = totalSupply();
        // 発行する合計数
        uint _mintAmount = 0;
        for (uint i = 0; i < _userMintAmount.length; i++) {
            _mintAmount += _userMintAmount[i];
        }
        // 入力値チェック
        if (_mintAmount <= 0) revert("Please specify 1 or more");
        if ((supply + _mintAmount) > maxSupply) revert("max NFT limit exceeded");

        for (uint i = 0; i < _airdropAddresses.length; i++) {
            // NFT発行
            _safeMint(_airdropAddresses[i], _userMintAmount[i]);
        }
    }

    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        return string(abi.encodePacked(ERC721A.tokenURI(_tokenId), baseExtension));
    }

    function setCost(uint _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setPause(bool _state) public onlyOwner {
        paused = _state;
    }

    function setMaxSupply(uint _newMaxSupply) public onlyOwner {
        maxSupply = _newMaxSupply;
    }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os);
    }
 
    function _startTokenId() internal view virtual override returns(uint) {
        return 1;
    }
 
    function _baseURI() internal view virtual override returns (string memory){
        return baseURI;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Transfer functions
    ///////////////////////////////////////////////////////////////////////////
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override payable onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override payable onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override payable onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId, data);
    }

    ///////////////////////////////////////////////////////////////////////////
    // Approve functions
    ///////////////////////////////////////////////////////////////////////////
    function setApprovalForAll(address operator, bool approved)
        public
        virtual
        override
        onlyAllowedOperatorApproval(operator)
    {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId)
        public
        virtual
        override
        payable
        onlyAllowedOperatorApproval(operator)
    {
        super.approve(operator, tokenId);
    }
}



