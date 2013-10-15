# Propono

[![Build Status](https://travis-ci.org/meducation/propono.png)](https://travis-ci.org/meducation/propono)
[![Dependencies](https://gemnasium.com/meducation/propono.png?travis)](https://gemnasium.com/meducation/propono)
[![Code Climate](https://codeclimate.com/github/meducation/propono.png)](https://codeclimate.com/github/meducation/propono)

## Installation

Add this line to your application's Gemfile:

    gem 'propono'

If you want to use the latest version from Github, you can do:

    gem 'propono', github: "meducation/propono"

And then execute:

    $ bundle

This script demonstrates usage:

```ruby
require 'propono'

class Toy
  def play
    configure
    make_fun_stuff_happen
  end

  private
  def make_fun_stuff_happen
    Propono.publish("jez-test-topic", "A test message")
    Propono.subscribe_by_queue("jez-test-topic")
    Propono.subscribe_by_post("jez-test-topic", 'http://example.com/endpoint')
  end

  def configure
    Propono.config.access_key = '...'
    Propono.config.secret_key = '...'
    Propono.config.queue_region = 'eu-west-1'
  end
end

Toy.new.play
```

## Contributing

Firstly, thank you!! :heart::sparkling_heart::heart:

Please read our [contributing guide](https://github.com/meducation/propono/tree/master/CONTRIBUTING.md) for information on how to get stuck in.

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
