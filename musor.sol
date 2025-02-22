// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TrafficSafetySystem {
    struct Driver {
        string name;
        uint256 balance;
    }

    struct License {
        string licenseNumber;
        uint256 licenseExpiry;
        string category;
        uint256 experienceYears;
        uint256 fines;
    }

    struct Vehicle {
        string category;
        uint256 marketValue;
        uint256 usageYears;
        address owner;
    }

    address public bank;
    mapping(address => Driver) public drivers;
    mapping(address => string[]) public driverLicenses;
    mapping(string => License) public licenses;
    mapping(string => address) public licenseToAddress;
    mapping(address => string[]) public ownerVehicles;
    mapping(string => Vehicle) public vehicles;

    event LicenseRegistered(address indexed driver, string licenseNumber);
    event VehicleRegistered(string vehicleID, address indexed owner);
    event FineIssued(string licenseNumber);
    event FinePaid(string licenseNumber, uint256 amount);
    event LicenseRenewed(string licenseNumber, uint256 newExpiry);

    constructor() {
        bank = msg.sender;
    }

    function registerDriver(string memory _name, address _driverAddress) public {
        require(bytes(drivers[_driverAddress].name).length == 0, "Driver already registered");
        drivers[_driverAddress] = Driver(_name, 50);
    }

    function registerLicense(address _driverAddress, string memory _licenseNumber, uint256 _expiry, string memory _category, uint256 _experienceYears) public {
        require(bytes(drivers[_driverAddress].name).length > 0, "Driver not found");
        require(licenseToAddress[_licenseNumber] == address(0), "License already registered");
        
        licenses[_licenseNumber] = License(_licenseNumber, _expiry, _category, _experienceYears, 0);
        licenseToAddress[_licenseNumber] = _driverAddress;
        driverLicenses[_driverAddress].push(_licenseNumber);
        
        emit LicenseRegistered(_driverAddress, _licenseNumber);
    }

    function registerVehicle(string memory _vehicleID, string memory _category, uint256 _marketValue, uint256 _usageYears, string memory _licenseNumber) public {
        address owner = licenseToAddress[_licenseNumber];
        require(owner != address(0), "License not found");
        require(keccak256(bytes(licenses[_licenseNumber].category)) == keccak256(bytes(_category)), "License category mismatch");
        
        vehicles[_vehicleID] = Vehicle(_category, _marketValue, _usageYears, owner);
        ownerVehicles[owner].push(_vehicleID);
        
        emit VehicleRegistered(_vehicleID, owner);
    }

    function renewLicense(string memory _licenseNumber, uint256 newExpiry) public {
        address owner = licenseToAddress[_licenseNumber];
        require(owner == msg.sender, "Only license owner can renew");
        require(block.timestamp + 30 days >= licenses[_licenseNumber].licenseExpiry, "Renewal not allowed yet");
        require(licenses[_licenseNumber].fines == 0, "All fines must be paid before renewal");
        
        licenses[_licenseNumber].licenseExpiry = newExpiry;
        emit LicenseRenewed(_licenseNumber, newExpiry);
    }

    function issueFine(string memory _licenseNumber) public {
        require(licenseToAddress[_licenseNumber] != address(0), "License not found");
        
        licenses[_licenseNumber].fines++;
        emit FineIssued(_licenseNumber);
    }

    function payFine(string memory _licenseNumber) public payable {
        address owner = licenseToAddress[_licenseNumber];
        require(owner == msg.sender, "Only license owner can pay fines");
        require(licenses[_licenseNumber].fines > 0, "No fines to pay");
        uint256 fineAmount = block.timestamp % 1 days <= 5 minutes ? 5 ether : 10 ether;
        require(drivers[owner].balance >= fineAmount, "Insufficient funds");
        drivers[owner].balance -= fineAmount;
        licenses[_licenseNumber].fines--;
        payable(bank).transfer(fineAmount);
        
        emit FinePaid(_licenseNumber, fineAmount);
    }
}
