pragma solidity ^0.4.16;

/**
 * @title BCSchemaBCSchema
 * @dev The BCSchema just as a test schema
 * @author pouladzade@gmail.com
 */
 
contract BCSchema {
    
    struct Struct1{
       uint16   version;
       
       address adrs;
       uint8   var1;
       string  str1;
    } 
   
    struct Struct2{
       
       uint16   version;
       
       address adrs;
       string  str1;
       string  str2;
       string  str3;
    } 
}