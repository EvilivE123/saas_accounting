# SaaS Accounting

> This project is a secure, multi-tenant SaaS Accounting Engine built on Ruby on Rails 8 and PostgreSQL. It delivers a strict double-entry general ledger with real-time balance snapshots, automated financial reporting (P&L, Balance Sheet), and interactive dashboards powered by Stimulus JS and Bootstrap 5.

## 🚀 Tech Stack

* **Framework:** Rails 8.1.3
* **Database:** PostgreSQL 16.13 (using Neon for Production)
* **Deployment:** Containerized via "Back4App"

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed on your local machine:
* Ruby (v3.x or higher)
* PostgreSQL
* Node.js & Yarn (for asset management)

---

## 🛠️ Local Development Setup

Follow these steps to get your development environment running:

**1. Clone the repository**
```bash
git clone git@github.com:EvilivE123/saas_accounting.git
cd saas_accounting
```

**2. Install dependencies**
```bash
bundle install
yarn install
```

**3. Database Setup**
```bash
rails db:setup 
(Note: You may need to configure your config/database.yml with your local PostgreSQL credentials if they differ from the default).
```

**4. Start Application**
```bash
bin/dev
```
