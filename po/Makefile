POTFILES=$(sort $(shell find ../lib -type f -name \*.pm)) \
         $(sort $(shell find ../lib -type f -name \*.pl)) 

TT=$(sort $(shell find ../root -type f -name \*.tt))

POFILES=$(wildcard *.po)
MOFILES=$(POFILES:.po=.mo)

all: $(MOFILES) check

install: $(MOFILES)	
	@for file in $(MOFILES); do \
	     	lang=`echo $$file | sed 's/\.mo//'`; \
		install -d ../lib/LocaleData/$$lang/LC_MESSAGES/; \
		echo "Installing $$file to ../lib/LocaleData/$$lang/LC_MESSAGES/mb_server.mo"; \
		install -m 0644 $$file ../lib/LocaleData/$$lang/LC_MESSAGES/mb_server.mo; \
	done

mb_server.pot: $(POTFILES) $(TT) $(wildcard extract_pot)
	@echo "Rebuilding the .pot file"; 
	@echo "- Update templates' and database strings' .pot"; 
	@find ../root -type f -name \*.tt | sort | ./extract_pot | msguniq -s > mb_server.pot;
	@echo "- Update code .pot"
	@xgettext --from-code utf-8 --keyword=__ --keyword=l --keyword=ln:1,2 --keyword=__x --keyword=__nx:1,2 --keyword=__n:1,2 -Lperl -o mb_server.pot --add-comments=translators -j $(POTFILES)

clean:
	rm -f $(MOFILES)

%.mo: %.po
	@msgfmt -o $@ $<

%.po: mb_server.pot
	@echo -n "Merging $@"
	@msgmerge $@ mb_server.pot -o $@.new 2>&1

check:
	@for file in $(POFILES); do \
		lang=`echo $$file | sed 's/\.po//'`; \
		printf "$$lang: "; \
		msgfmt -o /dev/null -c -v --statistics $$lang.po;\
	done
