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
        //Transaction[] transactions;
        mapping(uint256=>Transaction) transactions;
        Counters.Counter private _transactionIds;
        
        //mapping(address=>bool)  _sellers;
        //mapping(address=>bool)  _buyers;
        Transaction tr;
        Confirmation[] _buyers;
        Confirmation[] _sellers;
        Confirmation cs;
        
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
        Confirmation adminCertifier;
        bool approved;
        Confirmation[] sellers;
        Confirmation[] buyers;
    }
    
    struct Confirmation{
        address user;
        bool approved;
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
        //awardItem("test", )
    }
    
    
    
    function createTransactionEstate(address[] memory recipients, uint id) public{
        delete _buyers;
        delete _sellers;
        //Transaction memory t;
        Estate memory e = estates[id-1];
        //Confirmation[] memory _sellers;
        //_buyers = new Confirmation[](recipients.length);
        for(uint i = 0; i<e.owners.length; i++){
            /*Confirmation memory cs = Confirmation({
                user: e.owners[i],
                approved: false
            });*/
            //_sellers.push(cs);
            //_sellers[e.owners[i]] = false;
            cs.user = e.owners[i];
            cs.approved = false;
             _sellers[i] =cs;
        }
        for(uint i = 0; i<recipients.length; i++){
            //tr.buyers[recipients[i]] = false;
            //_buyers[recipients[i]] = false;
            Confirmation memory cb = Confirmation({
                user: recipients[i],
                approved: false
            });
            _buyers[i] =cb;
        }
        Confirmation memory c = Confirmation({
            user: address(0x0),
            approved: false
        });
        /*Transaction memory tr = Transaction({
            adminCertifier: c,
            sellers : _sellers,
            buyers : _buyers,
            approved : false
        });*/
        tr.adminCertifier = c;
        tr.sellers = _sellers;
        tr.buyers = _buyers;
        tr.approved = false;
        //transactions.push(tr);
        
        
        transactions[_transactionIds.current()] = tr;
        _transactionIds.increment();
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

    function awardItem(string memory hash, string memory metadata) private
        returns (uint256)
    {
        require(hashes[hash] != 1);
        hashes[hash] = 1;
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _mint(address(this), newItemId);
        _setTokenURI(newItemId, metadata);
        return newItemId;
    }
    
    function submitEstate(string memory addPostal, string memory area, string[] memory specifications, string[] memory worksDone, address[] memory actualOwners)
    public returns(string memory){
        //address[] memory owners = new address[](1);
        address[] memory oldOwners = new address[](0);
        //owners[0] = msg.sender;
        Estate memory e = Estate({
            id: estates.length + 1,
            addr: addPostal,
            area: area,
            specifications: specifications,
            oldOwners : oldOwners,
            owners: actualOwners,
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