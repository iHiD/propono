# 2.0.0 / 2017-03-14
* [FEATURE] Remove UDP and TCP support
* [FEATURE] Change default publish behaviour from async to sync
* [FEATURE] Propono.subscripe_by_post has been removed
* [FEATURE] Propono.subscripe_by_queue has been renamed to subscribe
* [FEATURE] Change to Propono::Client interface
* [FEATURE] Switch fog out for aws gems
* [FEATURE] Use long polling

# 1.7.0 / 2017-01-17
* [FEATURE] Added num_messages_per_poll config option to allow you to change how many messages you pull from AWS per poll cycle.

# 1.6.0 / 2015-06-05
* [FEATURE] Require fog-aws gem instead of fog  (:blue_heart: @mhuggins)
* [FEATURE] Change licence to MIT  (:blue_heart: @BiggerNoise)

# 1.5.0 / 2015-03-16
* [BUGFIX] Fix inability to use queue if the message visibility timeout has changed.

# 1.4.0 / 2014-07-12
* [FEATURE] Move symbolize_keys to Propono namespace to avoid ActiveSupport conflict (:blue_heart: @tardate)
* [BUGFIX] Drain integration tests drain queues before starting (:blue_heart: @tardate)
* [BUGFIX] Fix typos in log messages (:blue_heart: @tardate)
* [BUGFIX] Fix issue with tests failing when ran in a certain order

# 1.3.0 / 2014-07-12
* [FEATURE] Add {async: false} option to publisher

# 1.2.0 / 2014-05-25
* [BUGFIX] Restrict SQS policy to only allow SNS topic publishes.

# 1.1.3 / 2014-05-14
* [FEATURE] Added ability to drain queue. Also allow dot releases of Fog.

# 1.1.2 / 2014-03-31
* [BUGFIX] Move topic lookup into publishing thread.

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
