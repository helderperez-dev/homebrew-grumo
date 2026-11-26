# Grumo Homebrew cutover

This tap currently distributes the published `voodoo-framework==3.2.2` and
its `voodoo_store` native extension. **Do not replace the Voodoo formula until
the Grumo packages have been published, clean-installed and tested.**

## Target

After the coordinated cutover:

```sh
brew tap helderperez-dev/grumo
brew install grumo
grumo --help
```

Target GitHub repository: `helderperez-dev/homebrew-grumo` (the GitHub naming
convention permits the short tap `helderperez-dev/grumo`).

Target formula: `Formula/grumo.rb`; Ruby class `Grumo`.

## Pre-publish gates

- [ ] New PyPI `grumo-store` project exists, with GitHub OIDC trusted
      publisher correctly configured after repository renaming.
- [ ] New PyPI `grumo` project exists with its own OIDC trusted publisher.
- [ ] `pip install grumo-store` yields a working `grumo_store` native wheel
      across supported macOS Intel and Apple Silicon variants.
- [ ] `pip install grumo` yields the canonical `grumo` CLI and Python package.
- [ ] `grumo new`, `grumo dev` and framework/store import smoke tests pass.
- [ ] New source tarball and SHA256 verified (do not reuse Voodoo hashes).
- [ ] Formula's `uv tool install` package and `libexec` path both updated.
- [ ] Homebrew's relocation workaround tested against actual new
      `grumo_store/_native.abi3.so` binary on supported macOS targets.
- [ ] If the workaround is no longer needed, remove it only after bottle/keg
      relocation smoke tests prove it is safe.
- [ ] Install, upgrade and uninstall checks pass for fresh installs and for
      existing `voodoo` users.
- [ ] GitHub Actions release and PyPI trusted publisher gates are green.

## Formula-specific reminders

In `Formula/grumo.rb` update *together*:

- `class Grumo < Formula`
- homepage, source tarball URL, SHA256 and Ruby version
- `uv tool install grumo==#{version}`
- `libexec/"grumo/bin"` and `bin.install_symlink tool_bin/"grumo"`
- native binding path `site-packages/grumo_store/_native.abi3.so`
- `post_install` decompression and all test invocations
- `from grumo import App`, `import grumo_store`
- generated app location `.grumo/application.grumo`

An installer that still points to `voodoo-framework` is **not** a completed
Grumo release. Use a new SHA256 from the *published* Grumo sdist.

## Renaming existing installs

Keep the existing `Formula/voodoo.rb` until the target is certified. At
cutover, add a `formula_renames.json` mapping:

```json
{
  "voodoo": "grumo"
}
```

Do not add this mapping before `Formula/grumo.rb` exists and passes an
installation test. Homebrew's rename mechanism can migrate installed formulae,
but a **tap repo rename** is a separate operation, and existing users may need
an explicit tap migration depending on their Homebrew configuration.

Check official guidance: https://docs.brew.sh/Rename-A-Formula and
https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap.

## Backward compatibility and rollback

- Preserve Git tags and original formula's resolved PyPI artifacts.
- Never publish a formula whose URL does not resolve to its SHA256.
- Keep `voodoo` usable through a transition period while notifying users.
- Existing projects with `.voodoo/application.vstore` need explicit verified
  copy/migration. Changing `brew` packages must not rewrite persistent data.
- The Voodoo → Grumo name transition does not alter the existing Store binary
  format.
