
ICONS = add_row.png delete_row.png collapse.png expand.png

ALL:  $(ICONS)

%.png: %.svg
	convert $< $@

clean:
	$(RM) $(ICONS)