# pull_diags.nvim
*pull_diags.nvim* is a plugin to enable pull diagnostics for nvim versions
< 0.10.

[Pull diagnostics](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#textDocument_pullDiagnostics) are preferable to push diagnostics because the client
(nvim) is able to manage the frequency of code diagnostic requests better
than the LSP backend can.

## Installation
With [Lazy.nvim](https://github.com/folke/lazy.nvim/tree/main):
```lua
{ "catlee/pull_diags.nvim", event = "LspAttach" }
```
