CREATE TABLE "ACCOUNTSTABLE"(
    accountsTableID INTEGER PRIMARY KEY,
    accountName TEXT,
    accountTypeID INTEGER,
    accountHidden INTEGER,
    accountCurrency TEXT,
    /* accountConversionRate INTEGER,*/
    accountConversionRateNew REAL,
    creditLimit INTEGER,
    cutOffDa INTEGER,
    creditCardDueDate INTEGER,
    cashBasedAccounts INTEGER,
    accountSelectorVisibility INTEGER,
    currencyChanged INTEGER,
    accountsExtraColumnInt1 INTEGER,
    accountsExtraColumnInt2 INTEGER,
    accountsExtraColumnString1 TEXT,
    accountsExtraColumnString2 TEXT
)

CREATE TABLE "ACCOUNTSTABLE"
(
    accountsTableID INTEGER PRIMARY KEY,
    accountName TEXT,
    accountTypeID INTEGER,
    accountHidden INTEGER,
    accountCurrency TEXT,
    /* accountConversionRate INTEGER,*/
    accountConversionRateNew REAL,
    creditLimit INTEGER,
    cutOffDa INTEGER,
    creditCardDueDate INTEGER,
    cashBasedAccounts INTEGER,
    accountSelectorVisibility INTEGER,
    currencyChanged INTEGER,
    accountsExtraColumnInt1 INTEGER,
    accountsExtraColumnInt2 INTEGER,
    accountsExtraColumnString1 TEXT,
    accountsExtraColumnString2 TEXT
)

CREATE INDEX 'accountsTable1' ON ACCOUNTSTABLE
(accountTypeID)

CREATE TABLE "ACCOUNTTYPETABLE"
(
    accountTypeTableID INTEGER PRIMARY KEY,
    accountTypeName TEXT,
    accountingGroupID INTEGER
)

CREATE INDEX 'accountsTypeTable1' ON ACCOUNTTYPETABLE
(accountingGroupID)

CREATE TABLE android_metadata
(
    locale TEXT
)

CREATE TABLE "CATEGORYGROUPTABLE"
(
    categoryGroupTableID INTEGER PRIMARY KEY,
    categoryGroupName TEXT
)

CREATE TABLE "CHILDCATEGORYTABLE"
(
    categoryTableID INTEGER PRIMARY KEY,
    childCategoryName TEXT,
    budgetAmount INTEGER,
    budgetCustomSetup TEXT,
    budgetEnabledCategoryChild INTEGER,
    budgetPeriod INTEGER,
    childCategoryIcon TEXT,
    categorySelectorVisibility INTEGER,
    parentCategoryID INTEGER,
    categoryExtraColumnInt1 INTEGER,
    categoryExtraColumnInt2 INTEGER,
    categoryExtraColumnString1 TEXT,
    categoryExtraColumnString2 TEXT
)

CREATE INDEX 'categoryChildTable1' ON CHILDCATEGORYTABLE
(parentCategoryID)

CREATE TABLE "FILTERSTABLE"(
    filtersTableID INTEGER PRIMARY KEY AUTOINCREMENT,
    filtername TEXT,
    filterJSON TEXT
)

CREATE TABLE "ITEMTABLE"(
    itemTableID INTEGER PRIMARY KEY AUTOINCREMENT,
    itemName TEXT,
    itemAutoFillVisibility INTEGER
)

CREATE TABLE "LABELSTABLE"(
    labelsTableID INTEGER PRIMARY KEY AUTOINCREMENT,
    labelName TEXT,
    transactionIDLabels INTEGER
)

CREATE TABLE "NOTIFICATIONTABLE"(
    smsTableID INTEGER PRIMARY KEY AUTOINCREMENT,
    notificationPackageName TEXT,
    notificationAppName TEXT,
    notificationDefaultName TEXT,
    notificationSenderAccountID INTEGER,
    notificationSenderCategoryID INTEGER,
    notificationSenderAmountOrder INTEGER
)

CREATE TABLE "PARENTCATEGORYTABLE"
(
    parentCategoryTableID INTEGER PRIMARY KEY,
    /* budgetAmountOverride TEXT, */
    parentCategoryName TEXT,
    budgetAmountCategoryParent INTEGER,
    budgetEnabledCategoryParent INTEGER,
    categoryGroupID INTEGER,
    budgetPeriodCategoryParent INTEGER,
    budgetCustomSetupParent TEXT,
    categoryParentExtraColumnInt1 INTEGER,
    categoryParentExtraColumnInt2 INTEGER,
    categoryParentExtraColumnString1 TEXT,
    categoryParentExtraColumnString2 TEXT
)

CREATE INDEX 'categoryParentTable1' ON PARENTCATEGORYTABLE
(categoryGroupID)

CREATE TABLE "PICTURETABLE"(
    pictureTableID INTEGER PRIMARY KEY AUTOINCREMENT,
    pictureFileName TEXT,
    transactionID INTEGER
)

CREATE TABLE room_master_table
(
    id INTEGER PRIMARY KEY,
    identity_hash TEXT
)

CREATE TABLE "SETTINGSTABLE"(
    settingsTableID INTEGER PRIMARY KEY AUTOINCREMENT,
    defaultSettings TEXT
)

CREATE TABLE "SMSSTABLE"(
    smsTableID INTEGER PRIMARY KEY AUTOINCREMENT,
    senderName TEXT,
    senderDefaultName TEXT,
    senderAccountID INTEGER,
    senderCategoryID INTEGER,
    senderAmountOrder INTEGER
)

CREATE TABLE TRACKINGTABLE(trackingTableID INTEGER PRIMARY KEY AUTOINCREMENT, trackingName VARCHAR
(63) )

CREATE TABLE "TRANSACTIONSTABLE"
(
    transactionsTableID INTEGER PRIMARY KEY,
    itemID INTEGER,
    amount INTEGER,
    transactionCurrency VARCHAR(5),
    conversionRateNew REAL,
    date TEXT,
    /* Uses DATETIME in DB version 42 */
    transactionTypeID INTEGER,
    categoryID INTEGER,
    accountID INTEGER,
    notes VARCHAR(255),
    status INTEGER,
    accountReference INTEGER,
    accountPairID INTEGER,
    uidPairID INTEGER,
    deletedTransaction INTEGER,
    newSplitTransactionID INTEGER,
    transferGroupID INTEGER,
    reminderTransaction INTEGER,
    reminderGroupID INTEGER,
    reminderFrequency INTEGER,
    reminderRepeatEvery INTEGER,
    reminderEndingType INTEGER,
    reminderStartDate TEXT,
    /* Uses DATETIME in DB version 42 */
    reminderEndDate TEXT,
    /* Uses DATETIME in DB version 42 */
    reminderAfterNoOfOccurences INTEGER,
    reminderAutomaticLogTransaction INTEGER,
    reminderRepeatByDayOfMonth INTEGER,
    reminderExcludeWeekend INTEGER,
    reminderWeekDayMoveSetting INTEGER,
    reminderUnbilled INTEGER,
    creditCardInstallment INTEGER,
    reminderVersion INTEGER,
    dataExtraColumnString1 VARCHAR(255)
)

CREATE INDEX 'transactionsTable2' ON TRANSACTIONSTABLE
(categoryID)
CREATE INDEX 'transactionsTable1' ON TRANSACTIONSTABLE
(accountID)


CREATE TABLE "TRANSACTIONTYPETABLE"(
    transactionTypeTableID INTEGER PRIMARY KEY AUTOINCREMENT,
    transactionTypeName TEXT
)
