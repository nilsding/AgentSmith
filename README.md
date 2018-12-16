# 🕴 AgentSmith

AgentSmith allows you to communicate with the Matrix using your favourite IRC
client (or bot).

This is just a silly proof of concept for now, but it looks promising.  It is
not yet recommended to use this in production.

<p align="center">
  <img src="https://github.com/nilsding/AgentSmith/blob/master/misc/img/kvirc_channel.png?raw=true" alt="Screenshot of KVIrc displaying a conversation within a Matrix room" />
</p>

## Features

- Communicate with rooms which have set a main alias
- ~~Annoy~~ Delight others with [colours][mirc_colours]
- File attachments are expanded as a HTTP link, ready to be opened by a browser

### Features that still need to be done/would be nice to have

- ~~Rooms without main aliases (this perhaps also covers private messages)~~
- Maybe support multiple homeservers at once
- A nicer way to log in to your homeserver
- Several IRC commands (e.g. ~~`WHO`~~, ~~`NAMES`~~, `LIST`)
- ~~Map permissions to IRC channel modes (e.g. Admin (100) -> `+o`, Moderator (50)
  -> `+h` etc.)~~
- File uploads (DCC?)
- TLS

## Installation

Install `crystal` using your favourite package manager as guided by the [Crystal
docs][crystal_install].  After that, building AgentSmith should be as easy as:

```sh
shards build
```

The resulting binary is then located in `./bin/AgentSmith`.

**macOS Mojave note**: You may run into an error saying the compiler could not
find OpenSSL.  To fix that, install `openssl` from Homebrew and point
`PKG_CONFIG_PATH` to OpenSSL's pkgconfig directory:

```sh
# zsh, bash:
export PKG_CONFIG_PATH=/usr/local/opt/openssl/lib/pkgconfig

# tcsh:
setenv PKG_CONFIG_PATH /usr/local/opt/openssl/lib/pkgconfig
```

## Usage

After building (see _Installation_ section above), run it:

```sh
# Authenticate with your home server for the first time
./bin/AgentSmith -s https://your_homeserver_url

# Once you got your access token and exported the MATRIX_ACCESS_TOKEN variable,
# run it again to start the IRC server:
./bin/AgentSmith -s https://your_homeserver_url
```

Once the server is running, you can point your favourite IRC client to it and
connect to the Matrix!

<p align="center">
  <img src="https://github.com/nilsding/AgentSmith/blob/master/misc/img/mirc_connect.png?raw=true" alt="mIRC server options" />
</p>

## Development

Basically:

1. Write new code
2. (optionally) Write specs for your code
3. Make sure it compiles and the specs work: `shards build` + `crystal spec`
4. And, of course, make sure it starts up like it should (see _Usage_ section
   above)

## Contributing

1. Fork it (<https://github.com/nilsding/AgentSmith/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the Crystal formatter (`crystal tool format`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

## Contributors

- [Georg Gadinger](https://github.com/nilsding) - creator and maintainer

## Code of Conduct

Everyone interacting in the AgentSmith project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of conduct].

[mirc_colours]: https://twitter.com/nilsding/status/1068661362845511680
[crystal_install]: https://crystal-lang.org/docs/installation
[code of conduct]: https://github.com/nilsding/AgentSmith/blob/master/CODE_OF_CONDUCT.md
