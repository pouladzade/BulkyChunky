# BulkyChunky
BulkyChunky is a library aims to facilitate transffering big amount of data between the Solidity smart contracts. It actually slices the data and put those slices in some bulks of chunks, it's why we call it BulkyChunky!!!



### How it works ?

Bulky Chunky actually uses the Seriality for serializing and deserializing. You just need implement three method in both side to get full advantage of BulkyChunky, even though for one-way communication you don't need to implement all these three method.

![ ](https://image.ibb.co/iWptA7/Bulky_Chunky.png  "BulkyChunky")

```js

    function serialize()   public;
    
    function deserialize() public; 
    
    function fetchBulk()   public;  
    
```   

Implementing Serialize and Deserialize method is pretty clear and I'm just  gonna explain the fetchBulk :

In fetchBulk you need call getBulk() method from other side and make the buffer base on the chanks which getBulk returns to you.

### Example :

```js

pragma solidity ^0.4.16;
 
contract BCSchema {
    
    struct DefinitionV1{
       uint16   version;
       
       address adrs;
       uint8   id;
       string  name;
       string  description;
       string  bytecode;
    } 
   
    struct DefinitionV2{
       uint16   version;
       
       address adrs;
       uint8   id;
       string  name;
       string  description;
       string  bytecode;
       string  ABI;
    }
}

```

```js

pragma solidity ^0.4.16;

import "./BulkyChunky.sol";
import "./BCSchema.sol";

contract Callee is BulkyChunky, BCSchema {

    DefinitionV1 Definition;
    
    function getData() public view returns (uint16 version,address adrs, uint8   id, string  name, string description, string bytecode){
        version = Definition.version;
        adrs    = Definition.adrs;
        id      = Definition.id;
        name    = Definition.name;
        bytecode= Definition.bytecode;
        description = Definition.description;
    }
     
  function serialize() public {
        
        Definition.version  = 1;
        Definition.adrs     = 0xcab77b4b9bf9b92a53572091c5798c570051be8f;
        Definition.id       = 123;
        Definition.name     = new string(32);
        Definition.bytecode = new string(128);
        Definition.description = new string(128);
        
        Definition.name  = "BulkyChunky";
        
        Definition.description = "BulkyChunky is a contract aims to facilitate transffering big amount of data between the Solidity smart contracts ";
        
        Definition.bytecode = "0x60606040526110cc806100136000396000f30060606040526004361061008e\
                                576000357c010000000000000000000000000000000000000000000000000000";
        
        
        
        Buffer.size = sizeOfString(Definition.bytecode) +
                      sizeOfString(Definition.description) +
                      sizeOfString(Definition.name) +
                      sizeOfUint(16) +
                      sizeOfInt(8) + 
                      sizeOfAddress();
                      
        if(Buffer.size % 32 > 0) 
            Buffer.size +=  (Buffer.size % 32);                     
                      
        bytes memory buffer = new bytes (Buffer.size);
        
        Buffer.chunk_count = Buffer.size / 32;
        
        if(Buffer.size % CHUNK_BYTES_SIZE > 0 ) {
            Buffer.chunk_count++;
        }
        
        // Serializing
        uint offset = Buffer.size;
        
        uintToBytes(offset,Definition.version, buffer);
        offset -= sizeOfUint(16);
        
        addressToBytes(offset,Definition.adrs, buffer);
        offset -= sizeOfAddress();
        
        uintToBytes(offset, Definition.id, buffer);
        offset -= sizeOfInt(8); 
        
        stringToBytes(offset,  bytes(Definition.name), buffer);
        offset -= sizeOfString(Definition.name);
        
        stringToBytes(offset,  bytes(Definition.description), buffer);
        offset -= sizeOfString(Definition.description);
        
        stringToBytes(offset,  bytes(Definition.bytecode), buffer);
        offset -= sizeOfString(Definition.bytecode);
        
        Buffer.data = buffer;
    } 

    
    function deserialize() public {
        
    }
    
    function fetchBulk()   public {
        
    }
}

```

```js

pragma solidity ^0.4.16;
 
import "./BulkyChunky.sol";
import "./Callee.sol";
import "./BCSchema.sol";

contract Caller is BulkyChunky, BCSchema {
    
    DefinitionV1 Definition;
    
    function getData() public view returns (uint16 ,address , uint8   , string, string, string ){
        
        return(Definition.version, Definition.adrs, Definition.id, Definition.name, Definition.description, Definition.bytecode);
    }
    
    function createBuffere() public {
         
        Callee callee = Callee(0x610033b6dd5a08004e46f2097ca09b693d744118);
        
        callee.serialize();
        uint buffer_size = callee.getBufferSize();
        
        initializeBuffer(buffer_size);         
     }
     
    function fetchBulk() public  {
        
        require(Buffer.size > 0);
        uint bulk_size = Buffer.size / BULK_BYTES_SIZE;
        if(Buffer.size % BULK_BYTES_SIZE > 0)
            bulk_size++;
        
        Callee callee = Callee(0x610033b6dd5a08004e46f2097ca09b693d744118);
        bytes memory buffer = Buffer.data;
        for(uint16 j=0 ; j < bulk_size ; j++){
            
            uint[BULK_CHUNK_SIZE] memory bulk = callee.getBulk(j+1);
    
            for(uint i = 1 ; i<= BULK_CHUNK_SIZE; i++)
               uintToBytes((i * 32) + (j * BULK_BYTES_SIZE), bulk[i-1], buffer);   
        }
      
       Buffer.data = buffer;
    }

    
    function deserialize() public {
        
        require(Buffer.size > 0);
        bytes memory buffer = Buffer.data;
        uint offset = Buffer.size;
        uint string_size;
        Definition.version = bytesToUint16(offset, buffer);
        offset -= sizeOfUint(16);
        
        Definition.adrs = bytesToAddress(offset, buffer);
        offset -= sizeOfAddress();
        
        Definition.id = bytesToUint8(offset, buffer);
        offset -= sizeOfInt(8); 
        
        string_size = getStringSize(offset, buffer);
        string memory name = new string(string_size);
        bytesToString(offset, buffer, bytes(name));
        offset -= sizeOfString(name);
        
        string_size = getStringSize(offset, buffer);
        string memory description = new string(string_size);
        bytesToString(offset, buffer, bytes(description));
        offset -= sizeOfString(description);
        
        string_size = getStringSize(offset, buffer);
        string memory bytecode = new string(string_size);
        bytesToString(offset, buffer, bytes(bytecode));
        offset -= sizeOfString(bytecode);
        
        Definition.name = name;
        Definition.description = description;
        Definition.bytecode = bytecode;
    }
    
  function serialize() public {
      
  }
}

```

Output buffer:

```
0000000000000000000000000000000000000000000000303030303030303030
3030303030303030303030303030303030303030303030353736303030333537
6330313030303030303030303030303030303030303030202020202020202020
2020202020202020202020202020202020202020202020363030306633303036
3036303630343035323630303433363130363130303865307836303630363034
3035323631313063633830363130303133363030303339000000000000000000
00000000000000000000000000000000000000000000a07920736d6172742063
6f6e7472616374732000000000000000000000000000006f756e74206f662064
617461206265747765656e2074686520536f6c696469746f20666163696c6974
617465207472616e7366666572696e672062696720616d42756c6b794368756e
6b79206973206120636f6e74726163742061696d732074000000000000000000
000000000000000000000000000000000000000000007242756c6b794368756e
6b79000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000b7bcab77b4b9bf9b92a
53572091c5798c570051be8f0001

```

![](https://preview.ibb.co/ifrZ07/output.png) 



   
   
   
    
