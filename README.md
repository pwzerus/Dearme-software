# README

Project 3 Group 4 - DearMe
===============================================

This application is designed for sharing personal photos and videos privately, helping you create and preserve memories without any social media pressure, likes, comments, or public interactions.
You simply upload your moments, save them for yourself, and when you want, you can share them with friends, family, or others so they can relive those memories with you — no algorithms, no followers, just memories.

This is a Ruby on Rails 8 web application that uses **Google OAuth 2.0** for authentication and **PostgreSQL** as the database.\
Users sign in with their Google account to access a protected dashboard.

* * * * *

📎 Overview
-----------

-   Secure login using Google OAuth 2.0

-   PostgreSQL as the backing database

-   Rails 8 conventions and MVC structure

* * * * *

✅ Requirements
--------------

Make sure you have the following installed:

-   **Ruby** (version in `.ruby-version` )

-   **Rails 8**

-   **PostgreSQL**

-   **Git**

-   A **Google account** to create OAuth credentials

* * * * *

🔗 Clone The Repository
-----------------------

`git clone https://github.com/tamu-edu-students/project3-group4-repo.git
cd project3-group4-repo`

* * * * *

📦 Install Dependencies
-----------------------

Install all Ruby gems:

`bundle install`

If `bundler` is missing:

`gem install bundler`

* * * * *

PostgreSQL Setup
-------------------

### 1️⃣ Install PostgreSQL

**Ubuntu / Debian**

`sudo apt update
sudo apt install postgresql postgresql-contrib`

**macOS (Homebrew)**

`brew install postgresql
brew services start postgresql`

Make sure the PostgreSQL server is running before you continue. (run the below command if the postgresql is already installed)

`sudo service postgresql start`

* * * * *

### 2️⃣ Set Password For `postgres` User

Open the PostgreSQL shell:

`sudo -u postgres psql`

Inside the `psql` prompt:

`ALTER USER postgres WITH PASSWORD 'your_password_here';
\q`

* * * * *

### 3️⃣ Set Database Environment Variables

In your terminal session, set:

`export PGUSER=postgres
export PGPASSWORD=your_password_here
export PGHOST=localhost`

These must be set in every terminal where you run Rails commands.
These command shall be run after starting the postgres server. (i.e, these commands shall be executed sequentially when you start working with ubuntu in a new terminal/session)

* * * * *

🔑 **Google OAuth Setup**
-------------------------

The app uses Google OAuth via the callback URLs:

`http://localhost:3000/auth/google_oauth2/callback`\
`http://127.0.0.1:3000/auth/google_oauth2/callback`

* * * * *

### **1️⃣ Create OAuth Credentials in Google Cloud Console**

#### **Step 1 --- Open the Google Cloud Console**

Go to:\
👉 **<https://console.cloud.google.com>**

Make sure you are logged in with your Google account.

* * * * *

### **Step 2 --- Create a New Project (or Select an Existing One)**

At the top-left corner:

1.  Click the **Project Selector** dropdown

2.  Press **New Project**

3.  Enter:

    -   **Project name** → for example: `Rails-Google-OAuth-App`

    -   **Organization** → leave default (for personal Google accounts)

4.  Click **Create**

⭐ *If you already have a project created earlier, you may select it instead.\
Just ensure that everyone on your team uses the **same project** for OAuth setup.*

* * * * *

### **Step 3 --- Open the OAuth Consent Screen**

In the left sidebar:

**APIs & Services → OAuth Consent Screen**

* * * * *

### **Step 4 --- Set User Type**

Choose:

-   **External** → recommended for local development and team usage

Click **Create**.

* * * * *

### **Step 5 --- Configure OAuth Consent Screen (Important)**

You must fill out the following fields:

-   **App name** → Choose anything (ex: `Memories App Local OAuth`)

-   **User support email** → Your Google email

-   **Developer contact email** → Your Google email

-   **App logo** (optional)

-   **App domain** (optional for local dev)

Scroll down, click **Save and Continue**.

You will then reach the **Scopes** page:

-   Leave scopes **as default** for now

-   Click **Save and Continue**

You will reach the **Test Users** page:

* * * * *

### ⭐ Add Team Members (Required for Development Mode)

Since the app uses "External" user type **and is in Testing mode**, only **test users** can sign in.

1.  In the **Test Users** section of the OAuth consent screen

2.  Click **Add Users**

3.  Enter the **email addresses of all team members** who need to test login

    -   Example:

        -   `yourname@gmail.com`

        -   `teammate@gmail.com`

        -   `anothermember@gmail.com`

4.  Click **Save**

All added users can now sign in using Google OAuth during development.

⚠️ **Important:**\
If a team member is not added as a test user, they will get:

> "Error 403: access_denied --- This app is not verified"

* * * * *

### **Step 6 --- Open Credentials Page**

Left menu:

**APIs & Services → Credentials**

* * * * *

### **Step 7 --- Create OAuth Client ID**

Click:

**Create Credentials → OAuth Client ID**

* * * * *

### **Step 8 --- Choose Application Type**

Choose:

-   **Web Application**

Enter a name like:

-   `Rails Local OAuth Client`

* * * * *

### **Step 9 --- Add Authorized Redirect URIs**

Under **Authorized redirect URIs**, add:

`http://localhost:3000/auth/google_oauth2/callback`\
`http://127.0.0.1:3000/auth/google_oauth2/callback`

These are required for local development.

* * * * *

### **Step 10 --- Create Credentials**

Click **Create**.

Google will show:

-   **Client ID**

-   **Client Secret**

Copy both.

* * * * *

### **Step 11 --- Store Client ID and Secret Key in `.env` File**

After Google shows you the **Client ID** and **Client Secret**, you must add them to your local environment.

Inside the **project root folder**, create a file named:

`.env`

Then add the following lines:

`GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here

Save the file.

> 🔒 **Important**\
> Do not commit these values to Git, GitHub, or any public place.
Make sure your environment is configured to load this file.

* * * * *

🛠 Database Setup
-----------------

From the project root:

### Create the database

`bin/rails db:create`

### Run migrations

`bin/rails db:migrate`

Or use:

`bin/rails db:prepare`

This will create and migrate the database in one step.

* * * * *

🚀 Run The App Locally
----------------------

Start the Rails server:

`bin/rails server`

Open your browser and visit:

`http://localhost:3000`

You should see the login page with a **Continue with Google** button.

Flow:

1.  Click **Continue with Google**

2.  Sign in with your Google account

3.  Approve the requested permissions

4.  You will be redirected back to the app and taken to your dashboard

* * * * *

🧪 Test Suite
------------------------

The tests shall be executed using the below commands:

### RSpec

`bundle exec rspec`

### Cucumber

`bundle exec cucumber`


* * * * *

🧰 Useful Commands
------------------

* * * * *

| Task | Command |
| --- | --- |
| **Start Rails server** | `rails server` |
| **Start PostgreSQL server (Ubuntu/Debian)** | `sudo service postgresql start` |
| **Start PostgreSQL server (macOS Homebrew)** | `brew services start postgresql` |
| **Set PostgreSQL username** | `export PGUSER=postgres` |
| **Set PostgreSQL password** | `export PGPASSWORD=your_password_here` |
| **Set PostgreSQL host** | `export PGHOST=localhost` |
| **Create database** | `rails db:create` |
| **Run migrations** | `rails db:migrate` |
| **Prepare db (create + migrate)** | `rails db:prepare` |
| **Run RSpec tests** | `bundle exec rspec` |
| **Run Cucumber tests** | `bundle exec cucumber` |
| **Prepare test database** | `RAILS_ENV=test bin/rails db:prepare` |

* * * * *

🩺 Troubleshooting
------------------

### PostgreSQL connection errors

Common things to check:

-   Is the PostgreSQL service running

-   Are `PGUSER`, `PGPASSWORD`, and `PGHOST` set correctly

-   Can you connect manually with `psql`

### `redirect_uri_mismatch` or Google login failure

-   Verify that the redirect URI in the Google Cloud Console **exactly** matches:

    `http://localhost:3000/auth/google_oauth2/callback`

-   Check that `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` are set in the shell where you run `bin/rails server`

### Environment variables not found

-   Run `export` commands in the same terminal where you start Rails

-   If using `.env`, ensure your environment is actually loading it

* * * * *

📝 Notes
--------

-   Never commit secrets like `GOOGLE_CLIENT_SECRET`, database passwords, or `.env` files

-   For team development, share only template files `.env`

-   This app is designed for local development first, and can be adapted for deployment later

* * * * *
