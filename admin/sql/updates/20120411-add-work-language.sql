-- MBS-1798, Add work language

ALTER TABLE work ADD COLUMN language INTEGER;
ALTER TABLE work ADD CONSTRAINT work_fk_language FOREIGN KEY (language) REFERENCES language (id);

