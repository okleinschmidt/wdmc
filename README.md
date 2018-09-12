# wdmc

The missing command line interface for Western Digital MyCloud NAS local REST API.

## Installation

Since wdmc is not published to rubygems.org yet, by now you have to build yourself as
follows:

```shell
# clone git repository
$ git clone git@github.com:okleinschmidt/wdmc.git

# enter wdmc source directory
$ cd wdmc

# to install run
$ bundle exec rake install
wdmc 0.0.1 built to pkg/wdmc-0.0.1.gem.
wdmc (0.0.1) installed.
```

## Configuration

Create YAML file in your $HOME: ~/.wdmc.yml

```yaml
url: http://192.168.0.10
username: admin
password: super-secure-password
validate_cert: true | false | warn (optional, default: true)
api_net_nl_bug: true | false (optional, default: false)
```
The value of *validate_cert* is relevant only for HTTPS URLs:
  - If not specified or set to _true_, then an invalid certificate will
  cause the server connection to fail with an error message.
  - If set to _false_, then certificate validation will not be performed.
  - If set to _warn_, then an invalid certificate will cause a
  warning message to be emitted and for certificate validation to
  be deactivated for the remainder of the operation.

Set _api_net_nl_bug_ to _true_ to avoid crashes caused by newline
characters in DNS server data in the API response from your server.

I gave admin permission to my user account:

```shell
$ wdmc user update <USER> -a
```

## Usage
```shell
$ wdmc
Commands:
  wdmc acl             # Fileshare ACLs
  wdmc device          # Device commands
  wdmc help [COMMAND]  # Describe available commands or one specific command
  wdmc share           # Fileshare commands
  wdmc sysinfo         # Device information
  wdmc tm              # TimeMachine commands
  wdmc user            # User commands
  wdmc version         # Version information

# List available shares
$ wdmc share list
AVAILABLE SHARES
 - Public
 - TimeMachineBackup
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/okleinschmidt/wdmc. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
