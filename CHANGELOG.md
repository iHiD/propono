# 0.10.0 / 2013-12-03

* [FEATURE] Add queue_suffix config variable

# 0.9.1 / Unreleased

* [FEATURE] Propono will raise exceptions if the message processing fails

# 0.9.0 / Unreleased

* [FEATURE] Add message ids that track throughout Propono

# 0.8.2 / 2013-11-01

* [BUGFIX] Replace thread library with standard ruby threads to fix Unicorn problems.

# 0.8.1 / 2013-11-01

* [FEATURE] Log all messages published from Propono.

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
