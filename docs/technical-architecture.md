# Technical Documentation

## Application Architecture

### Bluecoins App (`bluecoins_app`)

The main Django application that handles all financial data operations and user interface components.

#### Purpose
- Provides web interface for Bluecoins financial data
- Enables transaction filtering, searching, and reporting
- Generates Excel exports for financial analysis
- Handles dynamic database connections to Bluecoins backup files

#### Key Components

**Models (`models.py`)**
- Auto-generated Django models based on Bluecoins database schema
- Provides ORM access to financial data with proper relationships
- Includes read-only models for data integrity

**Views (`views.py`)**
- Implements business logic for transaction management
- Handles pagination, filtering, and reporting
- Supports both HTML and JSON responses for AJAX functionality

**Templates (`templates/`)**
- Responsive HTML templates with modern UI design
- JavaScript-enhanced user interactions
- Mobile-friendly responsive design

**Database Router (`dbrouters.py`)**
- Routes Bluecoins app models to the Bluecoins database
- Ensures Django admin models use the default database
- Maintains database isolation and integrity

#### Database Schema Integration

The application works with the Bluecoins mobile app database schema, which includes:

**Core Tables:**
- `TRANSACTIONSTABLE`: Primary transaction records
- `LABELSTABLE`: Transaction labeling system
- `ACCOUNTSTABLE`: Financial accounts
- `CATEGORYTABLE`: Transaction categories
- `ITEMTABLE`: Transaction descriptions/items

**Relationship Mapping:**
- One-to-many: Accounts → Transactions
- One-to-many: Categories → Transactions  
- Many-to-many: Transactions ↔ Labels (through foreign keys)
- One-to-many: Items → Transactions

#### Key Features Implementation

**Dynamic Database Detection:**
```python
def find_bluecoins_database():
    """
    Automatically locates the most recent Bluecoins backup file
    - Searches for bluecoins*.fydb pattern
    - Orders by modification time
    - Provides fallback mechanism
    """
```

**Optimized Pagination:**
- Custom pagination for label-filtered results
- AJAX loading for seamless user experience
- Prefetch optimization to prevent N+1 queries

**Excel Report Generation:**
- Month-based sheet organization
- Automatic currency conversion from micro-units
- Transfer transaction deduplication
- Customizable column structure

**Responsive UI:**
- Fixed header with logo and navigation
- Floating action buttons for quick access
- Dropdown menus with intelligent positioning
- Mobile-optimized touch interfaces

#### Security Considerations

**Database Access:**
- Read-only access to Bluecoins database
- Separate Django admin database for user management
- No write operations on financial data

**Input Validation:**
- Django's built-in CSRF protection
- Parameter sanitization for database queries
- Safe file path handling for backup detection

**Data Privacy:**
- Local database processing (no external data transmission)
- Secure file access permissions required
- No sensitive data logging

#### Performance Optimizations

**Database Queries:**
- Prefetch related objects to avoid N+1 problems
- Optimized filtering using database indexes
- Efficient pagination with count optimization

**Frontend Performance:**
- AJAX loading for smooth pagination
- JavaScript debouncing for scroll events
- CSS-only animations for better performance
- Optimized image assets

**Memory Management:**
- Streaming Excel generation for large datasets
- Limited query result sets with pagination
- Efficient template rendering

#### API Endpoints

**Transaction Management:**
- `GET /transactions/` - List transactions with filtering
- `GET /transactions/<id>/` - Transaction details
- `POST /transactions/new/` - Create transaction (if enabled)
- `PUT /transactions/<id>/edit/` - Update transaction
- `DELETE /transactions/<id>/delete/` - Remove transaction

**Reporting:**
- `GET /reports_by_label/` - Excel export by label
- `GET /reports_by_category/` - Category analysis report

**AJAX Endpoints:**
- `GET /transactions/?page=<n>` - Paginated transaction data
- `GET /transactions/?label=<name>` - Filtered transactions

#### Error Handling

**Database Errors:**
- Graceful handling of missing backup files
- Fallback database selection
- Connection timeout management

**User Experience:**
- Informative error messages
- Fallback content for empty results
- Progressive enhancement for JavaScript failures

**Logging:**
- Database selection logging
- Error tracking for debugging
- Performance monitoring points

#### Extensibility

**Model Extensions:**
- Easy addition of new Bluecoins table models
- Custom field mappings for schema changes
- Backward compatibility considerations

**View Customization:**
- Modular view structure for easy modification
- Template inheritance for consistent design
- Configurable pagination and filtering

**Report Formats:**
- Extensible report generation system
- Multiple export format support (Excel, CSV potential)
- Customizable report columns and grouping

#### Integration Points

**External Systems:**
- Cloud storage integration for backup file access
- Potential API integrations for enhanced functionality
- Export compatibility with accounting software

**Django Ecosystem:**
- Django admin integration for user management
- Django's authentication system integration
- Static file handling for production deployment

#### Development Workflow

**Local Development:**
- Django development server
- SQLite database for testing
- Debug toolbar integration potential

**Testing Strategy:**
- Unit tests for business logic
- Integration tests for database operations
- Frontend testing for UI components

**Deployment Considerations:**
- Static file collection for production
- Database file access permissions
- WSGI server configuration
- Environment-specific settings
