BEGIN;

ALTER TABLE artist_ipi ADD CONSTRAINT artist_ipi_fk_artist FOREIGN KEY (artist) REFERENCES artist (id);
ALTER TABLE label_ipi ADD CONSTRAINT label_ipi_fk_label FOREIGN KEY (label) REFERENCES label (id);

COMMIT;
