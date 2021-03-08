# ronin-db

[![CI](https://github.com/ronin-rb/ronin-db/actions/workflows/ruby.yml/badge.svg)](https://github.com/ronin-rb/ronin-db/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/ronin-rb/ronin-db.svg)](https://codeclimate.com/github/ronin-rb/ronin-db)

* [Website](https://ronin-rb.dev)
* [Source](https://github.com/ronin-rb/ronin-db)
* [Issues](https://github.com/ronin-rb/ronin-db/issues)
* [Documentation](https://ronin-rb.dev/docs/ronin-db/frames)
* [Slack](https://ronin-rb.slack.com) |
  [Discord](https://discord.gg/6WAb3PsVX9) |
  [Twitter](https://twitter.com/ronin_rb) |
  [IRC](https://ronin-rb.dev/irc/)

## Description

ronin-db is a database library for ronin-rb. ronin-db provides familiar ORM
models for interacting with the database's SQL tables and querying/storing
security data, such as URLs, email addresses, host names, IPs, ports, etc.
It also provides CLI commands for managing the database(s).

## Features

* Provides a Database using [DataMapper] with:
  * {Ronin::Author}
  * {Ronin::License}
  * {Ronin::Arch}
  * {Ronin::OS}
  * {Ronin::Software}
  * {Ronin::Vendor}
  * {Ronin::Address}
    * {Ronin::MACAddress}
    * {Ronin::IPAddress}
    * {Ronin::HostName}
  * {Ronin::Port}
    * {Ronin::TCPPort}
    * {Ronin::UDPPort}
  * {Ronin::Service}
  * {Ronin::OpenPort}
  * {Ronin::OSGuess}
  * {Ronin::UserName}
  * {Ronin::URL}
  * {Ronin::EmailAddress}
  * {Ronin::Credential}
    * {Ronin::ServiceCredential}
    * {Ronin::WebCredential}
  * {Ronin::Organization}
  * {Ronin::Campaign}
  * {Ronin::Target}

## Synopsis

List available Databases:

    $ ronin database

Add a new Database:

    $ ronin database --add team --uri mysql://user:pass@vpn.example.com/db

Remove a Database:

    $ ronin database --remove team

## Requirements

* [Ruby] >= 1.9.1
* [DataMapper]:
  * [dm-sqlite-adapter] ~> 1.2
    * [libsqlite3]
  * [dm-core] ~> 1.2
  * [dm-types] ~> 1.2
  * [dm-migrations] ~> 1.2
  * [dm-validations] ~> 1.2
  * [dm-aggregates] ~> 1.2
  * [dm-timestamps] ~> 1.2
  * [dm-serializer] ~> 1.2
* [uri-query_params] ~> 0.6
* [ronin-support] ~> 0.6

## Install

    $ gem install ronin-db

### Gemfile

    gem 'ronin-db', '~> 0.1'

## Development

1. [Fork It!](https://github.com/ronin-rb/ronin-db/fork)
2. Clone It!
3. `cd ronin-db`
4. `bundle install`
5. `git checkout -b my_feature`
6. Code It!
7. `bundle exec rake spec`
8. `git push origin my_feature`

## License

Copyright (c) 2006-2021 Hal Brodigan (postmodern.mod3 at gmail.com)

This file is part of ronin-db.

Ronin is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Ronin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Ronin.  If not, see <https://www.gnu.org/licenses/>.

[Ruby]: https://www.ruby-lang.org

[DataMapper]: http://datamapper.org
[dm-sqlite-adapter]: https://github.com/datamapper/dm-sqlite-adapter#readme
[libsqlite3]: https://sqlite.org/
[dm-core]: https://github.com/datamapper/dm-core#readme
[dm-types]: https://github.com/datamapper/dm-types#readme
[dm-migrations]: https://github.com/datamapper/dm-migrations#readme
[dm-validations]: https://github.com/datamapper/dm-validations#readme
[dm-aggregates]: https://github.com/datamapper/dm-aggregates#readme
[dm-timestamps]: https://github.com/datamapper/dm-timestamps#readme
[dm-serializer]: https://github.com/datamapper/dm-serializer#readme
[uri-query_params]: https://github.com/postmodern/uri-query_params#readme
[ronin-support]: https://github.com/ronin-rb/ronin-support#readme
