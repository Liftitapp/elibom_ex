# ElibomEx

[![Build Status](https://travis-ci.org/Liftitapp/elibom_ex.svg?branch=master)](https://travis-ci.org/Liftitapp/elibom_ex)

Elixir wrapper for delivering and managing your Elibom's API.

## Installation

ElibomEx can be installed from Hex:

```elixir
def deps do
  [{:elibom_ex, "~> 0.1.0"}]
end
```

Or from Github

```elixir
def deps do
  [{:elibom_ex, github: "liftitapp/elibom_ex"}]
end
```

## Configuration

In one of your configuration files, include your Elibom API key, for example:

```elixir
config :elibom_ex, username:  {:system, "ELIBOM_USERNAME"},
                   password: {:system, "ELIBOM_USERNAME"}
```

For security, I recommend that you use environment variables rather than hard
coding your account credentials. If you don't already have an environment
variable manager, you can create a `.env` file in your project with the
following content:

```bash
export ELIBOM_USERNAME=<account email here>
export ELIBOM_PASSWORD=<api token>
```

Then, just be sure to run `source .env` in your shell before compiling your
project.

### Multiple Environments
If you want to use different Twilio credentials for different environments, then
create separate Mix configuration files for each environment. To do this, change
`config/config.exs` to look like this:

```elixir
# config/config.exs

use Mix.Config

# shared configuration for all environments here ...

import_config "#{Mix.env}.exs"
```

Then, create a `config/#{environment_name}.exs` file for each environment. You
can then set the `config :elibom_ex` variables differently in each file.

## Usage

Check the [docs](https://hexdocs.pm/elibom_ex/) for complete usage.

```elixir
# Dispatch a new SMS
ElibomEx.send_sms(%{to: "573140000000", text: "Hi from Elibom"})

# You can also schedule SMS that will be dispatched in the exact date/time specified,
# format must be provided in the yyyy-mm-dd hh:mm format (e.g: 2014-02-1818 19:10)
ElibomEx.send_sms(%{to: "573140000000", text: "Hi from Elibom", scheduleDate: "2014-02-18 19:10"})

# Shows the status of provided SMS
ElibomEx.show_sms("sms_id")

# Show the state of a scheduled SMS
ElibomEx.show_scheduled_sms("scheduled_sms_id")

# Cancel a scheduled SMS
ElibomEx.cancel_scheduled_sms("scheduled_sms_id")

# Consult your account details
ElibomEx.show_account

# Show all the users related with your account. If you need to fetch a specific user data,
# just provide it's Elibom user id.
ElibomEx.show_users
```

### Supported Endpoints

#### Deliveries

- [Send SMS](https://www.elibom.com/developers#enviar).
- [Consult delivery](https://www.elibom.com/developers#consultar).
- [Consult scheduled SMS](https://www.elibom.com/developers#consult-prog).
- [Cancel scheduled SMS](https://www.elibom.com/developers#delete).
- [Send SMS](https://www.elibom.com/developers#enviar).

#### Account

- [Consult account](https://www.elibom.com/developers#consultar-cuenta).
- [Consult users](https://www.elibom.com/developers#consultar-usuarios).
- [Consult user](https://www.elibom.com/developers#consultar-usuario).
