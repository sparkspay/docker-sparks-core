# sparkspay/docker-sparks-core

A sparks Core docker image.

[![sparkspay/sparks-core][docker-pulls-image]][docker-hub-url] [![sparkspay/sparks-core][docker-stars-image]][docker-hub-url] [![sparkspay/sparks-core][docker-size-image]][docker-hub-url] [![sparkspay/sparks-core][docker-layers-image]][docker-hub-url]

## Tags

- `0.12.3.6-alpine`, `0.12-alpine`, `alpine`, `latest` ([0.12/alpine/Dockerfile](https://github.com/sparkspay/docker-sparks-core/blob/master/0.12/alpine/Dockerfile))
- `0.12.3.6`, `0.12`  ([0.12/Dockerfile](https://github.com/sparkspay/docker-sparks-core/blob/master/0.12/Dockerfile))

## Usage

### How to use this image

This image contains the main binaries from the SparksPay Core project - `sparksd`, `sparks-cli` and `sparks-tx`. It behaves like a binary, so you can pass any arguments to the image and they will be forwarded to the `sparksd` binary:

```sh
$ docker run --rm -it sparkspay/sparks-core \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcpassword=bar \
  -rpcuser=foo
```

By default, `sparksd` will run as user `sparks` for security reasons and with its default data dir (`~/.sparkscore`). If you'd like to customize where `sparks-core` stores its data, you must use the `SPARKS_DATA` environment variable. The directory will be automatically created with the correct permissions for the `sparks` user and `sparks-core` is automatically configured to use it.

```sh
$ docker run --env SPARKS_DATA=/var/lib/sparks --rm -it sparkspay/sparks-core \
  -printtoconsole \
  -regtest=1
```

You can also mount a directory it in a volume under `/home/sparks/.sparkscore` in case you want to access it on the host:

```sh
$ docker run -v ${PWD}/data:/home/sparks/.sparkscore -it --rm sparkspay/sparks-core \
  -printtoconsole \
  -regtest=1
```

You can optionally create a service using `docker-compose`:

```yml
sparks-core:
  image: sparkspay/sparks-core
  command:
    -printtoconsole
    -regtest=1
```

### Using RPC to interact with the daemon

There are two communications methods to interact with a running SparksPay Core daemon.

The first one is using a cookie-based local authentication. It doesn't require any special authentication information as running a process locally under the same user that was used to launch the SparaksPay Core daemon allows it to read the cookie file previously generated by the daemon for clients. The downside of this method is that it requires local machine access.

The second option is making a remote procedure call using a username and password combination. This has the advantage of not requiring local machine access, but in order to keep your credentials safe you should use the newer `rpcauth` authentication mechanism.

#### Using cookie-based local authentication

Start by launch the SparksPay Core daemon:

```sh
❯ docker run --rm --name sparks-server -it sparkspay/sparks-core \
  -printtoconsole \
  -regtest=1
```

Then, inside the running `sparks-server` container, locally execute the query to the daemon using `sparks-cli`:

```sh
❯ docker exec --user sparks sparks-server sparks-cli -regtest getmininginfo

{
  "blocks": 0,
  "currentblocksize": 0,
  "currentblockweight": 0,
  "currentblocktx": 0,
  "difficulty": 4.656542373906925e-10,
  "errors": "",
  "networkhashps": 0,
  "pooledtx": 0,
  "chain": "regtest"
}
```

In the background, `sparks-cli` read the information automatically from `/home/sparks/.sparkscore/regtest/.cookie`. In production, the path would not contain the regtest part.

#### Using rpcauth for remote authentication

Before setting up remote authentication, you will need to generate the `rpcauth` line that will hold the credentials for the SparksPay Core daemon.
You can either do this yourself by constructing the line with the format `<user>:<salt>$<hash>` or use the official `rpcuser.py` script to generate this line for you, including a random password that is printed to the console.

Example:

```sh
❯ curl -sSL https://raw.githubusercontent.com/sparkspay/sparks/master/share/rpcuser/rpcuser.py | python - foo

String to be appended to bitcoin.conf:
rpcauth=foo:796d3d89ded5b826c7a4bf2ca8fe465$4cb1618e1552b414941783822b087b2df8c2b8bb1fa3dc441d9fa8f32d43e054
Your password:
Yec3WkzEpXGNFRQgTCsdKYp8HO11Z6DaoOY8BvV4YhE=
```

Note that for each run, even if the username remains the same, the output will be always different as a new salt and password are generated.

Now that you have your credentials, you need to start the SparksPay Core daemon with the `-rpcauth` option. Alternatively, you could append the line to a `sparks.conf` file and mount it on the container.

Let's opt for the Docker way:

```sh
❯ docker run --rm --name sparks-server -it sparkspay/sparks-core \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcauth='foo:796d3d89ded5b826c7a4bf2ca8fe465$4cb1618e1552b414941783822b087b2df8c2b8bb1fa3dc441d9fa8f32d43e054'
```

Two important notes:

1. Some shells require escaping the rpcauth line (e.g. zsh), as shown above.
2. It is now perfectly fine to pass the rpcauth line as a command line argument. Unlike `-rpcpassword`, the content is hashed so even if the arguments would be exposed, they would not allow the attacker to get the actual password.

You can now connect via `sparks-cli` or any other [compatible client](https://github.com/sparkspay/sparks-core). You will still have to define a username and password when connecting to the SparksPay Core RPC server.

To avoid any confusion about whether or not a remote call is being made, let's spin up another container to execute `sparks-cli` and connect it via the Docker network using the password generated above:

```sh
❯ docker run --link sparks-server --rm sparkspay/sparks-core sparks-cli -rpcconnect=sparks-server -regtest -rpcuser=foo -rpcpassword='Yec3WkzEpXGNFRQgTCsdKYp8HO11Z6DaoOY8BvV4YhE=' getmininginfo

{
  "blocks": 0,
  "currentblocksize": 0,
  "currentblockweight": 0,
  "currentblocktx": 0,
  "difficulty": 4.656542373906925e-10,
  "errors": "",
  "networkhashps": 0,
  "pooledtx": 0,
  "chain": "regtest"
}
```

Done!


## Image variants

The `sparkspay/sparks-core` image comes in multiple flavors:

### `sparkspay/sparks-core:latest`

Points to the latest release available of SparksPay Core. Occasionally pre-release versions will be included.

### `sparkspay/sparks-core:<version>`

Based on Alpine Linux with Berkeley DB 4.8 (cross-compatible build), targets a specific version branch or release of SparksPay Core.

## Supported Docker versions

This image is officially supported on Docker version 1.12, with support for older versions provided on a best-effort basis.

## License

[License information](https://github.com/sparkspay/sparks/blob/master/COPYING) for the software contained in this image.

[License information](https://github.com/sparkspay/docker-sparks-core/blob/master/LICENSE) for the [sparkspay/sparks-core][docker-hub-url] docker project.

[docker-hub-url]: https://hub.docker.com/r/sparkspay/sparks-core
[docker-layers-image]: https://img.shields.io/imagelayers/layers/sparkspay/sparks-core/latest.svg?style=flat-square
[docker-pulls-image]: https://img.shields.io/docker/pulls/sparkspay/sparks-core.svg?style=flat-square
[docker-size-image]: https://img.shields.io/imagelayers/image-size/sparkspay/sparks-core/latest.svg?style=flat-square
[docker-stars-image]: https://img.shields.io/docker/stars/sparkspay/sparks-core.svg?style=flat-square
