# Directories
DEFDIR := source
GRFDIR := graphs
IMGDIR := images

# File extensions
DEFEXT := json
GRFEXT := dot
IMGEXT := svg

# File lists
DEFINITIONS := $(wildcard $(DEFDIR)/*.$(DEFEXT))
GRAPHS      := $(patsubst $(DEFDIR)/%,$(GRFDIR)/%,$(DEFINITIONS:.$(DEFEXT)=.$(GRFEXT)))
IMAGES      := $(patsubst $(DEFDIR)/%,$(IMGDIR)/%,$(DEFINITIONS:.$(DEFEXT)=.$(IMGEXT)))
TEMPFILES   := $(IMAGES:.svg=.normalized.svg)

# Default target
all: $(IMAGES)

# JSON/SQL to DOT
$(GRAPHS): $(DEFINITIONS)
	@./write_graphs.pl --output-dir "$(GRFDIR)" $?

# DOT to (normalized) SVG
$(IMGDIR)/%.$(IMGEXT): $(GRFDIR)/%.$(GRFEXT)
	@echo "Drawing $@"
	@dot -Tsvg $< \
		| scour \
			-o $@ \
			--indent=none \
			--keep-editor-data \
			--enable-id-stripping \
			--protect-ids-noninkscape

# Normalized SVG files (after Inkscape editing)
normalized: $(IMAGES)
	@for file in $(IMAGES); \
	do \
		scour \
			-i $$file \
			-o $$file.normalized.svg \
			--indent=none \
			--keep-editor-data \
			--enable-id-stripping \
			--protect-ids-noninkscape; \
		if diff -q $$file $$file.normalized.svg >/dev/null; \
		then echo "(Skipped $$file)"; \
		rm -f $$file.normalized.svg; \
		else echo "Normalized $$file"; \
		mv $$file.normalized.svg $$file; \
		fi; \
	done

clean:
	@rm -f $(TEMPFILES)

clean-all:
	@rm -f $(TEMPFILES) $(IMAGES) $(GRAPHS)

.PHONY: all normalized clean clean-all
