const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TrafficSafetySystem", function () {
  let TrafficSafetySystem, trafficSafetySystem;
  let owner, bank, dps, driver1, driver2, driver3;

  beforeEach(async function () {
    // Получаем аккаунты из Hardhat
    [owner, bank, dps, driver1, driver2, driver3] = await ethers.getSigners();

    // Разворачиваем контракт
    TrafficSafetySystem = await ethers.getContractFactory("TrafficSafetySystem");
    trafficSafetySystem = await TrafficSafetySystem.deploy();
    await trafficSafetySystem.deployed();

    // Регистрируем аккаунт банка
    await trafficSafetySystem.connect(bank).registerDriver("Bank", bank.address, 1000);

    // Регистрируем ДПС и водителей
    await trafficSafetySystem.connect(dps).registerDriver("DPS Officer", dps.address, 50);
    await trafficSafetySystem.connect(driver1).registerDriver("Ivanov Ivan", driver1.address, 50);
    await trafficSafetySystem.connect(driver2).registerDriver("Semenov Semen", driver2.address, 50);
    await trafficSafetySystem.connect(driver3).registerDriver("Petrov Petr", driver3.address, 50);
  });

  it("Должен корректно регистрировать водителей", async function () {
    const driverData = await trafficSafetySystem.drivers(driver1.address);
    expect(driverData.name).to.equal("Ivanov Ivan");
    expect(driverData.balance).to.equal(50);
  });

  it("Должен регистрировать водительское удостоверение и подтверждать его", async function () {
    await trafficSafetySystem.connect(driver1).registerLicense("LICENSE1", 1700000000, "B", 2);
    await trafficSafetySystem.connect(dps).approveLicense("LICENSE1");

    const licenseData = await trafficSafetySystem.licenses("LICENSE1");
    expect(licenseData.approved).to.be.true;
  });

  it("Должен запрещать регистрацию ТС, если категории не совпадают", async function () {
    await trafficSafetySystem.connect(driver1).registerLicense("LICENSE1", 1700000000, "B", 2);
    await trafficSafetySystem.connect(dps).approveLicense("LICENSE1");

    await expect(
      trafficSafetySystem.connect(driver1).registerVehicle("CAR1", "C", 10000, 3, "LICENSE1")
    ).to.be.revertedWith("License category mismatch");
  });

  it("Должен выписывать штраф и позволять его оплатить", async function () {
    await trafficSafetySystem.connect(driver1).registerLicense("LICENSE1", 1700000000, "B", 2);
    await trafficSafetySystem.connect(dps).approveLicense("LICENSE1");

    await trafficSafetySystem.connect(dps).issueFine("LICENSE1");
    let licenseData = await trafficSafetySystem.licenses("LICENSE1");
    expect(licenseData.fines).to.equal(1);

    await trafficSafetySystem.connect(driver1).payFine("LICENSE1");
    licenseData = await trafficSafetySystem.licenses("LICENSE1");
    expect(licenseData.fines).to.equal(0);
  });

  it("Должен запрещать продление водительского удостоверения, если есть неоплаченные штрафы", async function () {
    await trafficSafetySystem.connect(driver1).registerLicense("LICENSE1", 1700000000, "B", 2);
    await trafficSafetySystem.connect(dps).approveLicense("LICENSE1");

    await trafficSafetySystem.connect(dps).issueFine("LICENSE1");

    await expect(
      trafficSafetySystem.connect(driver1).renewLicense("LICENSE1", 1800000000)
    ).to.be.revertedWith("All fines must be paid before renewal");
  });
});
