# vimhelp-ko Makefile
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2007-04-17

NAME=vimhelp-$(LANG)
VERSION=7.0
REVISION=0
LANG=ko

SRCS=$(DOCS) $(TAGS)
DOCS=doc/*.$(LANG)x README-$(LANG)
TAGS=doc/tags-$(LANG)

.PHONY: help install

$(NAME)-$(VERSION)-$(REVISION).tar.bz2: $(shell find $(SRCS))
	tar cvjf $@ $(SRCS)

$(TAGS): $(DOCS)
	vim +"helptags doc" +"qa!"

install: $(TAGS)
	[ -e "$$HOME/.vim/doc" ] || ln -sfn "$$PWD/doc" "$$HOME/.vim/doc"

help:
	vim +"help help-translated" +"only" +"norm zt"

