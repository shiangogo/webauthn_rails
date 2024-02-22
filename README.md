# webauthn_rails
**Note: This is a demo site for practice purposes only and should not be deployed in a production environment.**
This is a simple website built with Rails, demonstrating Webauthn.

## Requirements
Make sure that:
 - Ruby version 3.2.2
 - Rails 7.0.8 or above

## Installation
1. Clone this repo to your local machine.
  ```bash
  git clone git@github.com:shiangogo/webauthn_rails.git
  ```

2. Nevigate to the project directory.
  ```bash
  cd webauthn_rails
  ```

3. Install dependencies
  ```bash
  bundle
  ```

4. Set up the database. It's just a simple demo site, so I chose sqlite3.
  ```bash
  rails db:create
  rails db:migrate
  ```

5. Start the Rails server.
  ```bash
  rails s
  ```

6. Then, open your browser and visit `http://localhost:3000` to see the website.

## Usage
