// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title TrafficSafetySystem - Блокчейн-система для управления дорожными штрафами и регистрацией водителей.
contract TrafficSafetySystem {
    
    /// @dev Структура, описывающая водителя
    struct Driver {
        string name;  // Имя водителя
        uint256 balance;  // Баланс в ProfiCoin
    }

    /// @dev Структура, описывающая водительское удостоверение
    struct License {
        string licenseNumber;  // Номер удостоверения
        uint256 licenseExpiry;  // Дата истечения срока действия
        string category;  // Категория транспортного средства
        uint256 experienceYears;  // Водительский стаж в годах
        uint256 fines;  // Количество неоплаченных штрафов
        bool approved;  // Подтверждено ли удостоверение службой ДПС
    }

    /// @dev Структура, описывающая транспортное средство
    struct Vehicle {
        string category;  // Категория ТС (например, "B" или "C")
        uint256 marketValue;  // Рыночная стоимость
        uint256 usageYears;  // Количество лет эксплуатации
        address owner;  // Владелец (адрес в блокчейне)
    }

    address public bank;  // Адрес аккаунта банка

    /// @dev Маппинг адресов водителей к их данным
    mapping(address => Driver) public drivers;
    
    /// @dev Маппинг водителей к их водительским удостоверениям
    mapping(address => string[]) public driverLicenses;
    
    /// @dev Маппинг номеров удостоверений к их данным
    mapping(string => License) public licenses;
    
    /// @dev Маппинг номеров удостоверений к адресу владельца
    mapping(string => address) public licenseToAddress;
    
    /// @dev Маппинг владельцев к их транспортным средствам
    mapping(address => string[]) public ownerVehicles;
    
    /// @dev Маппинг номеров транспортных средств к их данным
    mapping(string => Vehicle) public vehicles;

    /// @dev События для логирования действий в системе
    event LicenseRegistered(address indexed driver, string licenseNumber);
    event VehicleRegistered(string vehicleID, address indexed owner);
    event FineIssued(string licenseNumber);
    event FinePaid(string licenseNumber, uint256 amount);
    event LicenseRenewed(string licenseNumber, uint256 newExpiry);
    event DriverRegistered(address indexed driver, string name, uint256 balance);

    /// @dev Конструктор. Создатель контракта автоматически становится банком.
    constructor() {
        bank = msg.sender; // Банк привязывается к адресу, который развернул контракт
        registerDriver("Bank", bank, 1000); // Инициализация банка с балансом 1000 ProfiCoin
    }

    /// @notice Регистрация нового водителя в системе
    /// @param _name Имя водителя
    /// @param _driverAddress Адрес водителя
    /// @param _balance Начальный баланс ProfiCoin
    function registerDriver(string memory _name, address _driverAddress, uint256 _balance) public {
        require(bytes(drivers[_driverAddress].name).length == 0, "Driver already registered");
        drivers[_driverAddress] = Driver(_name, _balance);
        emit DriverRegistered(_driverAddress, _name, _balance);
    }

    /// @notice Регистрация водительского удостоверения (с последующей проверкой ДПС)
    /// @param _licenseNumber Номер удостоверения
    /// @param _expiry Дата истечения срока действия
    /// @param _category Категория ТС
    /// @param _experienceYears Стаж водителя
    function registerLicense(
        string memory _licenseNumber,
        uint256 _expiry,
        string memory _category,
        uint256 _experienceYears
    ) public {
        require(bytes(drivers[msg.sender].name).length > 0, "Driver not registered");
        require(licenseToAddress[_licenseNumber] == address(0), "License already registered");

        licenses[_licenseNumber] = License(_licenseNumber, _expiry, _category, _experienceYears, 0, false);
        licenseToAddress[_licenseNumber] = msg.sender;
        driverLicenses[msg.sender].push(_licenseNumber);

        emit LicenseRegistered(msg.sender, _licenseNumber);
    }

    /// @notice Подтверждение водительского удостоверения службой ДПС
    /// @param _licenseNumber Номер удостоверения
    function approveLicense(string memory _licenseNumber) public {
        require(licenseToAddress[_licenseNumber] != address(0), "License not found");
        licenses[_licenseNumber].approved = true;
    }

    /// @notice Регистрация транспортного средства
    /// @param _vehicleID Уникальный идентификатор ТС
    /// @param _category Категория ТС
    /// @param _marketValue Рыночная стоимость ТС
    /// @param _usageYears Количество лет эксплуатации
    /// @param _licenseNumber Водительское удостоверение владельца
    function registerVehicle(
        string memory _vehicleID,
        string memory _category,
        uint256 _marketValue,
        uint256 _usageYears,
        string memory _licenseNumber
    ) public {
        address owner = licenseToAddress[_licenseNumber];
        require(owner == msg.sender, "Only license owner can register a vehicle");
        require(licenses[_licenseNumber].approved, "License not approved");
        require(
            keccak256(bytes(licenses[_licenseNumber].category)) == keccak256(bytes(_category)),
            "License category mismatch"
        );

        vehicles[_vehicleID] = Vehicle(_category, _marketValue, _usageYears, owner);
        ownerVehicles[owner].push(_vehicleID);

        emit VehicleRegistered(_vehicleID, owner);
    }

    /// @notice Продление водительского удостоверения
    /// @param _licenseNumber Номер удостоверения
    /// @param newExpiry Новая дата истечения срока действия
    function renewLicense(string memory _licenseNumber, uint256 newExpiry) public {
        address owner = licenseToAddress[_licenseNumber];
        require(owner == msg.sender, "Only license owner can renew");
        require(
            block.timestamp + 30 days >= licenses[_licenseNumber].licenseExpiry,
            "Renewal not allowed yet"
        );
        require(licenses[_licenseNumber].fines == 0, "All fines must be paid before renewal");

        licenses[_licenseNumber].licenseExpiry = newExpiry;
        emit LicenseRenewed(_licenseNumber, newExpiry);
    }

    /// @notice Выписывание штрафа водителю
    /// @param _licenseNumber Номер водительского удостоверения
    function issueFine(string memory _licenseNumber) public {
        require(licenseToAddress[_licenseNumber] != address(0), "License not found");

        licenses[_licenseNumber].fines++;
        emit FineIssued(_licenseNumber);
    }

    /// @notice Оплата штрафа
    /// @param _licenseNumber Номер водительского удостоверения
    function payFine(string memory _licenseNumber) public {
        address owner = licenseToAddress[_licenseNumber];
        require(owner == msg.sender, "Only license owner can pay fines");
        require(licenses[_licenseNumber].fines > 0, "No fines to pay");

        uint256 fineAmount = (block.timestamp % 1 days <= 5 minutes) ? 5 : 10; // 50% скидка в первые 5 дней

        require(drivers[owner].balance >= fineAmount, "Insufficient funds");

        drivers[owner].balance -= fineAmount;
        licenses[_licenseNumber].fines--;
        drivers[bank].balance += fineAmount;

        emit FinePaid(_licenseNumber, fineAmount);
    }
}
