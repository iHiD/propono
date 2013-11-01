# 0.8.0 / 2013-11-01

* [FEATURE] SNS publish now delegates to a thread pool. The SNS response can be accessed via a future.

# 0.7.0 / 2013-10-23

* [FEATURE] Add TCP publish and listen methods.

# 0.6.3 / 2013-10-20

* [FEATURE] Catch all StandardError exceptions for UDP publishes.

# 0.6.2 / 2013-10-20

* [BUGFIX] Fixed integration tests that sometimes failed due to shared UDP ports or slow SQS subscriptions.

# 0.6.1 / 2013-10-20

* [BUGFIX] Added `require 'json'` to udp_listener.rb
