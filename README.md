# Dotfiles

- [.config/gh/config.yml](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.config/gh/config.yml)
- [.gnupg/gpg-agent.conf](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.gnupg/gpg-agent.conf)
- [.bashrc](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.bashrc)
- [.gitconfig](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.gitconfig)
- [.gitconfig-private](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.gitconfig-private)
- [.inputrc](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.inputrc)
- [.vimrc](https://raw.githubusercontent.com/marcofranssen/dotfiles/main/.vimrc)

## Prerequisites

- [Homebrew](https://brew.sh/)
- [Ghostty](https://ghostty.org/)
- [Tmux](https://tmux.github.io/)
- [GNU stow](https://www.gnu.org/software/stow/)
- [ZSH](https://www.zsh.org/)
- [GH Cli](https://cli.github.com/)
- [delta](https://github.com/dandavison/delta)
- [Tree-sitter](https://tree-sitter.github.io/tree-sitter/)

### CLI tools

- [ripgrep](https://github.com/burntsushi/ripgrep)
- [fd](https://github.com/sharkdp/fd)
- [bat](https://github.com/sharkdp/bat)
- [eza](https://eza.rocks/)
- [fzf](https://junegunn.github.io/fzf/)

Once Homebrew is installed the remainder of the prerequisites can be installed with the following command:

```shell
brew install git tmux stow zsh gh eza delta zellij ripgrep fd gnu-sed coreutils
cargo install tree-sitter-cli --locked
```

## Installation

Checkout the repository into `~/.dotfiles` and use stow to create the symlinks:

```shell
git clone git@github.com/marcofranssen/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow .
```

### Configure ViM

```shell
curl -sS https://raw.githubusercontent.com/marcofranssen/dotfiles/main/install_plugins_vim.sh | bash
```

## Configure git

### Prerequisites

```shell
curl -sS https://raw.githubusercontent.com/marcofranssen/dotfiles/main/install_gitconfig.sh | bash
```

## Configure gh cli

```shell
curl -sS https://raw.githubusercontent.com/marcofranssen/dotfiles/main/install_ghconfig.sh | bash
```

## Configure AI

### nono.sh

I'm using [nono.sh][] to sandbox my agents.

Fresh setup, outside any nono sandbox:

```shell
brew install nono

# Installs regular files under ~/.config/nono/packages (not in this repo or Stow).
nono pull nolabs-ai/pi
nono pull nolabs-ai/omp
nono pull nolabs-ai/hermes

# Link the custom profiles from this repo.
cd ~/.dotfiles && stow .

nono list --installed
```

Custom profiles in `.config/nono/profiles` remain versioned and Stow-managed.

The agent extension and skill symlinks that `nono pull` creates under `~/.omp`
and `~/.pi` are intentional; they point into the installed package store. After
installing or updating packs, restart the agent's nono session.

The Oh My Zsh function in `.oh-my-zsh/custom/nono.zsh` preserves Stow-managed
profile symlinks when running `nono profile promote <name>`. Load it into an
existing shell with:

```zsh
source ~/.dotfiles/.oh-my-zsh/custom/nono.zsh
nono profile promote omp --diff
nono profile promote omp
```

For symlinked profiles, it validates the draft, shows a diff, asks for confirmation
(unless `--yes`), and copies the draft to the resolved repository file. The draft
is retained. This is a manual apply workflow, not native promotion: it does not
provide nono's base-hash conflict checks or atomic replacement. Run it outside
the sandbox and avoid concurrent profile edits. Regular profiles and other nono
commands pass through to the executable unchanged.

The composed OMP profile extends `nolabs-ai/omp`, `github`, and `aws`. The
`github` overlay owns GitHub credential capture and `gh` configuration grants.
The `aws` overlay owns host-side SigV4 signing and the sandbox's placeholder
credentials; it currently uses the `bedrock` AWS profile in `us-east-1` for STS,
Bedrock, and Bedrock Runtime.

When applying drafts from `~/.config/nono/profile-drafts`, promote the
dependencies before the composed profile, outside the sandbox:

```zsh
nono profile promote aws
nono profile promote github
nono profile validate --draft omp
nono profile promote omp
nono run --profile omp -- omp
```

Keep `~/.aws` protected. OMP uses placeholder keys for provider availability
and client-side signing; the nono supervisor resolves the real AWS profile and
re-signs requests. Existing sandbox permissions do not change until restart.

Pi reuses the same `github` and `aws` overlays alongside `nolabs-ai/pi`, while
keeping its Pi Lens and SSH known-hosts grants in the Pi profile. After the
shared profiles are promoted, apply the Pi draft outside the sandbox:

```zsh
nono run --profile pi -- pi
```

### Pi

Install the Pi coding agent:

```shell
pnpm add -g --ignore-scripts @earendil-works/pi-coding-agent
```

Start Pi and authenticate each provider that should be available to the parent
session or subagents:

```shell
pi
```

Then run `/login` and complete the flows for **OpenAI Codex** and **Amazon
Bedrock**. Both providers are intentionally enabled. The default parent model
is OpenAI Codex Terra, while specialist subagents can use either provider.
After adding a provider or changing `enabledModels`, restart Pi: the model
picker's scoped model list is created when a session starts.

The stowed configuration lives at `.pi/agent/settings.json` (linked to
`~/.pi/agent/settings.json`). Use `/model` to change the parent model in a
running session. A default provider is not a provider lock: every authenticated
model listed in `enabledModels` remains selectable, and subagents use their
fully-qualified configured model independently of the parent model.

#### Model routing

The configuration uses a cost-aware three-tier model mix:

- **Luna** for cheap, bounded reconnaissance and generic delegation.
- **Terra** for normal substantial work, including source-backed research.
- **Sol** for adversarial reviews where deeper reasoning is worth the cost.
- **Claude Sonnet/Opus** where their larger context or implementation/advisory
  strengths are more valuable than minimizing Bedrock usage.

`subagents.defaultModel` is Luna at low thinking. It is a safe fallback for
future or package-provided agents that do not define a model or thinking level;
it does not override the explicit mappings below.

| Subagent             | Primary model and thinking | Fallbacks                                        | Why                                                                                                                                                 |
| -------------------- | -------------------------- | ------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `scout`              | OpenAI Codex Luna, low     | Bedrock Luna, then Claude Haiku 4.5              | Fast, inexpensive codebase reconnaissance and compact handoffs.                                                                                     |
| `delegate`           | OpenAI Codex Luna, low     | Bedrock Luna, then Claude Sonnet 4.6             | Routine, well-scoped tasks and summaries should use the lowest capable tier.                                                                        |
| `researcher`         | OpenAI Codex Terra, medium | Bedrock Terra, then Claude Sonnet 4.6 / Sonnet 5 | Terra is the normal source-evaluation and synthesis tier; Sonnet fallbacks preserve access to much larger context when needed.                      |
| `worker`             | Claude Sonnet 5, high      | Claude Sonnet 4.6                                | The primary implementation lane favors Sonnet's coding behavior and 1M-token context. High thinking reduces costly implementation/rework cycles.    |
| `reviewer`           | OpenAI Codex Sol, high     | Bedrock Sol, then Claude Opus 4.8 / Sonnet 5     | Reviews are adversarial correctness/security work, so deeper reasoning is deliberate. Use a one-off Terra override for inexpensive routine reviews. |
| `oracle` (`advisor`) | Claude Opus 4.8, high      | Claude Sonnet 5, then Claude Fable 5             | Rare high-stakes architecture and decision-consistency checks optimize for judgment rather than cost.                                               |

Fallbacks preserve the same model across providers first: Codex Luna, Terra,
or Sol retries through its Bedrock equivalent before moving to a different Claude
model. The later fallback models are used only for retryable provider/model
failures, such as rate limits or temporary availability errors; they are not a
task-based quality escalation mechanism. Use a per-run `model` override when a
specific task needs a different tier.

For example, run a bounded implementation with Terra without changing the
persistent worker mapping:

```text
/run worker[model=openai-codex/gpt-5.6-terra:high] "Implement the approved plan"
```

#### Installed Pi packages

The `packages` list in `.pi/agent/settings.json` installs the following
extensions and skill sources when Pi starts. Package changes also require a Pi
restart.

| Package                                      | Purpose                                                                                                                                    |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| [`npm:pi-subagents`][pi-subagents]           | Adds the multi-model subagent fleet, including the `scout`, `delegate`, `researcher`, `worker`, `reviewer`, and `oracle` roles used above. |
| [`npm:pi-web-access`][pi-web-access]         | Provides web research tools such as `web_search`, `fetch_content`, and `get_search_content`, enabling source-backed researcher runs.       |
| [`git:github.com/apmantza/pi-lens`][pi-lens] | Adds code-intelligence tools: symbol/module discovery, targeted reads, LSP diagnostics, and optional AST/LSP navigation tools.             |
| [`npm:@piotr-oles/pi-reflag`][pi-reflag]     | Provides reflag, a search/command utility used for efficient repository inspection. `brew install ripgrep fd`                              |
| [`git:github.com/cli/cli`][gh-cli]           | Supplies GitHub CLI-related agent skills and usage guidance. The `gh` executable itself is installed separately through Homebrew.          |

Packages can expose tools, commands, agents, or skills. A skill's guidance is
loaded only when the task matches it; package installation alone does not force
a subagent or tool to run. Keep package names in `settings.json` rather than
installing them ad hoc so the Pi environment is reproducible across machines.

[pi-subagents]: https://github.com/nicobailon/pi-subagents#readme "Pi Subagents"
[pi-web-access]: https://github.com/nicobailon/pi-web-access#readme "Pi Web Access"
[pi-lens]: https://github.com/apmantza/pi-lens#readme "Pi Lens"
[pi-reflag]: https://github.com/piotr-oles/pi-extensions/tree/main/packages/pi-reflag "Pi Reflag"
[gh-cli]: https://cli.github.com/manual/ "GitHub CLI"
[nono.sh]: https://nono.sh/ "Nono"
