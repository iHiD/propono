# Propono

[![Build Status](https://travis-ci.org/meducation/propono.png)](https://travis-ci.org/meducation/propono)
[![Dependencies](https://gemnasium.com/meducation/propono.png?travis)](https://gemnasium.com/meducation/propono)
[![Code Climate](https://codeclimate.com/github/meducation/propono.png)](https://codeclimate.com/github/meducation/propono)

Propono is a [pub/sub](http://en.wikipedia.org/wiki/Publish-subscribe_pattern) gem built on top of Amazon Web Services (AWS). It uses Simple Notification Service (SNS) and Simple Queue Service (SQS) to seamlessly pass messages throughout your infrastructure.

It's beautifully simple to use.

```ruby
# On Machine A
Propono.listen_to_queue('some-topic') do |message|
  puts "I just received: #{message}"
end

# On Machine B
Propono.publish('some-topic', "The Best Message Ever")

# Output on Machine A a second later.
# - "I just recieved The Best Message Ever"
```

## Installation

Add this line to your application's Gemfile:

    gem 'propono'

And then execute:

    $ bundle install

## Usage

The first thing to do is setup some configuration keys for Propono. It's best to do this in an initializer, or at the start of your application.

```ruby
Propono.config.access_key       = "access-key"       # From AWS
Propono.config.secret_key       = "secret-key"       # From AWS
Propono.config.queue_region     = "queue-region"     # From AWS
```

You can then start publishing messages easily from anywhere in your codebase.

```ruby
Propono.publish('some-topic', "Some string")
Propono.publish('some-topic', {some: ['hash', 'or', 'array']})
```

Listening for messages is easy too. Just tell Propono what your application is called and start listening. You'll get a block yieleded for each message.

```ruby
Propono.config.application_name = "application-name" # Something unique to this app.
Propono.listen_to_queue('some-topic') do |message|
  # ... Do something interesting with the message
end
```
In the background, Propono is automatically setting up a queue using SQS, a notification system using SNS, and glueing them all together for you. But you don't have to worry about any of that.

### Using TCP for messages

Publishing directly to SNS takes about 15x longer than publishing over a simple TCP connection. It is therefore some times favourable to publish to a seperate machine listening for TCP messages, which will then proxy them on.

To send messages this way, you need to set up a little extra config:

```ruby
Propono.config.tcp_host = "some.host.running.a.propono.listener"
Propono.config.tcp_port = 12543
```

You then simply pass the `:tcp` protocol into `publish`

```ruby
Propono.publish('some-topic', message, protocol: :tcp)
```

You'll now need another application running Propono to listen to the TCP feed. You can use the same machine or a different one, just make sure the port config is the same in both applications, and you're good to go.

```ruby
Propono.listen_to_tcp do |topic, message|
  Propono.publish(topic, message) # Proxy the message to SNS
end
```

This proxying of TCP to SQS is used so often that there's a simple shortcut. Just run this on the machine receiving the TCP packets.

```ruby
Propono.proxy_tcp()
```

### Using UDP for messages

If you want almost-zero performance impact, and don't mind the occasional message getting lost, you can use UDP. We use this for things like our live dashboard where we don't mind losing a piece of activity here and there, but any perforamnce impact on our Meducation itself is bad news.

Sending messages in this way is very similar to using TCP. First add some config:

```ruby
Propono.config.udp_host = "some.host.running.a.propono.listener"
Propono.config.udp_port = 12543
```

You then simply pass the `:udp` protocol into `publish`:

```ruby
Propono.publish('some-topic', message, protocol: :udp)

As per the `listen_to_tcp` method explained above, you now listen to udp or use the proxy method:

```ruby
Propono.listen_to_udp do |topic, message|
  Propono.publish(topic, message) # Proxy the message to SNS
end

Propono.proxy_udp()
```

### Configuration

The following configuration settings are available:

```
Propono.config do |config|
  config.access_key = "An AWS access key"
  config.secret_key = "A AWS secret key"
  config.queue_region = "An AWS queue region"
  config.application_name = "A name unique in your network"
  config.udp_host = "The host of a machine used for UDP proxying"
  config.udp_port = "The port of a machine used for UDP proxying"
  config.tcp_host = "The host of a machine used for TCP proxying"
  config.tcp_port = "The port of a machine used for TCP proxying"
  config.logger = "A logger such as Log4r or Rails.logger"
end
```

The can all also be setting using the `Propono.config.access_key = "..."` syntax.

### Is it any good?

[Yes.](http://news.ycombinator.com/item?id=3067434)

## Contributing

Firstly, thank you!! :heart::sparkling_heart::heart:

We'd love to have you involved. Please read our [contributing guide](https://github.com/meducation/propono/tree/master/CONTRIBUTING.md) for information on how to get stuck in.

### Contributors

This project is managed by the [Meducation team](http://company.meducation.net/about#team). 

These individuals have come up with the ideas and written the code that made this possible:

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
