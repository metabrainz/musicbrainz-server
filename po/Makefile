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

mb_server.pot: $(POTFILES) $(TT) $(wildcard extract_pot_templates)
	@echo "Rebuilding the mb_server.pot file"; 
	@echo "- Update templates .pot"; 
	@find ../root -path ../root/statistics -prune -o -type f -name \*.tt -print | sort | ./extract_pot_templates | msguniq -s > mb_server.pot;
	@echo "- Update code .pot"
	@xgettext --from-code utf-8 --keyword=__ --keyword=l --keyword=ln:1,2 --keyword=__x --keyword=__nx:1,2 --keyword=__n:1,2 -Lperl -o mb_server.pot --add-comments=translators -j $(POTFILES)

iso_codes.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the iso_codes.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db iso_codes | msguniq -s > iso_codes.pot

relationships.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the relationships.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db relationships | msguniq -s > relationships.pot

attributes.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the attributes.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db attributes | msguniq -s > attributes.pot

instruments.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the instruments.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db instruments | msguniq -s > instruments.pot

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
