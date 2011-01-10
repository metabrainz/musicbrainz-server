
ICONS = add_row.png delete_row.png collapse.png expand.png up.png down.png

ALL:  $(ICONS)

%.png: %.svg
	convert $< $@

clean:
	$(RM) $(ICONS)