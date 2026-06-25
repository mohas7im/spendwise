# Spendwise API Requirements

This document outlines the required API endpoints and JSON structures needed to replace the current `DummyDataService` with a real backend integration.

## Base URL
`/api/v1`

---

## 1. Authentication & User Profile

### GET `/user/profile`
Retrieves the current user's profile and settings.

**Response:**
```json
{
  "id": "u123",
  "name": "Alex Morgan",
  "email": "alex.morgan@example.com",
  "avatar_url": "https://i.pravatar.cc/150?img=11",
  "preferences": {
    "currency": "INR",
    "theme_mode": "dark",
    "budget_rule": {
      "needs_percent": 50,
      "wants_percent": 30,
      "savings_percent": 20
    }
  }
}
```

---

## 2. Transactions

### GET `/transactions`
Retrieves a paginated list of user transactions.

**Query Parameters:**
- `page` (int) - Page number
- `limit` (int) - Items per page
- `startDate` (ISO8601 string)
- `endDate` (ISO8601 string)

**Response:**
```json
{
  "transactions": [
    {
      "id": "tx_1",
      "title": "Netflix Subscription",
      "amount": 499.0,
      "date": "2026-06-25T10:00:00Z",
      "type": "expense",
      "category": {
        "id": "cat_ent",
        "name": "Entertainment",
        "emoji": "🎬",
        "color": "#FF5733"
      },
      "rule_allocation": "wants"
    }
  ],
  "total_pages": 1,
  "current_page": 1
}
```

### POST `/transactions`
Create a new transaction.

**Request:**
```json
{
  "title": "Grocery Shopping",
  "amount": 1250.0,
  "date": "2026-06-25T15:30:00Z",
  "type": "expense",
  "category_id": "cat_food",
  "note": "Weekly vegetables"
}
```

---

## 3. Budgets & Income Setup

### GET `/budget/summary`
Retrieves the user's monthly income, the 50/30/20 breakdown, and current category limits progress.

**Response:**
```json
{
  "monthly_salary": 15000.0,
  "incomes": [
    {
      "id": "inc_1",
      "source": "Company Salary",
      "amount": 15000.0,
      "frequency": "monthly"
    },
    {
      "id": "inc_2",
      "source": "Freelance Design",
      "amount": 3000.0,
      "frequency": "monthly"
    }
  ],
  "rule_breakdown": {
    "needs_budget": 9000.0,
    "wants_budget": 5400.0,
    "savings_budget": 3600.0
  },
  "category_limits": [
    {
      "category_id": "cat_food",
      "name": "Food & Dining",
      "emoji": "🍔",
      "limit_amount": 4000.0,
      "period": "monthly",
      "spent_amount": 2500.0
    }
  ]
}
```

---

## 4. Debts ("I Owe / They Owe")

### GET `/debts`
Retrieves pending and settled debts.

**Response:**
```json
{
  "debts": [
    {
      "id": "debt_1",
      "person_name": "John Doe",
      "amount": 500.0,
      "type": "they_owe",
      "date": "2026-06-20T09:00:00Z",
      "is_settled": false,
      "note": "Lunch yesterday"
    },
    {
      "id": "debt_2",
      "person_name": "Credit Card",
      "amount": 12000.0,
      "type": "i_owe",
      "date": "2026-06-15T00:00:00Z",
      "is_settled": false,
      "due_date": "2026-07-01T00:00:00Z"
    }
  ]
}
```

### PATCH `/debts/{id}/settle`
Marks a specific debt as paid.

**Request:**
```json
{
  "is_settled": true
}
```

---

## 5. Analytics & Stats

### GET `/analytics/spending`
Retrieves aggregated spending data for charts.

**Query Parameters:**
- `period` (weekly | monthly | yearly)

**Response:**
```json
{
  "total_spent": 18450.0,
  "bar_chart_data": [
    { "label": "Mon", "value": 12000.0 },
    { "label": "Tue", "value": 8000.0 },
    { "label": "Wed", "value": 15000.0 }
  ],
  "top_categories": [
    {
      "category": "Food & Dining",
      "emoji": "🍔",
      "spent": 4500.0,
      "percentage_of_total": 0.45
    }
  ]
}
```
