# 1.1.1 / 2014-02-22
* [BUGFIX] Logger.error only takes (0..1) arguments.

# 1.1.0 / 2014-02-18
* [FEATURE] Added slow queue to allow processing of lower priority messages.

# 1.0.0.rc3 / 2013-12-20
* [FEATURE] Create failed and corrupt queues when subscribe.

# 1.0.0.rc2 / 2013-12-15
* [FEATURE] Make queue_suffix optional

# 1.0.0.rc1 / 2013-12-15
* [FEATURE] Improve transactional handling of messages.
* [FEATURE] Add failed/corrupt queues.

# 0.11.1 / 2013-12-09
* [BUGFIX] Re raise 403 forbidden excetion instead of continuing.

# 0.11.0 / 2013-12-03
* [FEATURE] Add support for IAM profiles for AWS auth

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
