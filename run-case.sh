#!/usr/bin/env bash

ACTIVATE_SCRIPT="../activate"

FLUID_CMD="cd FLUID && ./run.sh --parallel"
SOLID_CMD="cd SOLID && ./run.sh"

SESSION_NAME="fsi_session"

tmux new-session -d -s $SESSION_NAME

tmux send-keys -t $SESSION_NAME "source $ACTIVATE_SCRIPT && $FLUID_CMD" C-m
tmux split-window -h -t $SESSION_NAME
tmux send-keys -t $SESSION_NAME "source $ACTIVATE_SCRIPT && $SOLID_CMD" C-m
tmux attach -t $SESSION_NAME
