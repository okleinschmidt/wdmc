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
```
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
