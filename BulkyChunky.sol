pragma solidity ^0.4.16;

/**
 * @title BulkyChunky
 * @dev The BulkyChunky contract provides enough services for transferring huge amount of data between contracts using
 * Seriality library
 * @author pouladzade@gmail.com
 */
 
import "./Seriality.sol";

contract BulkyChunky is Seriality {
    
   struct MetaBuffer {
        bytes data;
        uint size;
        uint chunk_count;
    }
        
    MetaBuffer Buffer;
    
    uint16 constant BULK_BYTES_SIZE  = 256;
    uint16 constant CHUNK_BYTES_SIZE = 32;
    uint16 constant BULK_CHUNK_SIZE  = 8 ;
    
    function serialize()   public;
    
    function deserialize() public;
    
    function fetchBulk()   public;
    
    function getBufferData() public view returns(bytes memory){
        return Buffer.data;
    }
    
    function getBufferSize() public view returns(uint) {
            return Buffer.size;
    }
    
    function getBufferChunkCount() public view returns(uint) {
            return Buffer.chunk_count;
    }
      
    function initializeBuffer(uint buffer_size)  internal {
        
        Buffer.size = buffer_size;
        Buffer.chunk_count = Buffer.size / CHUNK_BYTES_SIZE;
        
        if(Buffer.size % CHUNK_BYTES_SIZE > 0)  Buffer.chunk_count++;
        
        bytes memory buffer = new bytes(Buffer.size);
        
        Buffer.data = buffer;
    }  
    
    function getBulk(uint16 bulk_no) public view returns(uint[BULK_CHUNK_SIZE] bulk) {
        
        bytes memory buffer = Buffer.data;
        
        for(uint i = 1 ; i <= BULK_CHUNK_SIZE && i <= Buffer.chunk_count  ; i++)
            bulk[i-1] = bytesToUint256((i * CHUNK_BYTES_SIZE) + ((bulk_no - 1) * BULK_BYTES_SIZE) , buffer);
    }

}