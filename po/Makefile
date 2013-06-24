POTFILES=$(sort $(shell find ../lib -type f -name \*.pm)) \
         $(sort $(shell find ../lib -type f -name \*.pl)) 

TT=$(sort $(shell find ../root -path ../root/statistics -prune -o -type f -name \*.tt -print))
STATTT=$(sort $(shell find ../root/statistics -type f -name \*.tt -print))

POFILES=$(wildcard *.po)
MOFILES=$(POFILES:.po=.mo)

all: $(MOFILES) check

all_quiet: $(MOFILES) check_quiet

deploy: $(MOFILES)
	@for file in $(MOFILES); do \
			catalog=`echo $$file | sed 's/\.\([^.]*\)\.mo//'`; \
			lang=`echo $$file | sed -e 's/^\([^.]*\)\.//' -e 's/\.mo//'`; \
		install -d ../lib/LocaleData/$$lang/LC_MESSAGES/; \
		install -m 0644 $$file ../lib/LocaleData/$$lang/LC_MESSAGES/$$catalog.mo; \
	done

install: $(MOFILES)
	@for file in $(MOFILES); do \
			catalog=`echo $$file | sed 's/\.\([^.]*\)\.mo//'`; \
			lang=`echo $$file | sed -e 's/^\([^.]*\)\.//' -e 's/\.mo//'`; \
		install -d ../lib/LocaleData/$$lang/LC_MESSAGES/; \
		echo "Installing $$file to ../lib/LocaleData/$$lang/LC_MESSAGES/$$catalog.mo"; \
		install -m 0644 $$file ../lib/LocaleData/$$lang/LC_MESSAGES/$$catalog.mo; \
	done

pot: mb_server.pot statistics.pot languages.pot languages_notrim.pot scripts.pot relationships.pot attributes.pot instruments.pot instrument_descriptions.pot

mb_server.pot: $(POTFILES) $(TT) $(wildcard extract_pot_templates)
	@echo "Rebuilding the mb_server.pot file"; 
	@echo "- Update templates .pot"; 
	@find ../root -path ../root/statistics -prune -o -type f -name \*.tt -print | sort | ./extract_pot_templates | msguniq -s > mb_server.pot;
	@echo "- Update code .pot"
	@xgettext --from-code utf-8 --keyword=__ --keyword=l --keyword=lp:1,2c --keyword=N_lp:1,2c --keyword=N_l --keyword=ln:1,2 --keyword=N_ln:1,2 --keyword=__x --keyword=__nx:1,2 --keyword=__n:1,2 -Lperl -o mb_server.pot --add-comments=translators -j $(POTFILES)

statistics.pot: $(STATTT) $(wildcard extract_pot_db) $(wildcard extract_pot_templates)
	@echo "Rebuilding the statistics.pot file";
	@echo "- Update templates .pot"; 
	@find ../root/statistics -type f -name \*.tt -print | sort | ./extract_pot_templates | msguniq -s > statistics_tmpl.pot;
	@echo "- Update database .pot";
	@./extract_pot_db statistics | msguniq -s > statistics_db.pot
	@echo "- Merge";
	@msgcat -o statistics.pot statistics_db.pot statistics_tmpl.pot
	@rm statistics_db.pot statistics_tmpl.pot

countries.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the countries.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db countries | msguniq -s > countries.pot

languages.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the languages.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db languages | msguniq -s > languages.pot

languages_notrim.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the languages.pot file (no trimming)";
	@echo "- Update database .pot";
	@./extract_pot_db languages_notrim | msguniq -s > languages_notrim.pot

scripts.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the scripts.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db scripts | msguniq -s > scripts.pot

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

instrument_descriptions.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the instrument_descriptions.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db instrument_descriptions | msguniq -s > instrument_descriptions.pot

clean:
	rm -f $(MOFILES)

%.mo: %.po
	@msgfmt -o $@ $<

check:
	@for file in $(POFILES); do \
		lang=`echo $$file | sed 's/\.po//'`; \
		printf "$$lang: "; \
		msgfmt -o /dev/null -c -v --statistics $$lang.po;\
	done

check_quiet:
	@for file in $(POFILES); do \
		msgfmt -o /dev/null -c $$file;\
	done
