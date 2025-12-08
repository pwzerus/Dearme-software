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

**Ubuntu / Debian**

`sudo service postgresql start`

**macOS (Homebrew)**

` brew services start postgresql`

* * * * *

### 2️⃣ Set Password For `postgres` User

Open the PostgreSQL shell:

`sudo -u postgres psql`

Inside the `psql` prompt:

`ALTER USER postgres WITH PASSWORD 'your_password_here';`

* * * * *

### 3️⃣ Set Database Environment Variables

In your terminal session, set:

```
export PGUSER=postgres

export PGPASSWORD=your_password_here

export PGHOST=localhost

```

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

```
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
```

Save the file.

> 🔒 **Important**\
> Do not commit these values to Git, GitHub, or any public place.

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

Production Token Encryption Key (for Sharing)
============================================

In production, the application uses a symmetric encryption key to encode and decode sharing tokens. 
This key must be generated locally and stored in the TOKEN_ENCRYPTOR_STRICT_BASE64_ENCODED_KEY environment variable on Heroku.

Follow these steps to generate it:

1. Open a Rails console:

    bin/rails console

2. Get the required key length:

    len = ActiveSupport::MessageEncryptor.key_len

3. Generate a random salt:

    salt = SecureRandom.random_bytes(len)

4. Load your Google client secret (must already be in your environment):

    secret = ENV["GOOGLE_CLIENT_SECRET"]

5. Generate the binary encryption key:

    key = ActiveSupport::KeyGenerator.new(secret).generate_key(salt, len)

6. Base64-encode the key so it is safe to store:

    encoded = Base64.strict_encode64(key)

7. Copy the encoded string and add it to your Heroku Config Vars:

    TOKEN_ENCRYPTOR_STRICT_BASE64_ENCODED_KEY = <value from step 6>

8. Optional: Verify the encoded key decodes correctly:

    decoded = Base64.strict_decode64(encoded)
    key == decoded   # should return true


Deploying the Application to Heroku
===================================

These steps assume you have a working local environment and can run the application locally.

1. Create the Heroku App and Heroku Postgres database:

   - Go to the Heroku Dashboard.
   - Create a new app.
   - Open the Resources tab.
   - Add the Heroku Postgres add-on using the Essential-0 plan or higher.

2. Add the required configuration variables in Heroku → Settings → Config Vars:

   GOOGLE_CLIENT_ID
   GOOGLE_CLIENT_SECRET
   TOKEN_ENCRYPTOR_STRICT_BASE64_ENCODED_KEY
   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY

3. Log in to Heroku from your local machine:

    heroku login

4. Set the Heroku git remote (from inside your project folder):

    heroku git:remote -a your-heroku-app-name

5. Ensure the project contains a Procfile in the top-level directory with the following:

    release: bundle exec rails db:migrate && bundle exec rails db:seed
    web: bundle exec rails server -p $PORT

   Note: The release command should only run idempotent seeds.

6. Deploy the application:

    git push heroku main

   Heroku will build the application, run any release-phase commands, and start the web dyno.

7. Verify the deployment:

   - Open the deployed app URL in your browser.
   - Log in with a Google account that has been added as a test user in the Google Cloud OAuth settings.
   - Ensure you can reach the dashboard and use the application normally.


Configuring AWS S3 for Production File Storage
==============================================

1. Create an S3 bucket:

   - Open the AWS console and search for “S3”.
   - Create a new bucket.
   - Choose a unique bucket name such as “dearme-production-uploads”.
   - Select a region (example: us-east-1).
   - Leave the remaining settings as defaults for a private bucket.

2. Create an IAM user with S3 permissions:

   - Open the IAM service in AWS.
   - Create a new user (example: dearme-s3-user).
   - Attach the policy AmazonS3FullAccess or a more restrictive bucket-specific policy.
   - After creation, open the user, go to Security Credentials, and generate an access key.
   - Save the Access Key ID and Secret Access Key.

3. Add these credentials to the Heroku Config Vars:

   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY

4. Configure Rails to use S3 in production:

   In config/environments/production.rb:

       config.active_storage.service = :amazon

   In config/storage.yml ensure the amazon service looks like this:

       amazon:
         service: S3
         access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
         secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
         region: your-region-here
         bucket: your-bucket-name-here

5. Deploy updated configuration:

    git push heroku main

6. Verify uploads:

   - Log in to the production application.
   - Upload an image or video.
   - Confirm that the upload succeeds and appears in your AWS S3 bucket.


This completes the production deployment steps: generating the encryption key, deploying to Heroku, configuring AWS S3, and verifying the application in a production environment.
* * * * *

📝 Notes
--------

-   Never commit secrets like `GOOGLE_CLIENT_SECRET`, database passwords, or `.env` files

-   For team development, share only template files `.env`

* * * * *
