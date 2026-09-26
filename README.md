# Katl Homebrew tap

Install the beta channel on a supported host:

```sh
brew install katl-dev/katlctl/beta
katlctl version
```

The stable channel is `brew install katl-dev/katlctl/stable`. Its formula will
appear when Katl publishes its first stable release. Stable users receive only
stable releases. Beta users receive the newest stable or beta release, whichever
has the higher version. Both formulas install the executable as `katlctl`.
The formulas conflict; switch channels by uninstalling the current formula
(`brew uninstall katl-dev/katlctl/beta` or `brew uninstall katl-dev/katlctl/stable`)
before installing the other.
Each formula installs Bash, Fish, and Zsh completion scripts for `katlctl`.
Your shell may need to load Homebrew's completion directory; see
[Homebrew's shell completion instructions](https://docs.brew.sh/Shell-Completion).

To keep an exact release, install its versioned formula:

```sh
brew install katl-dev/katlctl/beta@2026.9.0-beta.16
katlctl version
```

The tap retains exact-version formulas from `2026.9.0-beta.16` onward. A stable
release gets both `stable@<version>` and `beta@<version>` because it is eligible
for either channel; a beta release gets only `beta@<version>`. Uninstall a
channel formula before installing another one because each provides `katlctl`.

The current published Katl releases provide a Linux amd64 binary. The tap will
also publish macOS arm64 entries when that release asset becomes available.
Other architectures are not supported by the upstream release.

The [formulas](Formula/) pin release binaries by SHA-256. An [hourly GitHub
Actions workflow](.github/workflows/update-formula.yml) checks both channels,
verifies each binary against its upstream checksum, and commits changed formulas
to the tap. It installs and tests changed formulas before publishing. Published
exact-version formulas remain fixed as the rolling channels advance. A
[push check](.github/workflows/test-formula.yml) also installs the published
formulas through Homebrew. Run the update workflow manually to check for a
release immediately.

For local maintenance, enter `nix develop path:.` or allow direnv with `direnv allow`.
Then run `python3 -m unittest discover -s scripts -p 'test_*.py'`,
`python3 scripts/update-formula.py`, `ruby -c Formula/beta.rb`, and
`actionlint .github/workflows/update-formula.yml`.
