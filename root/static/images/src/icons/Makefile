
ICONS = add_row.png delete_row.png collapse.png expand.png up.png down.png guesscase.png guesscase.32x32.png help.png

ALL:  $(ICONS)

%.png: %.svg
	convert $< $@

clean:
	$(RM) $(ICONS)

