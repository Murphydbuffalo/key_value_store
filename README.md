# KeyValueStore

A distributed key-value store built to make use of various Mix and OTP features
including Tasks, Agents, GenServers, umbrella applications.

To start the application run `iex -S mix`, and connect a TCP client to
`127.0.0.1:4040` to test it out, eg `telnet 127.0.0.1 4040`.

This key-value store allows you to create buckets, and to get, set, and delete
key-value pairs for a particular bucket. Valid commands are:
```
CREATE bucket_name
SET bucket_name key value
GET bucket_name key
DELETE bucket_name key
```

Includes tests written with ExUnit. You can run the test suite with `mix test`.
The unit test for `KV.Router` expects multiple nodes running this application
to be connected. You can run this test successfully by starting the application
on at least one machines or terminal window before running the tests with the 
command `elixir --sname some_name@my-computer-name -S mix test`.
 
