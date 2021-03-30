#!/bin/bash

dir=$1

wm_focus() {
	awesome-client 'awesome.emit_signal("navigator::focus", "'"$dir"'")'
}

case "$dir" in
	"left")
		if [ "$(tmux display-message -p '#{pane_at_left}')" -ne 1 ]; then tmux select-pane -L; else wm_focus; fi ;;
	"right")
		if [ "$(tmux display-message -p '#{pane_at_right}')" -ne 1 ]; then tmux select-pane -R; else wm_focus; fi ;;
	"up")
		if [ "$(tmux display-message -p '#{pane_at_top}')" -ne 1 ]; then tmux select-pane -U; else wm_focus; fi ;;
	"down")
		if [ "$(tmux display-message -p '#{pane_at_bottom}')" -ne 1 ]; then tmux select-pane -D; else wm_focus; fi ;;
esac
