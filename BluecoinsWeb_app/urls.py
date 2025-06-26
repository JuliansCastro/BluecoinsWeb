# bluecoins_app/urls.py

from django.urls import path
from . import views
from .views import report_by_label_excel


urlpatterns = [
    path('', views.home_view, name='home'),
    path('transactions/', views.TransactionsListView.as_view(), name='transactions_list'),
    path('transactions/<int:pk>/', views.TransactionDetailView.as_view(), name='transaction_detail'),
    path('transactions/new/', views.TransactionCreateView.as_view(), name='transaction_create'),
    path('transactions/<int:pk>/edit/', views.TransactionUpdateView.as_view(), name='transaction_update'),
    path('transactions/<int:pk>/delete/', views.TransactionDeleteView.as_view(), name='transaction_delete'),
    path('reports_by_category/', views.ReportByCategoryView,  name='report_by_category'),
    path('reports_by_label/', report_by_label_excel, name='report_by_label'),
]
