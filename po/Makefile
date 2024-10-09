# Allows passing file names with spaces in the prerequisite lists.
SED_ESCAPE_SPACES:=sed -e 's/ /\\ /g'
# Controls the output page width of msgcat and msguniq.
MSGWRAP:=79

GIT_LS_PERL:=git ls-files -- \
	':(top,glob)lib/**/*.pm' \
	':(top,glob,exclude)lib/**/*Admin*.pm' \
	':(top,glob,exclude)lib/**/*Admin*/**/*.pm' \
	| $(SED_ESCAPE_SPACES)

GIT_LS_JS:=git ls-files -- \
	':(top,glob)root/**/*.js' \
	':(top,glob,exclude)root/admin/**/*.js' \
	':(top,glob,exclude)root/report/**/*.js' \
	':(top,glob,exclude)root/static/scripts/tests/**/*.js' \
	':(top,glob,exclude)root/static/build/**/*.js' \
	':(top,glob,exclude)root/static/lib/**/*.js' \
	':(top,glob,exclude)root/statistics/**/*.js' \
	| $(SED_ESCAPE_SPACES)

GIT_LS_TT:=git ls-files -- \
	':(top,glob)root/**/*.tt' \
	':(top,glob,exclude)root/admin/**/*.tt' \
	':(top,glob,exclude)root/statistics/**/*.tt' \
	| $(SED_ESCAPE_SPACES)

GIT_LS_STATTT:=git ls-files -- \
	':(top,glob)root/statistics/**/*.tt' \
	| $(SED_ESCAPE_SPACES)

GIT_LS_REPORTJS:=git ls-files -- \
	':(top,glob)root/report/**/*.js' \
	| $(SED_ESCAPE_SPACES)

GIT_LS_STATJS:=git ls-files -- \
	':(top,glob)root/statistics/**/*.js' \
	| $(SED_ESCAPE_SPACES)

POTFILES=$(shell $(GIT_LS_PERL))
JSFILES=$(shell $(GIT_LS_JS))
TT=$(shell $(GIT_LS_TT))
STATTT=$(shell $(GIT_LS_STATTT))
STATJS=$(shell $(GIT_LS_STATJS))
REPORTJS=$(shell $(GIT_LS_REPORTJS))

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

pot: mb_server.pot statistics.pot countries.pot languages.pot languages_notrim.pot scripts.pot relationships.pot attributes.pot instruments.pot instrument_descriptions.pot history.pot reports.pot

mb_server.pot: $(POTFILES) $(JSFILES) $(TT) $(wildcard extract_pot_templates)
	@echo "Rebuilding the mb_server.pot file";
	@echo "- Update templates .pot";
	@$(GIT_LS_TT) | ./extract_pot_templates | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > mb_server.pot;
	@echo "- Update code .pot"
	@$(GIT_LS_PERL) | xargs xgettext --from-code utf-8 --keyword=__ --keyword=l --keyword=lp:1,2c --keyword=N_lp:1,2c --keyword=N_l --keyword=ln:1,2 --keyword=N_ln:1,2 --keyword=__x --keyword=__nx:1,2 --keyword=__n:1,2 -Lperl -o mb_server.pot --add-comments=translators -j
	@$(GIT_LS_JS) | xargs ../script/xgettext.js > javascript.pot
	@msgcat -w $(MSGWRAP) -o mb_server.pot mb_server.pot javascript.pot
	@rm javascript.pot

statistics.pot: $(STATTT) $(STATJS) $(wildcard extract_pot_db) $(wildcard extract_pot_templates)
	@echo "Rebuilding the statistics.pot file";
	@echo "- Update templates .pot";
	@$(GIT_LS_STATTT) | ./extract_pot_templates | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > statistics_tmpl.pot;
	@$(GIT_LS_STATJS) | xargs ../script/xgettext.js > statistics_js.pot
	@echo "- Update database .pot";
	@./extract_pot_db statistics | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > statistics_db.pot
	@echo "- Merge";
	@msgcat -w $(MSGWRAP) -o statistics.pot statistics_db.pot statistics_tmpl.pot statistics_js.pot
	@rm statistics_db.pot statistics_tmpl.pot statistics_js.pot

reports.pot: $(REPORTJS)
	@echo "Rebuilding the reports.pot file";
	@echo "- Update templates .pot";
	@$(GIT_LS_REPORTJS) | xargs ../script/xgettext.js > reports.pot

countries.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the countries.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db countries | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > countries.pot

languages.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the languages.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db languages | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > languages.pot

languages_notrim.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the languages.pot file (no trimming)";
	@echo "- Update database .pot";
	@./extract_pot_db languages_notrim | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > languages_notrim.pot

scripts.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the scripts.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db scripts | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > scripts.pot

relationships.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the relationships.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db relationships | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > relationships.pot

attributes.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the attributes.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db attributes | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > attributes.pot

instruments.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the instruments.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db instruments | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > instruments.pot

instrument_descriptions.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the instrument_descriptions.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db instrument_descriptions | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > instrument_descriptions.pot

history.pot: $(wildcard extract_pot_db)
	@echo "Rebuilding the history.pot file";
	@echo "- Update database .pot";
	@./extract_pot_db history | msguniq -w $(MSGWRAP) -s | ./format_extracted_comments > history.pot

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

test_source:
	@../t/no_gettext_for_admin.sh

.PHONY: all all_quiet check check_quiet clean pot test_source
