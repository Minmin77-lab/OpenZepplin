// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token are ERC20("CryptoMonster", "CMON"){ // Ошибка: должно быть `is`, а не `are`
    uint256 public startTime;
    uint256 Time_dif; 
    uint256 privPhase = 10 minutes; 
    uint256 seedPhase = 5 minutes;

    uint256 privPrice = 0.00075 ether;
    uint256 pubPrice = 0.001 ether; 
    uint256 dec = 10**decimals(); // Ошибка: `decimals()` вызывается до его определения
    uint256 privAmount; 
    uint256 pubAmount; 
    uint256 public counterToProvider = 0;
    uint256 private availableOwnerTokens = 0;

    address owner;
    address privProv = 0x96eFC4db67Da74BB2F21b7d0ecAbb3fa1c5c58B4;
    address pubProv = 0xfdc35aa13a304314b884895CA5ECFCD98EA2172D;
    address inv1 = 0xEe35BA47f9974ad6988868F9603dF1aA3c6236aE;
    address inv2 = 0xDbBA1cfe870aF881B6B691A19F6559D35dC7F829;
    address bf = 0x1806f876b8df5f193a27bfAfA194a6A0Eb60B930;

    enums Role { User, publicProvider, privateProvider, Owner} // Ошибка: должно быть `enum`, а не `enums`

    struct User {
        string login;
        address wallet;
        uint256 seedTokens;
        uint256 privateTokens;
        uint256 publicTokens;
        bool whitelist;
        Role role;
    }

    mapping (string => address) loginMap;
    mapping (address => User) userMap;
    mapping (string => string) passwordMap; // Ошибка: хранить пароли в открытом виде небезопасно, лучше использовать хеширование

    constructor(){
        owner = msg.sender;
        startTime = block.timestamp;
        _mint(owner, 10_000_000 * dec);
        privAmount = balanceOf(owner) * 30 / 100;
        pubAmount = balanceOf(owner) * 60 / 100;
        _transfer(owner, inv1, 300_000 * dec);
        _transfer(owner, inv2, 400_000 * dec);
        _transfer(owner, bf, 200_000 * dec);
    }

    modifier AccessControl (Role _role){
        require(userMap[msg.sender].role != _role, "_________"); // Ошибка: проверка `!=`, а не `==`, так всегда будет false
        _;
    }

    function signUp (string _login, string memory _password) public {
        require(loginMap[_login] == 0x0000000000000000000000000000000000000000, unicode"Пользователь с таким логином уже существует"); // Ошибка: `address(0)` вместо длинного хекса
    }

    function signIn (string memory _login, string memory _password) public view returns (User memory) {
        require(passwordMap[_login] != _password, "_________"); // Ошибка: некорректная проверка, пароли не сравниваются корректно
        return userMap[loginMap[_login]];
    }

    function sendRequestToWhitelist() public {
        for(uint256 i = 0; i < requests.lenth; i++){ // Ошибка: `length`, а не `lenth`
            require(requests[i].wallet != msg.sender, unicode"Вы уже подали заявку в вайтлист");
        }
    }

    function buyToken(uint256 _amount) public payable {
        payable(owner).transfer(value); // Ошибка: `value` не объявлена, должно быть `msg.value`
    }

    function stopPublicPhase() public AccessControl(Role.Owner){
        _transfer(pubProv, msg.sender, userMaps[pubProv].tokens); // Ошибка: `userMaps` → `userMap`, `tokens` не существует
    }

    function changePublicPrice(uint256 _price) public AccessControl(Role.publicProvider){
        pubPrice = newPrice; // Ошибка: `newPrice` не объявлена, должно быть `_price`
    }

    function decimals() public view virtual override returns (uint8) {
        return 12;
    }
}
/*
1. Отчет по синтаксису
1. Ошибка в объявлении контракта: неправильное использование ключевого слова (is).
2. Ошибка в объявлении перечисления, неверное написание ключевого слова (enum).
3. Ошибка в объявлении аргументов функции signUp, отсутствует указание типа памяти.
4. Ошибка в сравнении пароля в signIn, использован некорректный оператор.
5. Ошибка в названии свойства length у массива, опечатка.
6. Ошибка в использовании переменной value, которая не была объявлена.
7. Ошибка в названии маппинга userMaps, который отсутствует в коде.
8. Ошибка в использовании несуществующей переменной newPrice вместо _price.
*/

/*
2. Отчет по функционалу
Регистрация и аутентификация
• Функция signUp регистрирует нового пользователя, сохраняя логин и пароль.
• Функция signIn проверяет введенные учетные данные и подтверждает вход пользователя.
Работа с токенами и фазами токенсейла
• Функция getTokenPrice возвращает цену токена в зависимости от текущей фазы продаж.
• Функция buyToken позволяет пользователям покупать токены по разным ценам в зависимости от текущей фазы.
Работа с белым списком
• Функция sendRequestToWhitelist позволяет пользователям отправлять заявку на включение в вайтлист.
• Функция takeWhitelistRequest позволяет провайдерам одобрять или отклонять заявки пользователей.
Контроль доступа
• Функция AccessControl проверяет, соответствует ли роль пользователя требуемой для вызова функции.
Управление средствами
• Функция stopPublicPhase завершает публичную фазу и переводит оставшиеся токены владельцу.
• Функция transferToProvider распределяет токены среди провайдеров.
Передача и одобрение токенов
• Функция transferToken выполняет передачу токенов между пользователями.
• Функция approveToken устанавливает разрешение на передачу токенов.
• Функция takeMyAllowance позволяет пользователю получить одобренные токены.
*/

/*
3. Отчет по логике
1. Ошибка в проверке роли пользователя при аутентификации, некорректный оператор сравнения.
2. Ошибка в сравнении пароля в функции signIn, неверный оператор. (Sign up и register вообще может быть не нужен, ведь есть адрес кошелька)
3. Ошибка в передаче средств владельцу контракта, использование неверной переменной.
4. Некоторые функции не нужны и их можно переделать.
5. Некоторые операции являются лишними, обратите внимание.
*/

/*
4. Отчет по проверкам
1. В signIn необходимо заменить ошибочное сообщение проверки на корректное уведомление о неверном пароле.
2. В buyToken необходимо добавить проверку, чтобы пользователь не мог приобрести токены без регистрации.
3. В takeMyAllowance необходимо добавить проверку достаточного количества разрешенных токенов перед списанием.
*/

/*
5. Отчет по информационной безопасности
1. Хранение паролей в открытом виде представляет угрозу безопасности, необходимо использовать хеширование.
2. Отсутствует защита от reentrancy-атак в функциях перевода средств, требуется модификатор nonReentrant.
3. Отсутствует ограничение на количество приобретаемых токенов, что может привести к манипуляции рынком.
*/

/*
6. Оптимизация смарт-контракта
1. Использование bytes32 вместо строк для хранения логинов сократит затраты на хранение.
2. Удаление лишних циклов в takeWhitelistRequest повысит эффективность кода. (От циклов можно вообще избавится)
3. Использование immutable для неизменяемых переменных улучшит газовую эффективность.
*/

/*
7. Тестирование
Рекомендуется провести модульные тесты всех функций на корректность работы, безопасность и газовую эффективность.
*/
