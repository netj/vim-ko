# Vim 한글 번역을 위한 Makefile
# Author: Jaeho Shin <netj@sparcs.org>
# Created: 2007-04-17

AUTHOR?=$(shell cat AUTHOR || echo 신재호)

VERSION:=7.3
REVISION:=$(shell git rev-parse HEAD | cut -b1-6)

VIMREPO:=https://vim.googlecode.com/hg/
VIMCOPY:=vim

.PHONY: usage help translate zip install  tutor po menu man

usage:
	@echo "vim-ko $(VERSION)-$(REVISION) (https://github.com/netj/vim-ko)"
	@echo "사용법:"
	@echo "  make usage"
	@echo "  make help"
	@echo "  make translate D=usr_01"
	@echo "  make zip"
	@echo "  make install"
	@echo
	@echo "  make tutor"
	@echo "  make po"
	@echo "  make menu"
	@echo "  make man"


## 설명서
PACKAGE:=vim-$(VERSION)-doc-ko-$(REVISION).zip
TXTS:=doc/*.kox README-ko
TAGS:=doc/tags-ko

# 설명서 묶음
$(PACKAGE): $(TXTS) $(TAGS)
	zip -r $@ $^

# 번역중인 설명서 설치
zip: $(PACKAGE)
install: $(PACKAGE)
	mkdir -p ~/.vim/
	unzip -o $< doc/* -d ~/.vim/

$(TAGS): $(TXTS)
	vim +"helptags doc" +"qa!"

# 섦명서 번역에 앞서 읽어볼 도움말
help:
	vim +"help help-translated" +"only" +"norm zt"

# 설명서 번역
#  (D=usr_01와 같이 설명서 지정) 
translate: doc/$(D).kox $(VIMCOPY)/runtime/doc/$(D).txt
	@vim -N +1 $< \
	    +"set fenc=utf-8 | set fencs=ucs-bom,utf-8,korea" \
	    +"set noet | set listchars=tab:>.,eol:$$ | set list" \
	    +"new +1 $(VIMCOPY)/runtime/doc/$(D).txt" \
	    +"set scrollbind | norm wK" \
	    +"set scrollbind | norm \`\"" \
	    +"vnew MEMO | set noscrollbind | norm Hw" \
	    +"vertical resize 80" \

# 설명서 번역 준비
doc/%.kox: $(VIMCOPY)/runtime/doc/%.txt
	@\
	if [ -e $@ ]; then touch $@; \
	else \
	set -e; \
	cp $< $@; \
	runvim() { \
	    f=$$1; shift; \
	    vim -N +1 $$f \
	        +'set noet' \
	        +'norm no:spl doc/usr_toc.koxgg/pW"zy$$cD"zp0"yy$$uc' \
	        +'norm no0f|lv;hyW@y0"ty$$uc' \
	        +'norm no/"npV:s/"npa/"mp0"ry$$uc' \
	        "$$@" \
	        +'wq'; \
	}; \
	runvim $@ \
	    +'norm ggnoFor Vim version $(VERSION).0"ny$$uoVim version $(VERSION) 대상.0"my$$uc@r@t@r@t' \
	    +'norm ggnoLast change:0"ny$$uo새로고침:0"my$$uc@r@t@r@t' \
	    +'norm ggno^Copyright: see |manual-copyright|0"ny$$uo저작권: |manual-copyright| 참고0"my$$uc@r' \
	; \
	runvim $@ \
	    +'norm ggnoVIM USER MANUAL - by Bram Moolenaar0"ny$$uoVIM 사용설명서 - Bram Moolenaar 저0"my$$uc@r:center' \
	    +'norm yyp:set etV:retab!0vf-r WC     '"$(AUTHOR)"' 역:set noetV:retab!' \
	    +'norm gglvf*hy``@y:center' \
	; \
	runvim $@ \
	    +'norm ggno *Next chapter:0"ny$$uo다음 장:0"my$$uc@r@t@r@t' \
	    +'norm ggno *Previous chapter:0"ny$$uo이전 장:0"my$$uc@r@t' \
	    +'norm ggnoTable of contents:0"ny$$uo   차례:0"my$$uc@r' \
	    +'norm gg' \
	; \
	fi

# Vim 소스코드 가져오기
$(VIMCOPY):
	hg clone $(VIMREPO) $(VIMCOPY)
$(VIMCOPY)/%: $(VIMCOPY)


## 길잡이
tutor: $(VIMCOPY)
	cd $(VIMCOPY)/runtime/tutor && vim tutor.ko.utf-8
$(VIMCOPY)/runtime/tutor/tutor.ko.euc: $(VIMCOPY)/runtime/tutor/tutor.ko.utf-8
	vim $< +"wq! ++enc=euc-kr $@"

## 프로그램 메시지
po: $(VIMCOPY)
	cd $(VIMCOPY)/src/po && vim ko.UTF-8.po

## GUI 메뉴
menu: $(VIMCOPY)
	cd $(VIMCOPY)/runtime/lang && vim menu_ko_kr.utf-8.vim
$(VIMCOPY)/runtime/lang/menu_ko_kr.euckr.vim: \
    $(VIMCOPY)/runtime/lang/menu_ko_kr.utf-8.vim
	vim $< +"wq! ++enc=euc-kr $@"

## 매뉴얼 페이지
man: $(VIMCOPY)
	cd $(VIMCOPY)/runtime/doc && for m in *.1; do case $$m in *-*) continue ;; esac; k=$${m%.1}-ko.UTF-8.1; [ -e $$k ] || cp -a $$m $$k; done
	cd $(VIMCOPY)/runtime/doc && vim *-ko*.1

