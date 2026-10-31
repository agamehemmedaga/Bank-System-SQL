# 🏦 Bank System (PostgreSQL)

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue?style=for-the-badge)
![SQL](https://img.shields.io/badge/SQL-PL%2FpgSQL-orange?style=for-the-badge)

A PostgreSQL database schema for a simple banking system, with a transactional stored procedure that safely transfers money between accounts.

## 🧩 Database Schema

| Table | Purpose |
|-------|---------|
| `accounts` | Customers and their balances (`balance >= 0` enforced) |
| `transfers` | Record of every money transfer between two accounts |
| `transaction_history` | Per-account `DEPOSIT` / `WITHDRAW` log |

## ⚙️ Transfer Procedure

`make_transfer(sender_id, receiver_id, amount)` is a PL/pgSQL stored procedure that:

- Validates the amount (must be positive) and that sender and receiver differ
- Locks the sender row (`FOR UPDATE`) to prevent overspending in concurrent transfers
- Checks the sender exists and has sufficient funds, and that the receiver exists
- Updates both balances and writes to `transfers` and `transaction_history`
- Runs as a single transaction: any error rolls back all changes automatically

## 🚀 Getting Started

### Prerequisites

- PostgreSQL 14 or newer

### Run

```bash
createdb bank
psql -d bank -f Bank.sql
```

The script creates the tables, inserts two sample accounts and runs two demo transfers.

## 🖥️ Example

```sql
CALL make_transfer(1, 2, 150.00);

CALL make_transfer(1, 2, 400.00);
```

## 💡 Concepts Demonstrated

- Relational design with primary/foreign keys and `CHECK` constraints
- Stored procedures in PL/pgSQL
- Transaction safety and row-level locking
- Input validation and error handling inside the database

## 👤 Author

**Aga** - Java Backend Developer
GitHub: [agamehemmedaga](https://github.com/agamehemmedaga)
