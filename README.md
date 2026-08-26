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

Once Homebrew is installed the remainder of the prerequisites can be installed with the following command:

```shell
brew install git tmux stow zsh gh
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
