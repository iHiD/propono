# Upgrading

## Changes from v2 to v3

Version 3 changed the way configuration options for the two AWS services are
passed to the client gems. Instead of Propono attempting to guess which
configuration options you might want, it now accepts hashes for AWS
configuration which are passed directly to the appropriate clients.

If you are upgrading from v2 to v3, and using the configuration as previously
given in the README, you need to change from:

```ruby
client = Propono::Client.new
client.config.access_key   = "your_access_key_id"
client.config.secret_key   = "your_secret_access_key"
client.config.queue_region = "aws_region"
```

To:

```ruby
client = Propono::Client.new do |config|
  config.aws_options = {
    region:            'aws_region'
    access_key_id:     'your_access_key_id',
    secret_access_key: 'your_secret_access_key'
  }
end
```

For a full rundown, see the [AWS Configuration
section](../README.md#aws-configuration) of the README.


## Changes from v1 to v2

Version 2 of Propono changed a few things:
- We moved from a global interface to a client interface. Rather than calling
  `publish` and equivalent on `Propono`, you should now initialize a
  `Propono::Client` and then call everything on that client. This fixes issues
  with thread safety and global config.
- We have also removed the dependancy on Fog and instead switch to the `sns`
  and `sqs` mini-gems of `aws-sdk`.
- UDP and TCP support have been removed, and `subscribe_by_post` has been
  removed.
- We are now using long-polling. This makes Propono **significantly** faster
  (10-100x).
