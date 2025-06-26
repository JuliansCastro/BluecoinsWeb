# Database and Settings Configuration

## Overview

The Bluecoins Web Project uses a sophisticated dual-database architecture that separates Django administrative data from the read-only Bluecoins financial data. This document covers the database configuration, settings management, and deployment considerations.

## Database Architecture

### Dual Database Setup

The application maintains two separate databases:

**Default Database** (`bluecoins_admin.db`)
- Purpose: Django admin, user management, sessions, and app metadata
- Type: SQLite3
- Location: `databases/bluecoins_admin.db`
- Permissions: Read/Write

**Bluecoins Database** (`*.fydb` files)
- Purpose: Financial transaction data from Bluecoins mobile app
- Type: SQLite3 (with .fydb extension)
- Location: Dynamically detected from backup directory
- Permissions: Read-only

### Database Configuration

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'databases/bluecoins_admin.db',
    },
    'bluecoins': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': find_bluecoins_database(),  # Dynamic detection
    }
}
```

### Dynamic Database Detection

The `find_bluecoins_database()` function provides automatic backup file detection:

**Features**:
- Searches for files matching `bluecoins*.fydb` pattern
- Selects the most recently modified file
- Provides fallback to local database
- Logs selected database for debugging

**Implementation**:
```python
def find_bluecoins_database():
    bluecoins_dir = r'C:/Users/JuliansCastro/Mi unidad/Bluecoins/QuickSync/'
    pattern = os.path.join(bluecoins_dir, 'bluecoins*.fydb')
    matching_files = glob.glob(pattern)
    
    if not matching_files:
        print(f"Warning: No bluecoins database found in {bluecoins_dir}")
        return BASE_DIR / 'databases/bluecoins.fydb'
    
    matching_files.sort(key=os.path.getmtime, reverse=True)
    latest_file = matching_files[0]
    print(f"Using bluecoins database: {latest_file}")
    return latest_file
```

**Benefits**:
- Automatic adaptation to backup file naming changes
- No manual configuration required for new backups
- Seamless integration with cloud storage sync

## Database Router

### Purpose

The `BluecoinsDBRouter` ensures proper database isolation and routing:

**Routing Logic**:
- Routes `bluecoins_app` models to the `bluecoins` database
- Routes all other models to the `default` database
- Prevents accidental writes to the Bluecoins database

**Implementation**:
```python
class BluecoinsDBRouter:
    route_app_labels = {'bluecoins_app'}

    def db_for_read(self, model, **hints):
        if model._meta.app_label in self.route_app_labels:
            return 'bluecoins'
        return None

    def db_for_write(self, model, **hints):
        if model._meta.app_label in self.route_app_labels:
            return 'bluecoins'
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        if app_label in self.route_app_labels:
            return db == 'bluecoins'
        return None
```

**Configuration**:
```python
DATABASE_ROUTERS = [
    'bluecoins_app.dbrouters.BluecoinsDBRouter',
]
```

## Django Settings Configuration

### Application Settings

**Installed Apps**:
```python
INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes", 
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "django.contrib.humanize",  # For number formatting
    "bluecoins_app",            # Main application
]
```

**Key Components**:
- Django admin for user management
- Authentication system for security
- Humanize for currency/number display
- Static files for CSS/JS/images

### Middleware Configuration

```python
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]
```

**Security Features**:
- CSRF protection for form submissions
- Session management for user state
- Clickjacking protection
- Security headers for production

### Template Configuration

```python
TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]
```

**Features**:
- App-based template discovery
- Standard context processors
- Debug information in development

### Static Files Configuration

```python
STATIC_URL = "static/"
```

**File Organization**:
- App-level static files in `bluecoins_app/static/`
- Images, CSS, and JavaScript files
- Automatic collection for production deployment

### Internationalization Settings

```python
LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True
```

**Localization Features**:
- English as default language
- UTC timezone for consistency
- i18n framework ready for expansion
- Timezone-aware datetime handling

## Security Configuration

### Authentication Settings

```python
AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]
```

**Password Security**:
- Similarity checking with user attributes
- Minimum length requirements
- Common password detection
- Numeric-only password prevention

### Development vs Production

**Development Settings**:
```python
DEBUG = True
ALLOWED_HOSTS = []
SECRET_KEY = "django-insecure-..."  # Development key
```

**Production Settings** (recommended):
```python
DEBUG = False
ALLOWED_HOSTS = ['yourdomain.com', 'www.yourdomain.com']
SECRET_KEY = os.environ.get('SECRET_KEY')  # Environment variable
```

## File System Configuration

### Database Directory Structure

```
databases/
├── bluecoins_admin.db          # Django admin database
├── bluecoins.fydb              # Local backup (fallback)
└── schema/
    └── bluecoins_schema.sql    # Reference schema
```

### Backup File Locations

**Cloud Storage Integration**:
- Google Drive: `C:/Users/[User]/Mi unidad/Bluecoins/QuickSync/`
- OneDrive: `C:/Users/[User]/OneDrive/Bluecoins/`
- Dropbox: `C:/Users/[User]/Dropbox/Bluecoins/`

**Local Backup Options**:
- Project directory: `databases/bluecoins.fydb`
- Custom directory: Configure in `find_bluecoins_database()`

## Performance Configuration

### Database Optimization

**Connection Settings**:
- SQLite optimizations for read performance
- Connection pooling not required for SQLite
- Efficient query patterns through ORM

**Query Optimization**:
- Prefetch related objects to avoid N+1 queries
- Use select_related for foreign key relationships
- Implement proper pagination for large datasets

### Static File Optimization

**Development**:
- Django serves static files automatically
- No additional configuration required

**Production**:
- Collect static files: `python manage.py collectstatic`
- Serve through web server (nginx, Apache)
- Configure caching headers

## Environment Configuration

### Development Environment

**Requirements**:
- Python 3.8+
- Django 5.1.5
- openpyxl for Excel generation
- Access to Bluecoins backup files

**Setup Commands**:
```bash
python -m venv venv
venv\Scripts\activate  # Windows
pip install Django==5.1.5 openpyxl
python manage.py migrate
python manage.py runserver
```

### Production Environment

**Additional Requirements**:
- Web server (nginx, Apache)
- WSGI server (gunicorn, uWSGI)
- Process manager (systemd, supervisor)
- SSL certificate for HTTPS

**Configuration Files**:
- `wsgi.py` for WSGI deployment
- Environment variables for sensitive settings
- Web server configuration for static files

## Backup and Recovery

### Database Backup Strategy

**Django Admin Database**:
- Regular SQLite backups
- Django dumpdata for data export
- Migration files for schema backup

**Bluecoins Database**:
- Handled by Bluecoins mobile app
- Cloud storage provides redundancy
- Local copies for offline access

### Recovery Procedures

**Database Corruption**:
- Restore from recent backup
- Re-run migrations if necessary
- Verify data integrity

**Configuration Issues**:
- Reset to default settings
- Check file permissions
- Verify database paths

## Monitoring and Logging

### Database Monitoring

**Connection Status**:
- Monitor database file availability
- Log connection attempts and failures
- Track query performance

**Error Tracking**:
- Database connection errors
- Query execution errors
- File permission issues

### Application Logging

**Log Configuration**:
```python
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'file': {
            'level': 'INFO',
            'class': 'logging.FileHandler',
            'filename': 'bluecoins.log',
        },
    },
    'loggers': {
        'bluecoins_app': {
            'handlers': ['file'],
            'level': 'INFO',
            'propagate': True,
        },
    },
}
```

## Troubleshooting

### Common Issues

**Database Not Found**:
- Check `find_bluecoins_database()` path configuration
- Verify file permissions
- Ensure backup file exists

**Permission Errors**:
- Check file system permissions
- Verify Django can read backup directory
- Ensure write access to admin database

**Performance Issues**:
- Monitor query counts
- Check for N+1 query problems
- Optimize database indexes

### Debug Tools

**Django Debug Mode**:
- Enable with `DEBUG = True`
- Shows detailed error pages
- Displays SQL queries

**Database Inspection**:
- Use Django shell: `python manage.py shell`
- SQLite browser tools
- Database query logging

## Future Enhancements

### Database Improvements

**Connection Pooling**:
- Implement for high-traffic scenarios
- Consider PostgreSQL for production
- Add connection retry logic

**Caching Strategy**:
- Redis/Memcached for query caching
- Template fragment caching
- Static file caching

### Configuration Management

**Environment Variables**:
- Move sensitive settings to environment
- Use django-environ for management
- Separate development/production configs

**Docker Integration**:
- Containerize application
- Docker Compose for development
- Production container deployment
