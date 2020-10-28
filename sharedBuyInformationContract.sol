pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

contract sharedBuyInformationContract {
    
    struct CreditCard {
        string Number;
        string ExpiresDate;
        string Ccv;
        string OwnerName;
    }
    
    struct Person {
        string Email;
        string FullName;
        string BirthDate;
        string Sex;
        string Phone;
        string Password;
        mapping (string => CreditCard) Cards;
        bool exists;
    }
    
    mapping (string => Person) Persons;
    
    function GetContractData(string memory DocumentNumber) public view returns(string memory) {
        Person memory _person = Persons[DocumentNumber];
        string memory _email = _person.Email;
        string memory _fullName = _person.FullName;
        string memory _sex = _person.Sex;
        string memory _phone = _person.Phone;
        string memory _birthdate = _person.BirthDate;

        return string(abi.encodePacked(_email, "-" ,_fullName,"-" , DocumentNumber,"-" , _sex,"-" , _phone,"-" , _birthdate ));
    }
    
    function AddNewCard(string memory DocumentNumber,string memory number, string memory expiresDate, string memory ccv, string memory ownerName ) public  {
        CreditCard memory creditCard;
        
        creditCard.Number = number;
        creditCard.Ccv = ccv; 
        creditCard.ExpiresDate = expiresDate;
        creditCard.OwnerName = ownerName;
        
        Persons[DocumentNumber].Cards[creditCard.Number] = creditCard;
    }
    
    
    function GetCardByNumber(string memory DocumentNumber, string memory CardNumber) public view returns(string[4] memory) {
        return [Persons[DocumentNumber].Cards[CardNumber].Number, Persons[DocumentNumber].Cards[CardNumber].Ccv,
        Persons[DocumentNumber].Cards[CardNumber].ExpiresDate, Persons[DocumentNumber].Cards[CardNumber].OwnerName];
    }
    
    function LoginWithPlugin (string memory DocumentNumber, string memory Password) public view returns (bool){
        string memory _password = Persons[DocumentNumber].Password;
        string memory _hashedFormPassword = Bytes32ToString(HashPassword(Password));
        if(keccak256(abi.encodePacked((_password))) == keccak256(abi.encodePacked((_hashedFormPassword)))) {
            return true;
        }
        return false;
    }
    
    function RegisterNewUser (string memory DocumentNumber, string memory Email, 
        string memory FullName, string memory BirthDate, 
        string memory Sex, string memory Phone, string memory Password
    ) public
    {
        Person memory _person;
        _person.Email = Email;
        _person.FullName = FullName;
        _person.Sex = Sex;
        _person.Phone = Phone;
        _person.BirthDate = BirthDate;
        
        if(!Persons[DocumentNumber].exists) {
            _person.Password = Bytes32ToString(HashPassword(Password));
            Persons[DocumentNumber] = _person;
        }
    }
    
    function Bytes32ToString(bytes32 _bytes32) private pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    
    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
    
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function HashPassword(string memory senha) private pure returns(bytes32) {
        return sha256(abi.encode(senha));
    }
    
    function DecodePassword(string memory hash) private pure returns (string memory) {
        bytes32 arr = stringToBytes32(hash);
        bytes memory arrBytes = abi.encodePacked(arr);
        return abi.decode(arrBytes, (string));
    }
}



