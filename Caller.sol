pragma solidity ^0.4.16;

/**
 * @title Caller
 * @dev The Caller contract is a test usage of BulkyChunky library
 * @author pouladzade@gmail.com
 */
 
import "./BulkyChunky.sol";
import "./Callee.sol";
import "./BCSchema.sol";

contract Caller is BulkyChunky, BCSchema {
    
    Struct1 StructData;
    
    function getData() public view returns (uint16 ,address , uint8   , string  ){
        
        return(StructData.version, StructData.adrs, StructData.var1, StructData.str1);
    }
    
    function createBuffere() public {
         
        Callee callee = Callee(0xcca417069d356fcf870f4fe05b7d95bf700de960);
        
        callee.serialize();
        uint buffer_size = callee.getBufferSize();
        
        initializeBuffer(buffer_size);         
     }
     
    function fetchBulk() public  {
        
        require(Buffer.size > 0);
        
        Callee callee = Callee(0xcca417069d356fcf870f4fe05b7d95bf700de960);
        
        uint[BULK_CHUNK_SIZE] memory bulk = callee.getBulk(1);

        bytes memory buffer = Buffer.data;

        for(uint i = 1 ; i<= 8 && i <= Buffer.chunk_count; i++)
           uintToBytes(i * 32, bulk[i-1], buffer);
      
       Buffer.data = buffer;
    }
    
    function serialize()   public {
        
    }
    
    function deserialize() public {
        
        require(Buffer.size > 0);
        bytes memory buffer = Buffer.data;
        uint offset = Buffer.size;
       
        StructData.version = bytesToUint16(offset, buffer);
        offset -= sizeOfUint(16);
        
        StructData.adrs = bytesToAddress(offset, buffer);
        offset -= sizeOfAddress();
        
        StructData.var1 = bytesToUint8(offset, buffer);
        offset -= sizeOfInt(8); 
        
        string memory str1 = new string(getStringSize(offset, buffer));
        bytesToString(offset, buffer, bytes(str1));
        
        StructData.str1 = str1;
    }

}
