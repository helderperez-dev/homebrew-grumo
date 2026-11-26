# Grumo Homebrew tap

Grumo is a programmable runtime for adaptive applications.

## Install the CLI

After the formula has passed installation CI and merged:

```sh
brew install helderperez-dev/grumo/grumo
grumo version
```

Upgrade with `brew upgrade grumo`.

## Install without Homebrew

```sh
uv tool install --python 3.12 grumo
grumo version
```

For an existing uv project use `uv add grumo` and `uv run grumo --help`.
The native Grumo Store is installed as a dependency. The previous Voodoo formula is retained during migration; do not migrate or delete existing application data when changing installers.
