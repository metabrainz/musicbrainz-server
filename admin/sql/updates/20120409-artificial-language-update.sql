-- MBS-1799, Add ISO 639-3 language codes to the database

INSERT INTO language (iso_code_3, name) VALUES ('qaa', '[Artificial (Other)]');

UPDATE release SET language=qaa.id
       FROM language AS art,language AS qaa
       WHERE release.language = art.id AND art.iso_code_2b = 'art' AND qaa.iso_code_3 = 'qaa';
