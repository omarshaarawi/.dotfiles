#!/bin/bash

SCRIPTS_DIR=".scripts"
CONFIG_DIR=".config"

if [ ! -d "$HOME/$SCRIPTS_DIR" ]; then
  mkdir "$HOME/$SCRIPTS_DIR"
fi

if [ ! -d "$HOME/$CONFIG_DIR" ]; then
  mkdir "$HOME/$CONFIG_DIR"
fi

stow .
