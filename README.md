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

The current published Katl releases provide a Linux amd64 binary. The tap will
also publish macOS arm64 entries when that release asset becomes available.
Other architectures are not supported by the upstream release.

The [formulas](Formula/) pin release binaries by SHA-256. An [hourly GitHub
Actions workflow](.github/workflows/update-formula.yml) checks both channels,
verifies each binary against its upstream checksum, and commits changed formulas
to the tap. It installs and tests changed formulas before publishing. A
[push check](.github/workflows/test-formula.yml) also installs the published
formulas through Homebrew. Run the update workflow manually to check for a
release immediately.

For local maintenance, enter `nix develop path:.` or allow direnv with `direnv allow`.
Then run `python3 -m unittest discover -s scripts -p 'test_*.py'`,
`python3 scripts/update-formula.py`, `ruby -c Formula/beta.rb`, and
`actionlint .github/workflows/update-formula.yml`.
