pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract REToken is ERC721{
    using Counters for Counters.Counter;
        Counters.Counter private _tokenIds;
        mapping(string => uint8) hashes;
        mapping(uint256 => string) private _tokenURIs;
        mapping (address => bool) isAdmin;
        mapping(bytes32 => Estate) estateList;
        Estate[] estates;
        Transaction[] transactions;
        Counters.Counter private _transactionIds;
        
        mapping(address=>bool)  _sellers;
        mapping(address=>bool)  _buyers;
        Transaction tr;
        
        
    struct Estate{
        uint id;
        string addr;
        string area;
        string[] specifications;
        address[] oldOwners;
        address[] owners;
        string[] worksDone;
        bool approved;
    }
    
    struct Transaction{
        address adminCertifier;
        bool approvedByAdmin;
        mapping(address => bool) sellers;
        mapping(address => bool) buyers;
    }
    
        
    constructor() ERC721("RealEstateToken", "RET") public {
        isAdmin[msg.sender] = true;
        
    }
    
    function seeEstates() public view returns(Estate[] memory){
        return estates;
    }
    
    function approveEstate(uint index) public{
        require(isAdmin[msg.sender]);
        Estate memory newEstate = estates[index-1];
        newEstate.approved = true;
        estates[index-1] = newEstate;
    }
    
    
    
    function createTransactionEstate(address[] memory recipients, uint id) public{
        
        //Transaction memory t;
        Estate memory e = estates[id-1];
        for(uint i = 0; i<e.owners.length; i++){
            //t.sellers[e.owners[i]] = false;
            _sellers[e.owners[i]] = false;
        }
        for(uint i = 0; i<recipients.length; i++){
            //t.buyers[recipients] = false;
            _buyers[recipients[i]] = false;
        }
        tr = Transaction({
            sellers : _sellers,
            buyers : _buyers,
            approvedByAdmin : false
        });
        transactions.push(tr);
    }
    
    //TODO
    function seeEstateById(uint index) public view returns(string memory){
        return string(abi.encodePacked("id: ", index, " address: ", estates[index-1].addr, " approved : ", estates[index-1].approved)); 
    }
    
    function addAdmin(address adminToAdd) public{
        require(isAdmin[msg.sender]);
        require(!isAdmin[adminToAdd]);
        isAdmin[adminToAdd] = true;
    }
    
    function revokeAdmin(address adminToRevoke) public{
        require(isAdmin[msg.sender]);
        require(!isAdmin[adminToRevoke]);
        isAdmin[adminToRevoke] = false;
    }
    
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
            require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
            _tokenURIs[tokenId] = _tokenURI;
        }

    function awardItem(address recipient, string memory hash, string memory metadata) private
        returns (uint256)
    {
        require(hashes[hash] != 1);
        hashes[hash] = 1;
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(this, newItemId);
        _setTokenURI(newItemId, metadata);
        return newItemId;
    }
    
    function submitEstate(string memory addPostal, string memory area, string[] memory specifications, string[] memory worksDone, address[] memory actuelOwners)
    public returns(string memory){
        //address[] memory owners = new address[](1);
        //owners[0] = msg.sender;
        Estate memory e = Estate({
            id: estates.length + 1,
            addr: addPostal,
            area: area,
            specifications: specifications,
            oldOwners : address[],
            actuelOwners: actuelOwners,
            worksDone : worksDone,
            approved : false
        });
        bytes32 hash = keccak256(abi.encode(e.id,e.addr));
        require(estateList[hash].id == 0);
        estateList[hash] = e;
        estates.push(e);
        return "ok";
    }
}