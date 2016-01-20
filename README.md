# zeet

My personal zsh setup, ready for checkout on any machine.

## Features

* Automatically updates itself in the background, non-blocking.

## Setup

Start zsh and execute the following commands:

```shell
git clone --quiet https://github.com/mafredri/zeet.git ~/.zsh &&
(cd ~/.zsh && git submodule update --init --quiet) &&
echo "source ~/.zsh/zeet.zsh" >> ~/.zshrc &&
source ~/.zshrc && echo "Installation complete"
```
