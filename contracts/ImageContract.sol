// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../openzeppelin/token/ERC721/extensions/ERC721Full.sol";
import "../openzeppelin/token/ERC721/extensions/IERC721Metadata.sol";

contract ImageContract is IERC721Metadata, ERC721Full{

address admin;  
uint TokenID = 0;

struct metadata {
string Artwork_name;
string Artwork_type;
address Author;//changed

string Artwork_description;
string Artwork_url_image;
uint Artwork_price;
uint Auction_Length;
uint Royalty;


}

 struct Vendor{
    uint nftCount; 
    uint withdrawnBalance;
    uint userWeiBalance;
 
    }
 mapping (address => Vendor) Vendors;   
 enum TokenState {Sold, Available}
 struct NFT {
        uint256 price;
        uint256 _tokenId;
        string  tokenURL;
        TokenState tokenState;
        uint bidcount;
         bool doesExist;
        
    }
    
string[] public images;
mapping(uint => metadata) public imageData;
mapping(string => bool) _imageExists;

mapping(uint => bool) _listedForAuction;
mapping(uint => bool) _listedForSale;
mapping(uint => address) _tokenToOwner;
mapping (uint => NFT) NFTs;
struct auctionData {
uint Artwork_price;
uint time;
}

mapping(uint => auctionData) tokenAuction;

event BoughtNFT(uint256 _tokenId, address _buyer, uint256 _price);


 NFT[] allNFT;
     
constructor() ERC721("Unpainted_NFT", "NFT Mint") { admin = payable( msg.sender);}

 
function mintFixedPrice(string memory _Artwork_name, string memory _Artwork_type, string memory _Artwork_description, string memory _Artwork_url_image, uint _Artwork_price,uint _Royalty) public returns (uint){
require(!_imageExists[_Artwork_url_image]);
metadata memory md;
md.Artwork_name = _Artwork_name;
md.Artwork_type = _Artwork_type;

md.Artwork_description = _Artwork_description;
md.Artwork_url_image = _Artwork_url_image;
md.Artwork_price = _Artwork_price;
//md.Auction_Length = _Auction_Length;
md.Royalty= _Royalty;
images.push(_Artwork_url_image);
TokenID =  TokenID  +1;
md.Author = msg.sender;

imageData[ TokenID ] = md;
_mint(msg.sender,TokenID);
_tokenToOwner[TokenID] = msg.sender;
_imageExists[_Artwork_url_image] = true;

return  TokenID;
}

function mintAuctionLength(string memory _Artwork_name, string memory _Artwork_type, string memory _Artwork_description, string memory _Artwork_url_image, uint _Artwork_price, uint _Auction_Length,uint _Royalty) public returns (string memory,uint,uint){
require(!_imageExists[_Artwork_url_image]);
metadata memory md;
md.Artwork_name = _Artwork_name;
md.Artwork_type = _Artwork_type;
md.Artwork_description = _Artwork_description;
md.Artwork_url_image = _Artwork_url_image;
md.Artwork_price = _Artwork_price;
md.Auction_Length = _Auction_Length;
md.Royalty= _Royalty;
images.push(_Artwork_url_image);
 TokenID  =  TokenID +1;
md.Author = msg.sender;

imageData[ TokenID ] = md;
_mint(msg.sender,TokenID);
_tokenToOwner[TokenID] = msg.sender;
_imageExists[_Artwork_url_image] = true;

uint VendorNumberofNFT =  Vendors[msg.sender].nftCount++; 
       NFT memory allNFTs = NFT(_Artwork_price,TokenID,_Artwork_url_image, TokenState.Available, 0,true);
       NFTs[TokenID] = NFT(_Artwork_price, TokenID,_Artwork_url_image, TokenState.Available,0,true);
       allNFT.push(allNFTs);
       return (' Auction NFT MINT sucessfully',TokenID, VendorNumberofNFT);

}

 
function nftSold(uint _tokenId) public {
    _listedForSale[_tokenId] = false;
    _listedForAuction[_tokenId] = false;
  }
  
  function buyImage(address _owner, uint256 _tokenId, uint256 _price) public payable returns(string memory,uint256) {
        require(msg.sender != admin,'Token owner cannot buy');
        _price = imageData[_tokenId].Artwork_price;
        if(_owner==imageData[_tokenId].Author){
            require(msg.value==_price, "You need to send the correct amount.");
            transferFrom(_owner, msg.sender, _tokenId);
            nftSold(_tokenId);
            emit BoughtNFT(_tokenId, msg.sender, _price);
            payable(_owner).transfer(msg.value); 
            _tokenToOwner[_tokenId] = msg.sender;
            return('You have sucessfully Buy this NFT',_tokenId);
        }
        else{
            uint256 royalty = _price*imageData[_tokenId].Royalty/100;
            require(msg.value==_price+royalty, "You need to send the correct amount.");
            transferFrom(_owner, msg.sender, _tokenId);
            nftSold(_tokenId);
            emit BoughtNFT(_tokenId, msg.sender, _price);
            payable(_owner).transfer(_price); 
            payable(imageData[_tokenId].Author).transfer(royalty); 
            _tokenToOwner[_tokenId] = msg.sender;
            return('You have sucessfully Buy this NFT',_tokenId);
        }
        
    }

}



   


//import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';

contract NFtMarket  is ImageContract {
    
   // address payable admin;
   //  enum TokenState {Sold, Available}
     
   
  //    mapping (uint => NFT) NFTs;
      mapping(address => mapping(uint => bool)) hasBibedFor;
      mapping (address => uint) bidPrice;
      mapping (uint => mapping (address => bider)) biderToId;
      mapping (uint => uint) BidAmountToTokenId;
 //     mapping (address => Vendor) Vendors;
      
       
    
    
  /*  constructor () ERC721('OlaNFT', 'OLANFT')  {
        admin = payable( msg.sender); 
    }
    */
   // uint TokenID = 0;
    uint bidcount = 0;
    uint BidAmount = 0;
    
    uint HighestBiderPrice = 0;
    address public HighestBiderAddress ;
    
   
  /*   
    struct Vendor{
    uint nftCount; 
    uint withdrawnBalance;
    uint userWeiBalance;
 
    }
    
    struct NFT {
        uint256 price;
        uint256 _tokenId;
        string  tokenURL;
        TokenState tokenState;
        uint bidcount;
         bool doesExist;
        
    }
    
    */
    
    struct bider {
        address biderAdress;
        uint bidPrice;
        bool canPay;
    }
    

     
//  NFT[] allNFT;
 
    function bid (uint _tokenId, uint _bidAmount) public returns (string memory, uint, uint) {
       require(msg.sender != admin,'Token Owner cannot bid');
       require(NFTs[_tokenId].doesExist == true, 'Token id does not exist'); 
       require (hasBibedFor[msg.sender][_tokenId] == false, 'you cannot bid for an Nft twice');
       require (BidAmountToTokenId[_tokenId] < _bidAmount, 'this Nft already has an higher or equal bider');
       require (NFTs[_tokenId].price <= _bidAmount, 'You cannot bid below the startingPrice');
       uint TotalBid = NFTs[_tokenId].bidcount++;
      
        bidPrice[msg.sender] = _bidAmount;
        uint bidAmount = bidPrice[msg.sender];
         hasBibedFor[msg.sender][_tokenId]= true;
        biderToId[_tokenId][msg.sender]= bider(msg.sender,_bidAmount, true);
        if (BidAmountToTokenId[_tokenId] < _bidAmount ){
            BidAmountToTokenId[_tokenId] = _bidAmount;
        }
        return('You have sucessfully bided for this NFT', bidAmount, TotalBid);
        
    }
    
    function CheckhighestBidDEtails (uint _id) public  returns(uint, address) {
    require(NFTs[_id].doesExist == true, 'Token id does not exist');
        HighestBiderPrice = BidAmountToTokenId[_id];
        if ( biderToId[_id][msg.sender].bidPrice == HighestBiderPrice){
            HighestBiderAddress = biderToId[_id][msg.sender].biderAdress;
        }
        else{
        
         return(HighestBiderPrice,HighestBiderAddress);

        }
        
        
       return(HighestBiderPrice,HighestBiderAddress);
       
    }
    
    
    function PayForNFT (uint _tokenId) public payable returns(string memory)  {
       require(NFTs[_tokenId].doesExist == true, 'Token id does not exist');
      // require(msg.value == _amount, "DepositEther:Amount sent does not equal amount entered");
       require (msg.sender == HighestBiderAddress, 'only highest bidder can pay' );
      // require (msg.value == HighestBiderPrice, 'amount is less than higest bid price');
     //   Vendors[msg.sender].userWeiBalance += _amount;
     if(ownerOf(_tokenId)==imageData[_tokenId].Author){
        address nftOwner = ownerOf(_tokenId);
        console.log("nftOwner",nftOwner);
        address buyer = msg.sender; 
         console.log("buyer",buyer);
        transferFrom(nftOwner, buyer, _tokenId);
        nftSold(_tokenId);
        emit BoughtNFT(_tokenId, buyer, HighestBiderPrice);

        require(msg.value==HighestBiderPrice, "You need to send the correct amount.");

        payable(nftOwner).transfer(msg.value); 
         _tokenToOwner[_tokenId] = msg.sender;

        return('Bid NFT Buy sucessfully ');
        //safeTransferFrom(nftOwner, buyer, _tokenId);
        // payable(address(this)).transfer(msg.value); 
      //    uint VendorNumberofNFT =  Vendors[msg.sender].nftCount--; 
     //   return(VendorNumberofNFT);
     }
     else{
        address nftOwner = ownerOf(_tokenId);
        console.log("nftOwner",nftOwner);
        address buyer = msg.sender; 
         console.log("buyer",buyer);
        transferFrom(nftOwner, buyer, _tokenId);
        nftSold(_tokenId);
        emit BoughtNFT(_tokenId, buyer, HighestBiderPrice);
        uint256 royalty = HighestBiderPrice*imageData[_tokenId].Royalty/100;
        require(msg.value==HighestBiderPrice+royalty, "You need to send the correct amount.");

        payable(nftOwner).transfer(HighestBiderPrice); 
        payable(imageData[_tokenId].Author).transfer(royalty);
        _tokenToOwner[_tokenId] = msg.sender;

        return('Bid NFT Buy sucessfully ');
        //safeTransferFrom(nftOwner, buyer, _tokenId);
        // payable(address(this)).transfer(msg.value); 
      //    uint VendorNumberofNFT =  Vendors[msg.sender].nftCount--; 
     //   return(VendorNumberofNFT);
         
     }
    }
    
       function contractEtherBalance() public view returns(uint256){
        return address(this).balance;
    }

     
 function getBalance() public view returns(uint){
     return address(this).balance;
 }
 
    function resellNFT(uint256 _token, uint256 _newPrice, string memory _newName,string memory _Artwork_type)public returns(string memory,uint) {//changed
        address _owner = _tokenToOwner[_token];
        require(msg.sender==_owner, "You are not the owner so you cannot resell this.");
        // NFTs[_token]=NFT(_newPrice, nft._tokenId,nft.tokenURL, nft.tokenState, nft.bidcount,  nft.doesExist );
        _listedForSale[_token] = true;
        NFTs[_token].price = _newPrice;
        imageData[_token].Artwork_price=_newPrice;
        imageData[_token].Artwork_name = _newName;
        imageData[_token].Artwork_type = _Artwork_type;

        console.log("Test Owner",_owner);
        return('Resell Fixed Price NFT  sucessfully ',_token);
    }


function resellAuctionNFT(uint256 _token, string memory _newName,string memory _Artwork_type,  uint256 _newPrice, uint _Auction_Length)public returns(string memory,uint) {//changed
        address _owner = _tokenToOwner[_token];
        require(msg.sender==_owner, "You are not the owner so you cannot resell this.");
        // NFTs[_token]=NFT(_newPrice, nft._tokenId,nft.tokenURL, nft.tokenState, nft.bidcount,  nft.doesExist );
        _listedForSale[_token] = true;
        NFTs[_token].price = _newPrice;
        imageData[_token].Artwork_price=_newPrice;
        imageData[_token].Artwork_name = _newName;
        imageData[_token].Artwork_type = _Artwork_type;
        imageData[_token].Auction_Length = _Auction_Length;


        console.log("Test Owner",_owner);
        return('Resell Auction Length Price NFT  sucessfully ',_token);
    }


function getFixedRoyalty(uint256 _token) view public returns(uint256) {
        return (imageData[_token].Artwork_price*imageData[_token].Royalty)/100;
    }
    function getAuctionRoyalty(uint256 _token, uint256 _highestBidPrice) view public returns(uint256) {
        return (_highestBidPrice*imageData[_token].Royalty)/100;
    }
    
}


   


