# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.


from django.db import models

# Default values for the foreign keys
# OTHERS = 785
# BILLS = 3


class Accounting_group_table(models.Model):
    accounting_group_table_id = models.AutoField(db_column='accountingGroupTableID', primary_key=True)  # Field name made lowercase.
    account_group_name = models.TextField(db_column='accountGroupName', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ACCOUNTINGGROUPTABLE'

class Account_type_table(models.Model):
    account_type_table_id = models.AutoField(db_column='accountTypeTableID', primary_key=True)  # Field name made lowercase.
    account_type_name = models.TextField(db_column='accountTypeName', blank=True, null=True)  # Field name made lowercase.
    accounting_group_id = models.IntegerField(db_column='accountingGroupID', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ACCOUNTTYPETABLE'
    
    def __str__(self):
        return self.account_type_name or f"AccountType {self.account_type_table_id}"

class Accounts_table(models.Model):
    accounts_table_id = models.AutoField(db_column='accountsTableID', primary_key=True)  # Field name made lowercase.
    account_name = models.TextField(db_column='accountName', blank=True, null=True)  # Field name made lowercase.
    account_type_id = models.ForeignKey(Account_type_table, on_delete=models.SET_NULL, null=True, db_column='accountTypeID')  # Field name made lowercase.
    account_hidden = models.IntegerField(db_column='accountHidden', blank=True, null=True)  # Field name made lowercase.
    account_currency = models.TextField(db_column='accountCurrency', blank=True, null=True)  # Field name made lowercase.
    account_conversion_rate_new = models.FloatField(db_column='accountConversionRateNew', blank=True, null=True)  # Field name made lowercase.
    credit_limit = models.IntegerField(db_column='creditLimit', blank=True, null=True)  # Field name made lowercase.
    cut_off_da = models.IntegerField(db_column='cutOffDa', blank=True, null=True)  # Field name made lowercase.
    credit_card_due_date = models.IntegerField(db_column='creditCardDueDate', blank=True, null=True)  # Field name made lowercase.
    cash_based_accounts = models.IntegerField(db_column='cashBasedAccounts', blank=True, null=True)  # Field name made lowercase.
    account_selector_visibility = models.IntegerField(db_column='accountSelectorVisibility', blank=True, null=True)  # Field name made lowercase.
    currency_changed = models.IntegerField(db_column='currencyChanged', blank=True, null=True)  # Field name made lowercase.
    accounts_extra_column_int1 = models.IntegerField(db_column='accountsExtraColumnInt1', blank=True, null=True)  # Field name made lowercase.
    accounts_extra_column_int2 = models.IntegerField(db_column='accountsExtraColumnInt2', blank=True, null=True)  # Field name made lowercase.
    accounts_extra_column_string1 = models.TextField(db_column='accountsExtraColumnString1', blank=True, null=True)  # Field name made lowercase.
    accounts_extra_column_string2 = models.TextField(db_column='accountsExtraColumnString2', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ACCOUNTSTABLE'    
    def __str__(self):
        return self.account_name or f"Account {self.accounts_table_id}"




class Category_group_table(models.Model):
    category_group_table_id = models.AutoField(db_column='categoryGroupTableID', primary_key=True)  # Field name made lowercase.
    category_group_name = models.TextField(db_column='categoryGroupName', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'CATEGORYGROUPTABLE'

class Parent_category_table(models.Model):
    parent_category_table_id = models.AutoField(db_column='parentCategoryTableID', primary_key=True)  # Field name made lowercase.
    parent_category_name = models.TextField(db_column='parentCategoryName', blank=True, null=True)  # Field name made lowercase.
    budget_amount_category_parent = models.IntegerField(db_column='budgetAmountCategoryParent', blank=True, null=True)  # Field name made lowercase.
    budget_enabled_category_parent = models.IntegerField(db_column='budgetEnabledCategoryParent', blank=True, null=True)  # Field name made lowercase.
    category_group_id = models.ForeignKey(Category_group_table, on_delete=models.SET_NULL, null=True, db_column='categoryGroupID')  # Field name made lowercase.
    budget_period_category_parent = models.IntegerField(db_column='budgetPeriodCategoryParent', blank=True, null=True)  # Field name made lowercase.
    budget_custom_setup_parent = models.TextField(db_column='budgetCustomSetupParent', blank=True, null=True)  # Field name made lowercase.
    category_parent_extra_column_int1 = models.IntegerField(db_column='categoryParentExtraColumnInt1', blank=True, null=True)  # Field name made lowercase.
    category_parent_extra_column_int2 = models.IntegerField(db_column='categoryParentExtraColumnInt2', blank=True, null=True)  # Field name made lowercase.
    category_parent_extra_column_string1 = models.TextField(db_column='categoryParentExtraColumnString1', blank=True, null=True)  # Field name made lowercase.
    category_parent_extra_column_string2 = models.TextField(db_column='categoryParentExtraColumnString2', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'PARENTCATEGORYTABLE'

class Child_category_table(models.Model):
    category_table_id = models.AutoField(db_column='categoryTableID', primary_key=True)  # Field name made lowercase.
    child_category_name = models.TextField(db_column='childCategoryName', blank=True, null=True)  # Field name made lowercase.
    budget_amount = models.IntegerField(db_column='budgetAmount', blank=True, null=True)  # Field name made lowercase.
    budget_custom_setup = models.TextField(db_column='budgetCustomSetup', blank=True, null=True)  # Field name made lowercase.
    budget_enabled_category_child = models.IntegerField(db_column='budgetEnabledCategoryChild', blank=True, null=True)  # Field name made lowercase.
    budget_period = models.IntegerField(db_column='budgetPeriod', blank=True, null=True)  # Field name made lowercase.
    child_category_icon = models.TextField(db_column='childCategoryIcon', blank=True, null=True)  # Field name made lowercase.
    category_selector_visibility = models.IntegerField(db_column='categorySelectorVisibility', blank=True, null=True)  # Field name made lowercase.
    parent_category_id = models.ForeignKey(Parent_category_table, on_delete=models.SET_NULL, null=True, db_column='parentCategoryID')  # Field name made lowercase.
    category_extra_column_int1 = models.IntegerField(db_column='categoryExtraColumnInt1', blank=True, null=True)  # Field name made lowercase.
    category_extra_column_int2 = models.IntegerField(db_column='categoryExtraColumnInt2', blank=True, null=True)  # Field name made lowercase.
    category_extra_column_string1 = models.TextField(db_column='categoryExtraColumnString1', blank=True, null=True)  # Field name made lowercase.
    category_extra_column_string2 = models.TextField(db_column='categoryExtraColumnString2', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'CHILDCATEGORYTABLE'    
    def __str__(self):
        return self.child_category_name or f"Category {self.category_table_id}"


class Filter_stable(models.Model):
    filter_stable_id = models.AutoField(db_column='filtersTableID', primary_key=True)  # Field name made lowercase.
    filtername = models.TextField(blank=True, null=True)
    filter_json = models.TextField(db_column='filterJSON', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'FILTERSTABLE'


class Item_table(models.Model):
    item_table_id = models.AutoField(db_column='itemTableID', primary_key=True)  # Field name made lowercase.
    item_name = models.TextField(db_column='itemName', blank=True, null=True)  # Field name made lowercase.
    item_auto_fill_visibility = models.IntegerField(db_column='itemAutoFillVisibility', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'ITEMTABLE'    
    def __str__(self):
        return self.item_name or f"Item {self.item_table_id}"



class Notification_table(models.Model):
    sms_table_id = models.AutoField(db_column='smsTableID', primary_key=True)  # Field name made lowercase.
    notification_package_name = models.TextField(db_column='notificationPackageName', blank=True, null=True)  # Field name made lowercase.
    notification_app_name = models.TextField(db_column='notificationAppName', blank=True, null=True)  # Field name made lowercase.
    notification_default_name = models.TextField(db_column='notificationDefaultName', blank=True, null=True)  # Field name made lowercase.
    notification_sender_account_id = models.IntegerField(db_column='notificationSenderAccountID', blank=True, null=True)  # Field name made lowercase.
    notification_sender_category_id = models.IntegerField(db_column='notificationSenderCategoryID', blank=True, null=True)  # Field name made lowercase.
    notification_sender_amount_order = models.IntegerField(db_column='notificationSenderAmountOrder', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'NOTIFICATIONTABLE'


class Settings_table(models.Model):
    settings_table_id = models.AutoField(db_column='settingsTableID', primary_key=True)  # Field name made lowercase.
    default_settings = models.TextField(db_column='defaultSettings', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'SETTINGSTABLE'


class Smss_table(models.Model):
    sms_table_id = models.AutoField(db_column='smsTableID', primary_key=True)  # Field name made lowercase.
    sender_name = models.TextField(db_column='senderName', blank=True, null=True)  # Field name made lowercase.
    sender_default_name = models.TextField(db_column='senderDefaultName', blank=True, null=True)  # Field name made lowercase.
    sender_account_id = models.IntegerField(db_column='senderAccountID', blank=True, null=True)  # Field name made lowercase.
    sender_category_id = models.IntegerField(db_column='senderCategoryID', blank=True, null=True)  # Field name made lowercase.
    sender_amount_order = models.IntegerField(db_column='senderAmountOrder', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'SMSSTABLE'


class Tracking_table(models.Model):
    tracking_table_id = models.AutoField(db_column='trackingTableID', primary_key=True)  # Field name made lowercase.
    tracking_name = models.TextField(db_column='trackingName', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'TRACKINGTABLE'

class Transaction_type_table(models.Model):
    transaction_type_table_id = models.AutoField(db_column='transactionTypeTableID', primary_key=True)  # Field name made lowercase.
    transaction_type_name = models.TextField(db_column='transactionTypeName', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'TRANSACTIONTYPETABLE'
        
    def __str__(self):
        #return f'({self.transaction_type_table_id}) - {self.transaction_type_name}'  # To display the account name in the view
        return f'{self.transaction_type_name}'
    
class Transactions_table(models.Model):
    transactions_table_id = models.AutoField(db_column='transactionsTableID', primary_key=True)  # Field name made lowercase.
    item_id = models.ForeignKey(Item_table, on_delete=models.SET_NULL, null= True, db_column= 'itemID')  # Field name made lowercase.
    amount = models.IntegerField(blank=True, null=True)
    transaction_currency = models.TextField(db_column='transactionCurrency', blank=True, null=True)  # Field name made lowercase.
    conversion_rate_new = models.FloatField(db_column='conversionRateNew', blank=True, null=True)  # Field name made lowercase.
    date = models.DateTimeField(blank=True, null=True)
    transaction_type_id = models.ForeignKey(Transaction_type_table, on_delete=models.SET_NULL, null=True, db_column='transactionTypeID')  # Field name made lowercase.
    category_id = models.ForeignKey(Child_category_table, on_delete=models.SET_NULL, null=True, db_column='categoryID')  # Field name made lowercase.
    account_id = models.ForeignKey(Accounts_table, on_delete=models.SET_NULL, null=True, db_column='accountID')  # Field name made lowercase.
    notes = models.TextField(blank=True, null=True)
    status = models.IntegerField(blank=True, null=True)
    account_reference = models.IntegerField(db_column='accountReference', blank=True, null=True)  # Field name made lowercase.
    account_pair_id = models.IntegerField(db_column='accountPairID', blank=True, null=True)  # Field name made lowercase.
    uid_pair_id = models.IntegerField(db_column='uidPairID', blank=True, null=True)  # Field name made lowercase.
    deleted_transaction = models.IntegerField(db_column='deletedTransaction', blank=True, null=True)  # Field name made lowercase.
    new_split_transaction_id = models.IntegerField(db_column='newSplitTransactionID', blank=True, null=True)  # Field name made lowercase.
    transfer_group_id = models.IntegerField(db_column='transferGroupID', blank=True, null=True)  # Field name made lowercase.
    reminder_transaction = models.IntegerField(db_column='reminderTransaction', blank=True, null=True)  # Field name made lowercase.
    reminder_group_id = models.IntegerField(db_column='reminderGroupID', blank=True, null=True)  # Field name made lowercase.
    reminder_frequency = models.IntegerField(db_column='reminderFrequency', blank=True, null=True)  # Field name made lowercase.
    reminder_repeat_every = models.IntegerField(db_column='reminderRepeatEvery', blank=True, null=True)  # Field name made lowercase.
    reminder_ending_type = models.IntegerField(db_column='reminderEndingType', blank=True, null=True)  # Field name made lowercase.
    reminder_start_date = models.TextField(db_column='reminderStartDate', blank=True, null=True)  # Field name made lowercase.
    reminder_end_date = models.TextField(db_column='reminderEndDate', blank=True, null=True)  # Field name made lowercase.
    reminder_after_no_of_occurences = models.IntegerField(db_column='reminderAfterNoOfOccurences', blank=True, null=True)  # Field name made lowercase.
    reminder_automatic_log_transaction = models.IntegerField(db_column='reminderAutomaticLogTransaction', blank=True, null=True)  # Field name made lowercase.
    reminder_repeat_by_day_of_month = models.IntegerField(db_column='reminderRepeatByDayOfMonth', blank=True, null=True)  # Field name made lowercase.
    reminder_exclude_weekend = models.IntegerField(db_column='reminderExcludeWeekend', blank=True, null=True)  # Field name made lowercase.
    reminder_week_day_move_setting = models.IntegerField(db_column='reminderWeekDayMoveSetting', blank=True, null=True)  # Field name made lowercase.
    reminder_unbilled = models.IntegerField(db_column='reminderUnbilled', blank=True, null=True)  # Field name made lowercase.
    credit_card_installment = models.IntegerField(db_column='creditCardInstallment', blank=True, null=True)  # Field name made lowercase.
    reminder_version = models.IntegerField(db_column='reminderVersion', blank=True, null=True)  # Field name made lowercase.
    data_extra_column_string1 = models.TextField(db_column='dataExtraColumnString1', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'TRANSACTIONSTABLE'

class Labels_table(models.Model):
    labels_table_id = models.AutoField(db_column='labelsTableID', primary_key=True)  # Field name made lowercase.
    label_name = models.TextField(db_column='labelName', blank=True, null=True)  # Field name made lowercase.
    transaction_id_labels = models.ForeignKey(Transactions_table, on_delete=models.CASCADE, null=True, db_column='transactionIDLabels')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'LABELSTABLE'
    
    def __str__(self):
        #return self.labelName or f"Label {self.labels_table_id}"
        #return f'({self.labels_table_id}) - {self.label_name}'  # To display the account name in the view
        return f'{self.label_name}'


class Picture_table(models.Model):
    picture_table_id = models.AutoField(db_column='pictureTableID', primary_key=True)  # Field name made lowercase.
    picture_file_name = models.TextField(db_column='pictureFileName', blank=True, null=True)  # Field name made lowercase.
    transaction_id = models.ForeignKey(Transactions_table, on_delete=models.SET_NULL, null=True, db_column='transactionID')  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'PICTURETABLE'


class AndroidMetadata(models.Model):
    locale = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'android_metadata'


class RoomMasterTable(models.Model):
    identity_hash = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'room_master_table'
