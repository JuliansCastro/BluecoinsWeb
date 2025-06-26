# URL Configuration Documentation

## Overview

The URL configuration defines the routing structure for the Bluecoins Web Project, mapping URLs to their corresponding view functions and classes.

## URL Structure

### Main Project URLs (`bluecoinsWeb_project/urls.py`)

```python
urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('bluecoins_app.urls')),
]
```

**Root Configuration**:
- Django admin interface at `/admin/`
- All app URLs included at root level (`/`)

### Application URLs (`bluecoins_app/urls.py`)

#### Core Endpoints

| URL Pattern | View | Name | Purpose |
|-------------|------|------|---------|
| `/` | `home_view` | `home` | Landing page |
| `/transactions/` | `TransactionsListView.as_view()` | `transactions_list` | Transaction listing |
| `/transactions/<int:pk>/` | `TransactionDetailView.as_view()` | `transaction_detail` | Individual transaction |
| `/transactions/new/` | `TransactionCreateView.as_view()` | `transaction_create` | Create transaction |
| `/transactions/<int:pk>/edit/` | `TransactionUpdateView.as_view()` | `transaction_update` | Edit transaction |
| `/transactions/<int:pk>/delete/` | `TransactionDeleteView.as_view()` | `transaction_delete` | Delete transaction |

#### Reporting Endpoints

| URL Pattern | View | Name | Purpose |
|-------------|------|------|---------|
| `/reports_by_category/` | `ReportByCategoryView` | `report_by_category` | Category analysis |
| `/reports_by_label/` | `report_by_label_excel` | `report_by_label` | Excel export |

## URL Parameters

### Path Parameters

**Transaction ID (`<int:pk>`)**:
- Used in detail, edit, and delete operations
- Django automatically converts to integer
- Validates numeric input

### Query Parameters

**Filtering Parameters**:
- `label`: Filter transactions by label name
- `page`: Pagination page number

**Usage Examples**:
```
/transactions/?label=groceries
/transactions/?page=2
/transactions/?label=transportation&page=3
```

## Named URL Patterns

### Template Usage

**URL Reversal in Templates**:
```django
{% url 'home' %}
{% url 'transactions_list' %}
{% url 'transaction_detail' transaction.pk %}
{% url 'transaction_update' transaction.pk %}
{% url 'report_by_label' %}?label={{ label }}
```

**JavaScript URL Generation**:
```javascript
const reportUrl = `{% url 'report_by_label' %}?label=${encodeURIComponent(selectedLabel)}`;
const transactionsUrl = `{% url 'transactions_list' %}?label=${encodeURIComponent(selectedLabel)}`;
```

### View Usage

**Redirect URLs**:
```python
success_url = reverse_lazy('transactions_list')
```

## RESTful Design Principles

### Resource-Based URLs

**Transaction Management**:
- `GET /transactions/` - List all transactions
- `GET /transactions/123/` - Get specific transaction
- `POST /transactions/new/` - Create new transaction
- `PUT /transactions/123/edit/` - Update transaction
- `DELETE /transactions/123/delete/` - Delete transaction

### HTTP Methods

**Supported Methods**:
- `GET`: Retrieve data (list, detail, forms)
- `POST`: Create or update data
- Standard HTML form methods only (no PUT/PATCH/DELETE in browser)

## AJAX Endpoint Behavior

### Content Negotiation

**Request Headers**:
- `X-Requested-With: XMLHttpRequest` - Indicates AJAX request
- Determines response format (JSON vs HTML)

**Response Formats**:
```python
if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
    return JsonResponse({
        'transactions_html': rendered_html,
        'has_more': has_more_pages,
        'page_number': page_number
    })
else:
    return render(request, template_name, context)
```

## Security Considerations

### CSRF Protection

**Form Submissions**:
- All POST requests require CSRF tokens
- Django middleware handles token validation
- Templates include `{% csrf_token %}` for forms

**AJAX Requests**:
- Include CSRF token in request headers
- Use Django's CSRF cookie for protection

### URL Validation

**Parameter Validation**:
- Path parameters validated by Django URL patterns
- Query parameters sanitized in view logic
- Integer constraints for primary keys

## Error Handling

### HTTP Status Codes

**Standard Responses**:
- `200 OK`: Successful GET requests
- `302 Found`: Successful POST redirects
- `404 Not Found`: Missing resources
- `405 Method Not Allowed`: Invalid HTTP methods

**Custom Error Pages**:
- Custom 404 templates for missing transactions
- Error handling in AJAX responses

### URL Resolution Errors

**Invalid URLs**:
- Django returns 404 for unmatched patterns
- Invalid parameter types return 404
- Missing required parameters return 404

## Internationalization

### URL Prefixes

**Language Support** (if enabled):
```python
# Future enhancement
urlpatterns = [
    path('en/', include('bluecoins_app.urls')),
    path('es/', include('bluecoins_app.urls')),
]
```

**Current Implementation**:
- Single language support
- No URL prefixes required
- Ready for i18n expansion

## Performance Considerations

### URL Optimization

**Efficient Patterns**:
- Specific patterns before general ones
- Avoid complex regex patterns
- Use `path()` over `re_path()` when possible

**Caching**:
- URL resolution cached by Django
- Named URL patterns cached
- Reverse URL lookups optimized

## Development and Debugging

### URL Debugging

**Django Debug Mode**:
- Shows available URL patterns on 404 errors
- Highlights URL resolution process
- Displays pattern matching attempts

**URL Testing**:
```python
from django.test import TestCase
from django.urls import reverse

class URLTests(TestCase):
    def test_transaction_list_url(self):
        url = reverse('transactions_list')
        self.assertEqual(url, '/transactions/')
    
    def test_transaction_detail_url(self):
        url = reverse('transaction_detail', args=[123])
        self.assertEqual(url, '/transactions/123/')
```

### Common Patterns

**URL Generation in Views**:
```python
from django.urls import reverse
from django.http import HttpResponseRedirect

def my_view(request):
    # ... processing ...
    return HttpResponseRedirect(reverse('transactions_list'))
```

**Dynamic URL Building**:
```python
from django.urls import reverse
from urllib.parse import urlencode

def build_filter_url(label=None, page=None):
    url = reverse('transactions_list')
    params = {}
    if label:
        params['label'] = label
    if page:
        params['page'] = page
    if params:
        url += '?' + urlencode(params)
    return url
```

## Future Enhancements

### API Endpoints

**RESTful API** (potential addition):
```python
# api/urls.py
urlpatterns = [
    path('api/v1/transactions/', TransactionListAPIView.as_view()),
    path('api/v1/transactions/<int:pk>/', TransactionDetailAPIView.as_view()),
    path('api/v1/reports/category/', CategoryReportAPIView.as_view()),
    path('api/v1/reports/label/', LabelReportAPIView.as_view()),
]
```

### Versioning

**API Versioning**:
- URL-based versioning (`/api/v1/`)
- Header-based versioning
- Backward compatibility considerations

### Additional Resources

**Potential Endpoints**:
- `/accounts/` - Account management
- `/categories/` - Category management  
- `/labels/` - Label management
- `/reports/custom/` - Custom report builder

## Best Practices

### URL Design

**Guidelines**:
- Use descriptive, lowercase URLs
- Separate words with hyphens, not underscores
- Keep URLs short and memorable
- Use plural nouns for collections
- Use singular nouns for specific resources

**Examples**:
```
✓ /transactions/
✓ /reports-by-category/
✗ /transaction_list/
✗ /GetTransactionById/
```

### Maintainability

**Organization**:
- Group related URLs together
- Use consistent naming patterns
- Document complex URL patterns
- Keep URL configurations DRY (Don't Repeat Yourself)

**Testing**:
- Test all URL patterns
- Verify parameter validation
- Check error handling
- Test URL reversal
