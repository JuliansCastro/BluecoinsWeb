# bluecoins_app/views.py
# Create your views here.

import locale
from datetime import datetime
from django.shortcuts import render
from collections import defaultdict, Counter
from django.urls import reverse_lazy
from django.http import JsonResponse
from django.http import HttpResponse
from django.db.models import Prefetch
from django.db.models import Sum, Case, When
from django.core.paginator import Paginator
from django.utils.timezone import localtime
from django.utils.formats import date_format
from django.shortcuts import get_object_or_404
from django.views.generic import ListView, DetailView, CreateView, UpdateView, DeleteView
from openpyxl import Workbook
import calendar

from .models import Accounts_table, Transactions_table, Child_category_table, Labels_table


# Set the local language for month names to Spanish (with fallback)
def set_spanish_locale():
    """
    Try to set Spanish locale for month names, fallback to default if not available.
    """
    spanish_locales = [
        'es_ES.UTF-8',      # Linux/Mac
        'es_ES',            # Linux/Mac alternative
        'Spanish_Spain.1252', # Windows
        'Spanish',          # Windows alternative
        'esp',              # Some systems
    ]
    
    for locale_name in spanish_locales:
        try:
            locale.setlocale(locale.LC_TIME, locale_name)
            print(f"Successfully set locale to: {locale_name}")
            return locale_name
        except locale.Error:
            continue
    
    # If no Spanish locale is available, keep the default
    print("Warning: No Spanish locale available, using system default")
    return None

# Attempt to set Spanish locale
set_spanish_locale()


class TransactionsListView(ListView):
    model = Transactions_table
    template_name = 'transactions_list.html'
    context_object_name = 'transactions'
    paginate_by = 50  # A lower value can give better visual feedback

    def get_queryset(self):
        """
        Returns the queryset of transactions. If there is a label, pagination is
        handled right here. If not, the full queryset is returned for ListView to paginate.
        """
        label = self.request.GET.get('label')

        # Optimization: We use prefetch_related to avoid N+1 queries to the labels table.
        labels_prefetch = Prefetch(
            'labels_table_set',
            queryset=Labels_table.objects.all(),
            to_attr='prefetched_labels'
        )

        if label:
            tx_ids_qs = (Labels_table.objects
                         .filter(label_name=label)
                         .values_list('transaction_id_labels', flat=True)
                         .distinct())

            # We order the IDs by transaction date (most recent first)
            tx_ids = list(Transactions_table.objects.filter(transactions_table_id__in=tx_ids_qs).order_by(
                '-date').values_list('transactions_table_id', flat=True))

            paginator = Paginator(tx_ids, self.paginate_by)
            page_number = self.request.GET.get('page', 1)
            page_obj = paginator.get_page(page_number)

            # We save the page_obj to use it in get_context_data and render_to_response
            self._label_page_obj = page_obj

            page_tx_ids = list(page_obj.object_list)

            if not page_tx_ids:
                return Transactions_table.objects.none()

            # We keep the correct order using Case/When
            preserved_order = Case(
                *[When(transactions_table_id=pk, then=pos) for pos, pk in enumerate(page_tx_ids)])
            qs = Transactions_table.objects.filter(transactions_table_id__in=page_tx_ids).order_by(
                preserved_order).prefetch_related(labels_prefetch)
            return qs
        else:
            # If there is no filter, we return the full queryset and let ListView paginate
            return Transactions_table.objects.all().order_by('-date').prefetch_related(labels_prefetch)

    def get_context_data(self, **kwargs):
        """
        Builds the context. Prevents double pagination when filtering by label.
        """
        label = self.request.GET.get('label')

        if label:
            # Manual pagination for label filter
            queryset = self.get_queryset()
            label_page_obj = getattr(self, '_label_page_obj', None)
            context = {
                'object_list': queryset,
                'transactions': queryset,
                'page_obj': label_page_obj,
                'is_paginated': bool(label_page_obj and label_page_obj.has_other_pages()),
                'paginator': label_page_obj.paginator if label_page_obj else None,
            }
        else:
            # If there is no label, we use the normal and efficient ListView behavior.
            context = super().get_context_data(**kwargs)

        # This processing is common for both cases
        transactions_by_date = defaultdict(list)
        for tx in context['object_list']:
            date_obj = localtime(tx.date) if tx.date else None
            formatted_date = date_format(
                date_obj, format='D, d \\d\\e F \\d\\e Y', use_l10n=True).capitalize() if date_obj else "Sin fecha"

            tx.formatted_amount = (tx.amount or 0) / 1000000

            # Thanks to prefetch, this no longer makes a new DB query for each transaction
            tx.labels = tx.prefetched_labels

            transactions_by_date[formatted_date].append(tx)

        context['transactions_by_date'] = dict(transactions_by_date)
        context['all_labels'] = Labels_table.objects.values_list(
            'label_name', flat=True).distinct().order_by('label_name')
        context['selected_label'] = label or ''

        return context

    def render_to_response(self, context, **response_kwargs):
        """
        Handles AJAX responses for infinite scroll.
        """
        if self.request.headers.get('x-requested-with') == 'XMLHttpRequest':
            transactions_html = self.render_partial(context)

            page_obj = context.get('page_obj')
            has_more = page_obj.has_next() if page_obj else False

            # We return the partial HTML and whether there are more pages.
            return JsonResponse({'transactions_html': transactions_html, 'has_more': has_more})

        return super().render_to_response(context, **response_kwargs)

    def render_partial(self, context):
        """
        Renders only the HTML fragment with the list of transactions.
        """
        from django.template.loader import render_to_string
        partial_context = {
            'transactions_by_date': context.get('transactions_by_date', {}),
        }
        return render_to_string('transactions_partial.html', partial_context, request=self.request)


class TransactionDetailView(DetailView):
    model = Transactions_table
    template_name = 'transaction_detail.html'
    context_object_name = 'transaction'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        transaction = self.get_object()
        # Safely get amount attribute
        amt_val = (getattr(transaction, 'amount', 0) or 0)
        formatted_amount = amt_val / 1000000

        # Get associated tags (Labels)
        context['formatted_amount'] = formatted_amount
        context['labels'] = Labels_table.objects.filter(transaction_id_labels=transaction)
        
        # Add transaction type information for easier template logic
        transaction_type_str = str(transaction.transaction_type_id).lower() if transaction.transaction_type_id else ""
        context['is_expense'] = 'expense' in transaction_type_str or 'gasto' in transaction_type_str
        context['is_transfer'] = 'transfer' in transaction_type_str or 'transferencia' in transaction_type_str
        context['is_income'] = 'income' in transaction_type_str or 'ingreso' in transaction_type_str

        return context
    

class TransactionCreateView(CreateView):
    model = Transactions_table
    # Add here all the fields you want to handle in the form:
    # For example:
        
    fields = [
        'item_id',
        'date',
        'amount',
        'transaction_currency',
        'notes',
        'transaction_type_id',
        'category_id',
        'account_id',
    ]
    template_name = 'transaction_form.html'
    success_url = reverse_lazy('transactions_list')


class TransactionUpdateView(UpdateView):
    model = Transactions_table
    fields = [
        'item_id',
        'amount',
        'transaction_currency',
        'notes',
        'transaction_type_id',
        'category_id',
        'account_id',
        # ...
    ]
    template_name = 'transaction_detail.html'
    success_url = reverse_lazy('transactions_list')

class TransactionDeleteView(DeleteView):
    model = Transactions_table
    template_name = 'transaction_confirm_delete.html'
    success_url = reverse_lazy('transactions_list')


# Views for accounts
class AccountListView(ListView):
    model = Accounts_table
    template_name = 'accounts_list.html'  # your template
    context_object_name = 'accounts'
    
    def get_queryset(self):
        # To use the "bluecoins" DB explicitly:
        # return Accounts_table.objects.using('bluecoins').all()
        return Accounts_table.objects.all()

class AccountDetailView(DetailView):
    model = Accounts_table
    template_name = 'account_detail.html'

# class AccountCreateView(CreateView):
#     model = Accounts_table
#     fields = ['account_name', 'account_type_id', 'account_currency']  # etc.
#     template_name = 'account_form.html'
#     success_url = reverse_lazy('accounts_list')

# class AccountUpdateView(UpdateView):
#     model = Accounts_table
#     fields = ['account_name', 'account_type_id', 'account_currency']  # etc.
#     template_name = 'account_form.html'
#     success_url = reverse_lazy('accounts_list')

# class AccountDeleteView(DeleteView):
#     model = Accounts_table
#     template_name = 'account_confirm_delete.html'
#     success_url = reverse_lazy('accounts_list')


# Other views of reports, analytics, etc.

def ReportByCategoryView(request):
    data = (Transactions_table.objects
            .values('category_id')
            .annotate(total_amount=Sum('amount'))
            .order_by('-total_amount'))
    
    # Get the category names
    # (Assuming category:id of Transactions_table is FK to Child_category_table)
    # To map to the names, we do something like:
    categories_data = []
    for item in data:
        category_id = item['category_id']
        total_amount = item['total_amount'] or 0
        try:
            category_name = Child_category_table.objects.get(pk=category_id).child_category_name
        except Child_category_table.DoesNotExist:
            category_name = "Unknown"
        categories_data.append((category_name, total_amount))
        #print(f'Category: {category_name} - Total amount: {total_amount}')
    return render(request, 'report_by_category.html', {'categories_data': categories_data})



def home_view(request):
    return render(request, 'home.html')


def report_by_label_excel(request):
    """
    Generates an Excel report of transactions filtered by label, grouped by month in separate sheets.
    """
    label = request.GET.get('label')
    
    # Filter transactions by label if provided
    if label and label.strip():  # Check that label is not empty or whitespace
        tx_ids = Labels_table.objects.filter(label_name=label) \
            .values_list('transaction_id_labels', flat=True).distinct()
        qs = Transactions_table.objects.filter(transactions_table_id__in=tx_ids).order_by('date')
    else:
        qs = Transactions_table.objects.all().order_by('date')

    # Identify duplicates by item_id for transfer handling
    item_counts = Counter(qs.values_list('item_id', flat=True))

    # Group transactions by month-year
    data_by_month = {}
    for tx in qs:
        # For transfers with duplicates, include only the negative record
        if item_counts[tx.item_id] > 1 and (tx.amount or 0) > 0:
            continue
        date = tx.date
        sheet_name = date.strftime('%B %Y') if date else 'Undated'
        data_by_month.setdefault(sheet_name, []).append(tx)    # Check if there are any transactions to process
    if not data_by_month:
        # If no transactions found, render a template with the message instead of downloading a file
        return render(request, 'no_transactions_report.html', {'label': label})
    
    # Build Excel workbook only if there are transactions
    wb = Workbook()
    # Remove default sheet safely
    first_sheet = wb.active
    if first_sheet:
        wb.remove(first_sheet)
    
    for sheet_name, transactions in data_by_month.items():
        ws = wb.create_sheet(title=sheet_name)        
        # Header row
        ws.append(['ID Transaction', 'Date', 'Transaction name', 'Income', 'Expense', 'Transaction type'])
        for tx in transactions:
            # Convert amount from micro-units
            amt = (tx.amount or 0) / 1000000
            income = amt if amt > 0 else ''
            expense = -amt if amt < 0 else ''            # Convert model objects to strings safely
            transaction_name = str(tx.item_id) if tx.item_id else ''
            transaction_type = str(tx.transaction_type_id) if tx.transaction_type_id else ''
            
            ws.append([
                tx.transactions_table_id,
                tx.date.strftime('%d/%m/%Y') if tx.date else '',
                transaction_name,
                income,
                expense,
                transaction_type,
            ])

    # Prepare HTTP response
    response = HttpResponse(
        content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    )
    filename = f"report_by_label_{label or 'all'}.xlsx"
    response['Content-Disposition'] = f'attachment; filename="{filename}"'
    wb.save(response)
    return response