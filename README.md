# Propono

[![Build Status](https://travis-ci.org/meducation/propono.png)](https://travis-ci.org/meducation/propono)
[![Dependencies](https://gemnasium.com/meducation/propono.png?travis)](https://gemnasium.com/meducation/propono)
[![Code Climate](https://codeclimate.com/github/meducation/propono.png)](https://codeclimate.com/github/meducation/propono)

Propono is a [pub/sub](http://en.wikipedia.org/wiki/Publish-subscribe_pattern) gem built on top of Amazon Web Services (AWS). It uses Simple Notification Service (SNS) and Simple Queue Service (SQS) to seamlessly pass messages throughout your infrastructure.

Usage is as simple as adding your config keys then running commands such as:

```ruby
Propono.listen_to_queue('some-topic')
Propono.publish('some-topic', "This message will get from A to B")
```

## Installation

Add this line to your application's Gemfile:

    gem 'propono'

And then execute:

    $ bundle install

## Usage

The first thing to do is setup your configuration.
```ruby
Propono.config.access_key       = "access-key"
Propono.config.secret_key       = "secret-key"
Propono.config.queue_region     = "queue-region"
Propono.config.application_name = "application-name"
```

You can then start publishing messages easily:

```ruby
Propono.publish('some-topic', "{some: ['payload', 'or', 'message']}")
```

To listen for the messages, simply use the `listen` loop. This automatically subscribes the application to the relevant topic.

```ruby
Propono.listen_to_queue('some-topic') do |sqs_message|
  original_message = JSON.parse(sqs_message["Body"])["Message"]
end
```

### Using UDP for messages

If you want almost-zero performance impact, and don't care about whether the message gets lost, you can use UDP. We use this for things like our live dashboard.

To send messages, you need to set up a little extra config:

```ruby
Propono.config.udp_host = "localhost"
Propono.config.udp_port = 12543
```
You then simply pass the `:udp` protocol into `publish`:

```ruby
Propono.publish('some-topic', message, protocol: :udp)
```

Setting up another service running Propono to listen to the UDP feed, is easy. You can use it proxy the message to SNS. For example, with the same config:

```ruby
Propono.listen_to_udp do |message|
  Propono.publish('some-topic', message)
end
```

In fact, this is used so often, that there's a simple shortcut: 

```ruby
Propono.proxy_udp('some-topic')
```

### Is it any good?

[Yes.](http://news.ycombinator.com/item?id=3067434)

## Contributing

Firstly, thank you!! :heart::sparkling_heart::heart:

Please read our [contributing guide](https://github.com/meducation/propono/tree/master/CONTRIBUTING.md) for information on how to get stuck in.

### Contributors

This project is managed by the [Meducation team](http://company.meducation.net/about#team). These specific individuals have written lots of the code that made this possible:

- [Jeremy Walker](http://github.com/iHID)
- [Malcom Landon](http://github.com/malcyL)
- [Rob Styles](http://github.com/mmmmmrob)

## Licence

Copyright (C) 2013 New Media Education Ltd

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

A copy of the GNU Affero General Public License is available in [Licence.md](https://github.com/meducation/propono/blob/master/LICENCE.md)
along with this program.  If not, see <http://www.gnu.org/licenses/>.
