# zeet

My personal zsh setup, ready for checkout on any machine.

## Features

* Automatically updates itself in the background, non-blocking.

## Setup

Start zsh and execute the following commands:

```shell
git clone --quiet --recurse-submodules=. https://github.com/mafredri/zeet.git ~/.zsh \
	&& echo "source ~/.zsh/zeet.zsh" >> ~/.zshrc \
	&& source ~/.zshrc \
	&& echo "Installation complete"
```
