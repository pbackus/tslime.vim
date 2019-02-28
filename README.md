tslime.vim
==========

⚠️ WARNING: This fork of tslime is not compatible with other versions!

`tslime.vim` allows you to easily copy text from a Vim buffer into a pane in a
running tmux session. It can be used to communicate with a shell, interactive
interpreter, or REPL.

Basic functionality is documented below. Documentation is also available
through Vim's help system; use `:help tslime` after generating help tags (your
plugin manager may do so automatically).

Settings
--------

You can tell tslime.vim to use the current session and current window; this
let's you avoid specifying this on every upstart of vim.

```vim
let g:tslime_always_current_session = 1
let g:tslime_always_current_window = 1
```

These are disabled by default, meaning you will have the ability to choose from
every session/window/pane combination.

Setting Keybindings
-------------------

In this fork of tslime.vim, keybindings are not set automatically for you.
Instead, you can map whatever you'd like to one of the plugin-specific bindings
in your `.vimrc` file.

To send a selection in visual mode to vim, set the following in your `.vimrc`:

``` vim
xmap <your_key_combo> <Plug>(TslimeSendSelection)
```

To send any text object or motion to tmux in normal mode:

```vim
nmap <your_key_combo> <Plug>(TslimeOperator)
```

Commands
--------

- `:TslimeChooseTarget` - Choose a new session/window/pane to send text to.
- `:TslimeSend` - Send the current buffer in its entirety to tmux. Also accepts
  a range of lines.
