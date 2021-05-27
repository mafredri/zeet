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

## Note

If startup is slow, ensure directories are secure via `compaudit`. For instance, on macOS:

```
chmod 0755 /usr/local/share/zsh/site-functions /usr/local/share/zsh
```
