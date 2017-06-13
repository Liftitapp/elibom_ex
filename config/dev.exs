use Mix.Config

config :elibom_ex, username: System.get_env("ELIBOM_USERNAME"),
                   password: System.get_env("ELIBOM_PASSWORD")
