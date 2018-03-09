pragma solidity ^0.4.16;

/**
 * @title Callee
 * @dev The Callee contract is a test usage of BulkyChunky library
 * @author pouladzade@gmail.com
 */
 
import "./BulkyChunky.sol";
import "./BCSchema.sol";

contract Callee is BulkyChunky, BCSchema {

    Struct1 StructData;
    
    function getData() public view returns (uint16 version,address adrs, uint8   var1, string  str1){
        version = StructData.version;
        adrs    = StructData.adrs;
        var1    = StructData.var1;
        str1    = StructData.str1;
    }
     
    function serialize() public {
        
        StructData.version = 1;
        StructData.adrs  = 0xcab77b4b9bf9b92a53572091c5798c570051be8f;
        StructData.var1  = 123;
        StructData.str1  = new string(32);
        
        StructData.str1  = "Hello from BulkyChunky!!!";
        
        Buffer.size = 128;
        bytes memory buffer = new bytes (Buffer.size);
        
        Buffer.chunk_count = Buffer.size / 32;
        
        if(Buffer.size % CHUNK_BYTES_SIZE > 0 ) {
            Buffer.chunk_count++;
        }
        
        // Serializing
        uint offset = Buffer.size;
        
        uintToBytes(offset,StructData.version, buffer);
        offset -= sizeOfUint(16);
        
        addressToBytes(offset,StructData.adrs, buffer);
        offset -= sizeOfAddress();
        
        uintToBytes(offset, StructData.var1, buffer);
        offset -= sizeOfInt(8); 
        
        stringToBytes(offset,  bytes(StructData.str1), buffer);
        
        Buffer.data = buffer;
    } 
    
    function deserialize() public {
        
    }
    
    function fetchBulk()   public {
        
    }
}