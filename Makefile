# vim-ko Makefile
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2007-04-17

VERSION=7.0
LANG=ko
REVISION=0

.PHONY: help doc doc-help doc-install po menu man

help:
	@echo "Usage: make help|doc|doc-help|doc-install|po|menu|man"


# 설명서
DOC=vim-$(VERSION)-doc-$(LANG)-$(REVISION).tar.bz2
DOCS=$(TXTS) $(TAG)
TXTS=doc/*.$(LANG)x README-$(LANG)
TAG=doc/tags-$(LANG)

doc: $(DOC)
$(DOC): $(shell find $(DOCS))
	tar cvjf $@ $(DOCS)
$(TAG): $(TXTS)
	vim +"helptags doc" +"qa!"

doc-help:
	vim +"help help-translated" +"only" +"norm zt"

doc-install: $(TAG)
	[ -e "$$HOME/.vim/doc" ] || ln -sfn "$$PWD/doc" "$$HOME/.vim/doc"


# Vim 소스코드 가져오기
VIM7=vim7
$(VIM7):
	svn co https://svn.sourceforge.net/svnroot/vim/branches/vim7.0/ $(VIM7)

# 프로그램 메시지
po: $(VIM7)
	cd $(VIM7)/src/po && vim ko.po

# GUI 메뉴
menu: $(VIM7)
	cd $(VIM7)/runtime/lang && vim menu_ko_kr.utf-8.vim
$(VIM7)/runtime/lang/menu_ko_kr.euckr.vim: $(VIM7)/runtime/lang/menu_ko_kr.utf-8.vim
	vim $< +"wq! ++enc=euc-kr $@"

# 매뉴얼 페이지
man: $(VIM7)
	cd $(VIM7)/runtime/doc/*-ko*.1

