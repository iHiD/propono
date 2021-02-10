**Propono v3.0.0 has been released with new AWS configuration options. Check out the [upgrading doc](https://github.com/iHiD/propono/blob/main/docs/upgrading.md) for more information. Thanks to @dougal for this work!**

# Propono

![Tests](https://github.com/iHiD/propono/workflows/Tests/badge.svg)
[![Code Climate](https://codeclimate.com/github/iHiD/propono.png)](https://codeclimate.com/github/iHiD/propono)

Propono is a [pub/sub](http://en.wikipedia.org/wiki/Publish-subscribe_pattern) gem built on top of Amazon Web Services (AWS). It uses Simple Notification Service (SNS) and Simple Queue Service (SQS) to seamlessly pass messages throughout your infrastructure.

It's beautifully simple to use. [Watch an introduction](https://www.youtube.com/watch?v=ZM3-Gl5DVgM)

```ruby
# On Machine A
Propono::Client.new.listen('some-topic') do |message|
  puts "I just received: #{message}"
end

# On Machine B
Propono::Client.new.publish('some-topic', "The Best Message Ever")

# Output on Machine A a second later.
# - "I just received The Best Message Ever"
```

## Upgrading

Upgrades from v1 to v2, and v2 to v3 are covered in the [upgrade documentation](docs/upgrading.md).

## Installation

Add this line to your application's Gemfile:

    gem 'propono'

And then execute:

    $ bundle install

## Usage

The first thing to do is setup some configuration for Propono.
It's best to do this in an initializer, or at the start of your application.
If you need to setup AWS authentication, see the [AWS Configuration](#aws-configuration) section.

```ruby
client = Propono::Client.new
```

You can then start publishing messages easily from anywhere in your codebase.

```ruby
client = Propono::Client.new
client.publish('some-topic', "Some string")
client.publish('some-topic', {some: ['hash', 'or', 'array']})
```

Listening for messages is easy too. Just tell Propono what your application is called and start listening. You'll get a block yielded for each message.

```ruby
client = Propono::Client.new
client.config.application_name = "application-name" # Something unique to this app.
client.listen('some-topic') do |message|
  # ... Do something interesting with the message
end
```
In the background, Propono is automatically setting up a queue using SQS, a notification system using SNS, and gluing them all together for you. But you don't have to worry about any of that.

**Does it matter what I set my `application_name` to?**
For a simple publisher and subscriber deployment, no.
However, the `application_name` has a direct impact on subscriber behaviour when more than one is in play.
This is because a queue is established for each application_name/topic combination. In practice:
* subscribers that share the same `application_name` will act as multiple workers on the same queue. Only one will get to process each message.
* subscribers that have a different `application_name` will each get a copy of a message to process independently i.e. acts as a one-to-many broadcast.

### AWS Configuration

By default, Propono will create SQS and SNS clients with no options.
In the absence of options, these clients will make use of the credentials on the current host.
See the [AWS SDK For Ruby Configuration documentation](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html) for more details.

To manually configure options for use with AWS, use `aws_options`, which sets options to be passed to both clients. For example:

    client = Propono::Client.new do |config|
      config.aws_options = {
        region:            'aws_region',
        access_key_id:     'your_access_key_id',
        secret_access_key: 'your_secret_access_key'        
      }
    end

In addition to this, there are also `sqs_options` and `sns_options`, used to configure each client independently.
See the [SQS Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SQS/Client.html#initialize-instance_method) and [SNS Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SNS/Client.html#initialize-instance_method) documentation for available options.
These individual options are merged with `aws_options` with the per-client options taking precendence.

### General Configuration

```
Propono::Client.new do |config|
  # AWS Configuration, see above.
  config.aws_options = {...}
  config.sqs_options = {...}
  config.sns_options = {...}

  config.application_name = "A name unique in your network"
  config.logger = "A logger such as Log4r or Rails.logger"

  config.max_retries = "The number of retries if a message raises an exception before being placed on the failed queue"
  config.num_messages_per_poll = "The number of messages retrieved per poll to SQS"

  config.slow_queue_enabled = true
end
```

### Options

#### Async

By default messages are posted inline, blocking the main thread. The `async: true` option can be sent when posting a message, which will spawn a new thread for the message networking calls, and unblocking the main thread.

#### Visiblity Timeout

For certain tasks (e.g. video processing), being able to hold messages for longer is important. To achieve this, the [visibility timeout of a message](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-visibility-timeout.html) can be changed on the call to listen. e.g.

```
client.listen('long-running-tasks', visiblity_timeout: 3600) do |message|
  puts "I just received: #{message}"
end
```

### Slow Queue

The slow queue can be disabled by setting `slow_queue_enabled` to `false`. This will yield performance improvements if you do not make use of the "slow queue" functionality.

### Is it any good?

[Yes.](http://news.ycombinator.com/item?id=3067434)

## Contributing

Firstly, thank you!! :heart::sparkling_heart::heart:

We'd love to have you involved. Please read our [contributing guide](https://github.com/iHiD/propono/tree/master/CONTRIBUTING.md) for information on how to get stuck in.

### Contributors

This project is managed by the [Jeremy Walker](http://ihid.co.uk).

These individuals have come up with the ideas and written the code that made this possible:

- [Jeremy Walker](https://github.com/iHiD)
- [Malcolm Landon](https://github.com/malcyL)
- [Charles Care](https://github.com/ccare)
- [Rob Styles](https://github.com/mmmmmrob)

## Licence

Copyright (C) 2017 Jeremy Walker

This program is free software: you can redistribute it and/or modify
it under the terms of the MIT License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
MIT License for more details.

A copy of the MIT License is available in [LICENCE.md](https://github.com/iHiD/propono/blob/master/LICENCE.md)
along with this program.
