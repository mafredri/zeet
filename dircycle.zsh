# Cycle through direcotries on the directory stack (visited directories).
# Cycling does not trigger a directory change, therefore we force prompt-pure
# to refresh the prompt.

_update-cycled() {
	setopt localoptions nopushdminus
	builtin pushd -q $1 &>/dev/null

	# Trigger a prompt update for pure
	# vcs_info
	prompt_pure_async_tasks
	prompt_pure_preprompt_render
}

insert-cycledleft() { _update-cycled +1 || true }
zle -N insert-cycledleft

insert-cycledright() { _update-cycled -0 || true }
zle -N insert-cycledright

# Ctrl+Shift+Left (previous)
bindkey "\e[1;6D" insert-cycledleft
# Ctrl+Shift+Right (next)
bindkey "\e[1;6C" insert-cycledright
