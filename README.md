# KeyValueStore

A distributed key-value store built to [make use of various Mix and OTP features](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)
including Tasks, Agents, GenServers, and umbrella applications.

The application is meant to run on at least two separate nodes simultaneously,
so to start it up you'll need to run startup commands in at least two
separate terminal windows or on two different machines that are on the same
network.

We'll run one startup command from the root directory, which will start up
a TCP server, and a second command from the `apps/kv` subdirectory to handle
some of those TCP requests (the server process itself will also handle some
requests).

You can start the application via iEx with `iex --sname some_name -S mix`,
where you have replaced `some_name` with different arbitrary names of your choosing
for each terminal window/machine

For example, because I'm big nerd who likes to watch Noam Chomsky debate Michel
Foucault on YouTube I start the application on my laptop by running `iex --sname chomsky
-S mix` from the root directory in one terminal window, and `iex --sname foucault -S mix`
in a second window from the `apps/kv` directory.

Connect one or more TCP clients to `127.0.0.1:4040` to test the application out.
Eg `telnet 127.0.0.1 4040`.

This key-value store allows you to create buckets, and to get, set, and delete
key-value pairs within buckets. Valid (case-sensitive and whitespace-sensitive)
commands are:
```
CREATE bucket_name
SET bucket_name key value
GET bucket_name key
DELETE bucket_name key
```

Includes tests written with ExUnit. You can run the test suite with `mix test`.

The unit test for `KV.Router` expects multiple nodes running this application
to be connected. You can run this test successfully by starting the application
on at least one machine or terminal window before running the tests with the 
command `elixir --sname some_name@my-computer-name -S mix test`.

