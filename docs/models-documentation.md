# Database Models Documentation

## Overview

The Bluecoins Web Project uses auto-generated Django models that mirror the Bluecoins mobile app database schema. These models provide ORM access to financial data while maintaining the original database structure.

## Model Architecture

### Core Transaction Models

#### `Transactions_table`
**Purpose**: Primary model for financial transactions
**Database Table**: `TRANSACTIONSTABLE`

**Key Fields**:
- `transactions_table_id`: Primary key (Auto-increment)
- `item_id`: Foreign key to Item_table (transaction description)
- `amount`: Transaction amount in micro-units (Integer)
- `date`: Transaction date and time
- `transaction_type_id`: Foreign key to Transaction_type_table
- `category_id`: Foreign key to Child_category_table
- `account_id`: Foreign key to Accounts_table
- `notes`: Optional transaction notes

**Relationships**:
- Many-to-One with Accounts_table
- Many-to-One with Child_category_table
- Many-to-One with Transaction_type_table
- Many-to-One with Item_table
- One-to-Many with Labels_table

**Business Logic**:
- Amounts stored in micro-units (divide by 1,000,000 for display)
- Negative amounts represent expenses
- Positive amounts represent income
- Transfer transactions appear twice with opposite signs

#### `Labels_table`
**Purpose**: Manages transaction labeling system
**Database Table**: `LABELSTABLE`

**Key Fields**:
- `labels_table_id`: Primary key
- `label_name`: Text label for categorization
- `transaction_id_labels`: Foreign key to Transactions_table

**Relationships**:
- Many-to-One with Transactions_table (multiple labels per transaction)

**Usage Patterns**:
- Filtering: `Labels_table.objects.filter(label_name='groceries')`
- Transaction labels: `transaction.labels_table_set.all()`

### Account Management Models

#### `Accounts_table`
**Purpose**: Financial accounts (checking, savings, credit cards, etc.)
**Database Table**: `ACCOUNTSTABLE`

**Key Fields**:
- `accounts_table_id`: Primary key
- `account_name`: Display name for the account
- `account_type_id`: Foreign key to Account_type_table
- `account_currency`: Currency code (USD, EUR, etc.)
- `account_hidden`: Visibility flag (0=visible, 1=hidden)
- `credit_limit`: Credit limit for credit cards
- `cash_based_accounts`: Cash account flag

**Relationships**:
- Many-to-One with Account_type_table
- One-to-Many with Transactions_table

#### `Account_type_table`
**Purpose**: Categories of accounts (checking, savings, credit, etc.)
**Database Table**: `ACCOUNTTYPETABLE`

**Key Fields**:
- `account_type_table_id`: Primary key
- `account_type_name`: Type description
- `accounting_group_id`: Foreign key to Accounting_group_table

### Category System Models

#### `Child_category_table`
**Purpose**: Transaction categories and subcategories
**Database Table**: `CHILDCATEGORYTABLE`

**Key Fields**:
- `child_category_table_id`: Primary key
- `child_category_name`: Category display name
- `parent_category_id`: Foreign key to Parent_category_table
- `category_type_id`: Type classification (1=Income, 2=Expense, 3=Transfer)

**Relationships**:
- Many-to-One with Parent_category_table
- One-to-Many with Transactions_table

#### `Parent_category_table`
**Purpose**: Top-level category groupings
**Database Table**: `PARENTCATEGORYTABLE`

**Key Fields**:
- `parent_category_table_id`: Primary key
- `parent_category_name`: Parent category name
- `category_type_id`: Income/Expense/Transfer classification

### Supporting Models

#### `Item_table`
**Purpose**: Transaction descriptions and payees
**Database Table**: `ITEMTABLE`

**Key Fields**:
- `item_table_id`: Primary key
- `item_name`: Description or payee name
- `item_default_category_id`: Default category assignment
- `item_default_account_id`: Default account assignment

#### `Transaction_type_table`
**Purpose**: Transaction type classifications
**Database Table**: `TRANSACTIONTYPETABLE`

**Key Fields**:
- `transaction_type_table_id`: Primary key
- `transaction_type_name`: Type description (Income, Expense, Transfer)

## Model Relationships

### Primary Relationships
```
Accounts_table (1) ←→ (N) Transactions_table
Child_category_table (1) ←→ (N) Transactions_table
Item_table (1) ←→ (N) Transactions_table
Transaction_type_table (1) ←→ (N) Transactions_table
Transactions_table (1) ←→ (N) Labels_table
```

### Category Hierarchy
```
Parent_category_table (1) ←→ (N) Child_category_table
Child_category_table (1) ←→ (N) Transactions_table
```

### Account Structure
```
Accounting_group_table (1) ←→ (N) Account_type_table
Account_type_table (1) ←→ (N) Accounts_table
Accounts_table (1) ←→ (N) Transactions_table
```

## Data Access Patterns

### Common Queries

**Get all transactions for an account:**
```python
account = Accounts_table.objects.get(account_name="Checking")
transactions = Transactions_table.objects.filter(account_id=account)
```

**Filter transactions by label:**
```python
label_tx_ids = Labels_table.objects.filter(
    label_name="groceries"
).values_list('transaction_id_labels', flat=True)
transactions = Transactions_table.objects.filter(
    transactions_table_id__in=label_tx_ids
)
```

**Get transactions with optimized related data:**
```python
transactions = Transactions_table.objects.select_related(
    'account_id', 'category_id', 'transaction_type_id'
).prefetch_related('labels_table_set')
```

### Performance Considerations

**Prefetch Related Objects:**
- Use `prefetch_related()` for labels to avoid N+1 queries
- Use `select_related()` for foreign key relationships
- Implement pagination for large datasets

**Indexing Strategy:**
- Primary keys automatically indexed
- Foreign keys automatically indexed
- Consider composite indexes for common filter combinations

## Model Configuration

### Database Routing
All models use the `BluecoinsDBRouter` to ensure:
- Read operations use the Bluecoins database
- Write operations blocked for data integrity
- Proper database isolation

### Meta Configuration
```python
class Meta:
    managed = False  # Django doesn't manage these tables
    db_table = 'ORIGINAL_TABLE_NAME'  # Preserve original names
```

### Field Mappings
- `db_column` preserves original database column names
- Django field names use Python conventions (lowercase with underscores)
- Foreign keys properly mapped with `on_delete=models.SET_NULL`

## Data Integrity

### Read-Only Operations
- Models designed for read-only access
- No Django migrations applied to Bluecoins database
- Original data structure preserved

### Transaction Handling
- Transfer transactions require special handling (appear as duplicate records)
- Amount conversion from micro-units to display units
- Proper handling of NULL values

### Validation
- Django model validation applied
- Foreign key constraints respected
- Data type validation enforced

## Extension Points

### Adding New Models
1. Generate model from new table: `python manage.py inspectdb table_name`
2. Add to `models.py` with proper relationships
3. Update database router if needed
4. Add to admin interface if required

### Custom Methods
```python
class Transactions_table(models.Model):
    # ... fields ...
    
    def get_display_amount(self):
        """Convert micro-units to display amount"""
        return (self.amount or 0) / 1000000
    
    def is_expense(self):
        """Check if transaction is an expense"""
        return (self.amount or 0) < 0
    
    def get_labels(self):
        """Get all labels for this transaction"""
        return self.labels_table_set.all()
```

### Query Optimization
- Implement custom managers for common queries
- Add property methods for calculated fields
- Use database functions for aggregations

## Troubleshooting

### Common Issues

**Foreign Key Errors:**
- Ensure proper `on_delete` behavior
- Check for NULL values in foreign key fields
- Verify relationship directions

**Performance Issues:**
- Add `select_related()` for foreign keys
- Use `prefetch_related()` for reverse relationships
- Implement proper pagination

**Data Type Mismatches:**
- Verify field type mappings from original schema
- Handle NULL values appropriately
- Convert data types as needed for display

### Debugging Queries
```python
# Enable query logging
import logging
logging.basicConfig()
logging.getLogger('django.db.backends').setLevel(logging.DEBUG)

# Check generated SQL
print(queryset.query)

# Use Django Debug Toolbar for development
```
