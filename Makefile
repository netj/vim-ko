# vim-ko Makefile
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2007-04-17

AUTHOR?=$(shell cat AUTHOR || echo 신재호)

VERSION=7.0
REVISION=0

VIMREPO=https://svn.sourceforge.net/svnroot/vim/branches/vim7.0/
VIMCOPY=vim

.PHONY: help doc doc-help doc-install doc-translate po menu man

help:
	@echo "vim-ko $(VERSION)-$(REVISION) (http://code.google.com/p/vim-ko)"
	@echo "Usage:"
	@echo "  make help"
	@echo "  make doc"
	@echo "  make doc-help"
	@echo "  make doc-install"
	@echo "  make doc-translate D=usr_01"
	@echo "  make po"
	@echo "  make menu"
	@echo "  make man"


# 설명서
DOC=vim-$(VERSION)-doc-ko-$(REVISION).tar.bz2
DOCS=$(TXTS) $(TAG)
TXTS=doc/*.kox README-ko
TAG=doc/tags-ko

# 설명서 묶음
doc: $(DOC)
$(DOC): $(shell find $(DOCS))
	tar cvjf $@ $(DOCS)
$(TAG): $(TXTS)
	vim +"helptags doc" +"qa!"

# 번역에 앞서 읽어볼 도움말
doc-help:
	vim +"help help-translated" +"only" +"norm zt"

# 번역중인 설명서 설치
doc-install: $(TAG)
	[ -e "$$HOME/.vim/doc" ] || ln -sfn "$$PWD/doc" "$$HOME/.vim/doc"

# 설명서 번역
#  (D=usr_01와 같이 설명서 지정) 
doc-translate: doc/$(D).kox
	vim +1 $< \
	    +"set fenc=utf-8 | set fencs=ucs-bom,utf-8,korea" \
	    +"set noet | set listchars=tab:>.,eol:$$ | set list" \
	    +"new +1 $(VIMCOPY)/runtime/doc/$(D).txt" \
	    +"set scrollbind | norm wK" \
	    +"set scrollbind | norm \`\"" \
	    +"vnew MEMO | set noscrollbind | norm Hw" \
	    +"vertical resize 80" \

define run-vim
f() { \
    f=$$1; shift; \
    vim +1 $$f \
        +'norm no:spl doc/usr_toc.koxgg/pW"zy$$cD"zp0"yy$$uc' \
        +'norm no0f|lv;hyW@y0"ty$$uc' \
        +'norm no/"npV:s/"npa/"mp0"ry$$uc' \
        "$$@" \
        +'wq'; \
}; f
endef
# 설명서 번역 준비
doc/%.kox: $(VIMCOPY)/runtime/doc/%.txt
	cp $< $@
	$(run-vim) $@ \
	    +'norm ggnoFor Vim version 7.0.0"ny$$uoVim version 7.0 대상.0"my$$uc@r@t@r@t' \
	    +'norm ggnoLast change:0"ny$$uo새로고침:0"my$$uc@r@t@r@t' \
	    +'norm ggno^Copyright: see |manual-copyright|0"ny$$uo저작권: |manual-copyright| 참고0"my$$uc@r'
	@$(run-vim) $@ \
	    +'norm ggnoVIM USER MANUAL - by Bram Moolenaar0"ny$$uoVIM 사용설명서 - Bram Moolenaar 저0"my$$uc@r:center' \
	    +'norm yyp0vf-r WC     '"$(AUTHOR)"' 역' \
	    +'norm gglvf*hy``@y:center'
	@$(run-vim) $@ \
	    +'norm ggno *Next chapter:0"ny$$uo다음 장:0"my$$uc@r@t@r@t' \
	    +'norm ggno *Previous chapter:0"ny$$uo이전 장:0"my$$uc@r@t' \
	    +'norm ggnoTable of contents:0"ny$$uo   차례:0"my$$uc@r' \
	    +'norm gg'

# Vim 소스코드 가져오기
$(VIMCOPY) $(VIMCOPY)/%:
	svn co $(VIMREPO) $(VIMCOPY)

# 프로그램 메시지
po: $(VIMCOPY)
	cd $(VIMCOPY)/src/po && vim ko.po

# GUI 메뉴
menu: $(VIMCOPY)
	cd $(VIMCOPY)/runtime/lang && vim menu_ko_kr.utf-8.vim
$(VIMCOPY)/runtime/lang/menu_ko_kr.euckr.vim: \
    $(VIMCOPY)/runtime/lang/menu_ko_kr.utf-8.vim
	vim $< +"wq! ++enc=euc-kr $@"

# 매뉴얼 페이지
man: $(VIMCOPY)
	cd $(VIMCOPY)/runtime/doc && vim *-ko*.1

