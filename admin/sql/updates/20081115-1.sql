\set ON_ERROR_STOP 1

BEGIN;

-- missing from original list
INSERT INTO country (isocode, name) VALUES ('GS', 'South Georgia and the South Sandwich Islands');
-- added in newsletter V-2
INSERT INTO country (isocode, name) VALUES ('PS', 'Palestinian Territory'); -- added as "Palestinian Territory, Occupied"
-- changed in newsletter V-4
UPDATE country SET name = 'Macao' WHERE isocode = 'MO'; -- from Macau
-- changed in newsletter V-6
UPDATE country SET name = 'Timor-Leste' WHERE isocode = 'TL'; -- from East Timor
-- added in newsletter V-9
INSERT INTO country (isocode, name) VALUES ('AX', 'Åland Islands');
-- added in newsletter V-11
INSERT INTO country (isocode, name) VALUES ('GG', 'Guernsey');
INSERT INTO country (isocode, name) VALUES ('IM', 'Isle of Man');
INSERT INTO country (isocode, name) VALUES ('JE', 'Jersey');
-- added in newsletter V-12
INSERT INTO country (isocode, name) VALUES ('RS', 'Serbia');
-- added in newsletter VI-1
INSERT INTO country (isocode, name) VALUES ('BL', 'Saint Barthélemy');
INSERT INTO country (isocode, name) VALUES ('MF', 'Saint Martin');
-- changed in newsletter VI-2
UPDATE country SET name = 'Moldova' WHERE isocode = 'MD'; -- from Moldova, Republic of

-- see ISO 3166-3 newsletter I-3
UPDATE country SET name = 'Yugoslavia (historical, 1918-2003)' WHERE isocode = 'YU'; -- currently Yugoslavia (historical, 1918-1992)
-- see ISO 3166-3 newsletter I-4
UPDATE country SET name = 'Serbia and Montenegro (historical, 2003-2006)' WHERE isocode = 'CS'; -- currently Serbia and Montenegro

-- other minor name changes
UPDATE country SET name = 'Côte d''Ivoire' WHERE isocode = 'CI'; -- currently Cote d'Ivoire
UPDATE country SET name = 'Heard Island and McDonald Islands' WHERE isocode = 'HM'; -- currently Heard and Mc Donald Islands
UPDATE country SET name = 'Iran, Islamic Republic of' WHERE isocode = 'IR'; -- currently Iran (Islamic Republic of)
UPDATE country SET name = 'Saint Pierre and Miquelon' WHERE isocode = 'PM'; -- currently St. Pierre and Miquelon
UPDATE country SET name = 'Saint Helena' WHERE isocode = 'SH'; -- currently St. Helena
UPDATE country SET name = 'Svalbard and Jan Mayen' WHERE isocode = 'SJ'; -- currently Svalbard and Jan Mayen Islands
--UPDATE country SET name = 'Taiwan, Province of China' WHERE isocode = 'TW'; -- currently Taiwan, commented out this line as the current name is the most politically neutral
--UPDATE country SET name = 'Holy See (Vatican City State)' WHERE isocode = 'VA'; -- currently Vatican City State (Holy See)
UPDATE country SET name = 'Virgin Islands, British' WHERE isocode = 'VG'; -- currently Virgin Islands (British)
UPDATE country SET name = 'Virgin Islands, U.S.' WHERE isocode = 'VI'; -- currently Virgin Islands (U.S.)
UPDATE country SET name = 'Wallis and Futuna' WHERE isocode = 'WF'; -- currently Wallis and Futuna Islands

-- get rid of the French names
ALTER TABLE language DROP COLUMN french_name;

-- added to ISO 639-2
-- INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('ain', 'ain', 'Ainu', 1); -- added 2005-08-16, commented out because it's magically appeared in the database since I created this file.
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('alt', 'alt', 'Southern Altai', 1); -- added 2005-05-05
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('anp', 'anp', 'Angika', 1); -- added 2005-11-08
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('gsw', 'gsw', 'German, Swiss', 1); -- added 2005-11-04 as "Swiss German; Alemannic; Alsatian"
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('krl', 'krl', 'Karelian', 1); -- added 2005-11-21
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('nqo', 'nqo', 'N''Ko', 1); -- 2006-05-21
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('rup', 'rup', 'Aromanian', 1); -- added 2005-09-20 as "Aromanian; Arumanian; Macedo-Romanian"
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('srn', 'srn', 'Sranan Tongo', 1); -- added 2005-12-12
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('syc', 'syc', 'Classical Syriac', 0); -- added 2007-04-02
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('zbl', 'zbl', 'Blissymbols', 0); -- added 2007-08-08 as "Blissymbols; Blissymbolics; Bliss"
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('zza', 'zza', 'Zaza', 1); -- added 2006-08-23 as "Zaza; Dimili; Dimli; Kirdki; Kirmanjki; Zazaki"
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('frr', 'frr', 'Frisian, Northern', 1); -- added 2005-11-08 as "Northern Frisian"
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('frs', 'frs', 'Frisian, Eastern', 1); -- added 2005-11-16 as "Eastern Frisian"
INSERT INTO language (isocode_3t, isocode_3b, name, frequency) VALUES ('zxx', 'zxx', 'No linguistic content', 0); -- added 2006-01-11

-- updated in ISO 639-2
-- name changes
UPDATE language SET name = 'Official Aramaic (700-300 BCE)'
	WHERE isocode_3t = 'arc'; -- currently "Aramaic", changed 2007-05-29 to "Official Aramaic (700-300 BCE); Imperial Aramaic (700-300 BCE)"
UPDATE language SET name = 'Mapudungun'
	WHERE isocode_3t = 'arn'; -- currently "Araucanian", changed 2006-10-26 to "Mapudungun; Mapuche"
UPDATE language SET name = 'Galibi Carib'
	WHERE isocode_3t = 'car'; -- currently "Carib", changed 2006-11-22
UPDATE language SET name = 'Frisian, Western'
	WHERE isocode_3t = 'fry'; -- currently "Frisian", changed 2005-11-16 to "Western Frisian"
UPDATE language SET name = 'Galician'
	WHERE isocode_3t = 'glg'; -- currently Gallegan, changed 2005-07-25
UPDATE language SET name = 'Khmer, Central'
	WHERE isocode_3t = 'khm'; -- currently "Khmer", changed 2006-10-27 to "Central Khmer"
UPDATE language SET name = 'Romansh'
	WHERE isocode_3t = 'roh'; -- currently Raeto-Romance, changed 2006-10-25
UPDATE language SET name = 'Occitan'
	WHERE isocode_3t = 'oci'; -- currently "Occitan (post 1500); Provençal", changed 2008-07-08 to "Occitan (post 1500)"
UPDATE language SET name = 'Wolaitta'
	WHERE isocode_3t = 'wal'; -- currently Walamo, changed 2008-07-08 to "Wolaitta; Wolaytta"
UPDATE language SET name = 'Banda languages'
	WHERE isocode_3t = 'bad'; -- currently Banda, changed 2006-10-31
UPDATE language SET name = 'Batak languages'
	WHERE isocode_3t = 'btk'; -- currently Batak (Indonesia), changed 2006-10-31
UPDATE language SET name = 'Land Dayak languages'
	WHERE isocode_3t = 'day'; -- currently Dayak, changed 2006-10-31
UPDATE language SET name = 'Ijo languages'
	WHERE isocode_3t = 'ijo'; -- currently Ijo, changed 2006-10-31
UPDATE language SET name = 'Karen languages'
	WHERE isocode_3t = 'kar'; -- currently Karen, changed 2006-10-31
UPDATE language SET name = 'Kru languages'
	WHERE isocode_3t = 'kro'; -- currently Kru, changed 2006-10-31
UPDATE language SET name = 'Uncoded languages'
	WHERE isocode_3t = 'mis'; -- currently Miscellaneous languages, changed 2007-06-13
UPDATE language SET name = 'Nahuatl languages'
	WHERE isocode_3t = 'nah'; -- currently Nahuatl, changed 2006-10-31
UPDATE language SET name = 'Songhai languages'
	WHERE isocode_3t = 'son'; -- currently Songhai, changed 2006-10-31
UPDATE language SET name = 'Zande languages'
	WHERE isocode_3t = 'znd'; -- currently Zande, changed 2006-10-31

-- code changes
UPDATE language SET isocode_3b = 'hrv' WHERE isocode_3t = 'hrv'; -- currently scr, changed 2008-06-28
UPDATE language SET isocode_3b = 'srp' WHERE isocode_3t = 'srp'; -- currently scc, changed 2008-06-28
UPDATE language SET frequency = 0 WHERE isocode_3t = 'mol'; -- deprecated 2008-11-03, use Romanian instead, setting frequency instead of deleting as I don't know what might already reference it in the database

-- ancient languages and language collections have 0 for frequency
UPDATE language SET frequency = 0 WHERE isocode_3t = 'arc'; -- Official Aramaic (700-300 BCE)
UPDATE language SET frequency = 0 WHERE isocode_3t = 'nwc'; -- Classical Newari; Old Newari; Classical Nepal Bhasa
UPDATE language SET frequency = 0 WHERE isocode_3t = 'bad'; -- Banda languages
UPDATE language SET frequency = 0 WHERE isocode_3t = 'btk'; -- Batak languages
UPDATE language SET frequency = 0 WHERE isocode_3t = 'day'; -- Land Dayak languages
UPDATE language SET frequency = 0 WHERE isocode_3t = 'ijo'; -- Ijo languages
UPDATE language SET frequency = 0 WHERE isocode_3t = 'kar'; -- Karen languages
UPDATE language SET frequency = 0 WHERE isocode_3t = 'kro'; -- Kru languages
UPDATE language SET frequency = 0 WHERE isocode_3t = 'nah'; -- Nahuatl languages
UPDATE language SET frequency = 0 WHERE isocode_3t = 'son'; -- Songhai languages
UPDATE language SET frequency = 0 WHERE isocode_3t = 'znd'; -- Zande languages
-- although there are releases in Old Norse
UPDATE language SET frequency = 1 WHERE isocode_3t = 'non'; -- Old Norse

-- remove alternate names, use the first name
UPDATE language SET name = 'Adyghe'
	WHERE isocode_3t = 'ady'; -- currently Adyghe; Adygei
UPDATE language SET name = 'Asturian'
	WHERE isocode_3t = 'ast'; -- currently "Asturian; Bable" in the database, "Asturian; Bable; Leonese; Asturleonese" in ISO 639
UPDATE language SET name = 'Blin'
	WHERE isocode_3t = 'byn'; -- currently Blin; Bilin
UPDATE language SET name = 'Catalan'
	WHERE isocode_3t = 'cat'; -- currently Catalan; Valencian
UPDATE language SET name = 'Church Slavic'
	WHERE isocode_3t = 'chu'; -- currently Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic
UPDATE language SET name = 'Crimean Tatar'
	WHERE isocode_3t = 'crh'; -- currently Crimean Tatar; Crimean Turkish
UPDATE language SET name = 'Filipino'
	WHERE isocode_3t = 'fil'; -- currently Filipino; Pilipino
UPDATE language SET name = 'Kikuyu'
	WHERE isocode_3t = 'kik'; -- currently Kikuyu; Gikuyu
UPDATE language SET name = 'Kuanyama'
	WHERE isocode_3t = 'kua'; -- currently Kuanyama; Kwanyama
UPDATE language SET name = 'Luxembourgish'
	WHERE isocode_3t = 'ltz'; -- currently Luxembourgish; Letzeburgesch
UPDATE language SET name = 'Mi''kmaq'
	WHERE isocode_3t = 'mic'; -- currently Mi'kmaq; Micmac
UPDATE language SET name = 'Navajo'
	WHERE isocode_3t = 'nav'; -- currently Navajo; Navaho
UPDATE language SET name = 'Ndebele, South'
	WHERE isocode_3t = 'nbl'; -- currently Ndebele, South; South Ndebele
UPDATE language SET name = 'Ndebele, North'
	WHERE isocode_3t = 'nde'; -- currently Ndebele, North; North Ndebele
UPDATE language SET name = 'Nepal Bhasa'
	WHERE isocode_3t = 'new'; -- currently "Newari; Nepal Bhasa", "Nepal Bhasa; Newari" in ISO 639
UPDATE language SET name = 'Dutch'
	WHERE isocode_3t = 'nld'; -- currently Dutch; Flemish
UPDATE language SET name = 'Norwegian Nynorsk'
	WHERE isocode_3t = 'nno'; -- currently Norwegian Nynorsk; Nynorsk, Norwegian
UPDATE language SET name = 'Norwegian Bokmål'
	WHERE isocode_3t = 'nob'; -- currently Norwegian Bokmål; Bokmål, Norwegian
UPDATE language SET name = 'Sotho, Northern'
	WHERE isocode_3t = 'nso'; -- currently Northern Sotho, Pedi; Sepedi
UPDATE language SET name = 'Classical Newari'
	WHERE isocode_3t = 'nwc'; -- currently Classical Newari; Old Newari; Classical Nepal Bhasa
UPDATE language SET name = 'Chichewa'
	WHERE isocode_3t = 'nya'; -- currently Chichewa; Chewa; Nyanja
UPDATE language SET name = 'Ossetian'
	WHERE isocode_3t = 'oss'; -- currently Ossetian; Ossetic
UPDATE language SET name = 'Panjabi'
	WHERE isocode_3t = 'pan'; -- currently Panjabi; Punjabi
UPDATE language SET name = 'Sinhala'
	WHERE isocode_3t = 'sin'; -- currently Sinhala; Sinhalese
UPDATE language SET name = 'Spanish'
	WHERE isocode_3t = 'spa'; -- currently Spanish; Castilian
UPDATE language SET name = 'Klingon'
	WHERE isocode_3t = 'tlh'; -- currently Klingon; tlhIngan-Hol
UPDATE language SET name = 'Uighur'
	WHERE isocode_3t = 'uig'; -- currently Uighur; Uyghur
UPDATE language SET name = 'Zhuang'
	WHERE isocode_3t = 'zha'; -- currently Zhuang; Chuang
-- for the following, prefer one of the alternate names
UPDATE language SET name = 'Scottish Gaelic'
	WHERE isocode_3t = 'gla'; -- currently Gaelic; Scottish Gaelic
UPDATE language SET name = 'Haitian Creole'
	WHERE isocode_3t = 'hat'; -- currently Haitian; Haitian Creole
UPDATE language SET name = 'Greenlandic'
	WHERE isocode_3t = 'kal'; -- currently Kalaallisut; Greenlandic
UPDATE language SET name = 'Limburgish'
	WHERE isocode_3t = 'lim'; -- currently Limburgan; Limburger; Limburgish
UPDATE language SET name = 'German, Low'
	WHERE isocode_3t = 'nds'; -- currently Low German; Low Saxon; German, Low; Saxon, Low

-- make some names easier to find
UPDATE language SET name = 'Sorbian, Lower'
	WHERE isocode_3t = 'dsb'; -- currently Lower Sorbian
UPDATE language SET name = 'Sorbian, Upper'
	WHERE isocode_3t = 'hsb'; -- currently Upper Sorbian
UPDATE language SET name = 'Sami, Southern'
	WHERE isocode_3t = 'sma'; -- currently Southern Sami
UPDATE language SET name = 'Sami, Northern'
	WHERE isocode_3t = 'sme'; -- currently Northern Sami
UPDATE language SET name = 'Sami, Lule'    
	WHERE isocode_3t = 'smj'; -- currently Lule Sami
UPDATE language SET name = 'Sami, Inari'   
	WHERE isocode_3t = 'smn'; -- currently Inari Sami
UPDATE language SET name = 'Sami, Skolt'   
	WHERE isocode_3t = 'sms'; -- currently Skolt Sami

-- tidy up
UPDATE language SET name = 'Greek'
	WHERE isocode_3t = 'ell'; -- "currently Greek, Modern (1453-)", unneeded info
UPDATE language SET name = 'French, Middle (ca.1400-1600)'
	WHERE isocode_3t = 'frm'; -- currently "French, Middle (ca.1400-1800)", bad source data?
UPDATE language SET name = 'Gwich''in'
	WHERE isocode_3t = 'gwi'; -- currently "Gwich´in", bad source data?
UPDATE language SET name = 'Interlingua'
	WHERE isocode_3t = 'ina'; -- currently "Interlingua (International Auxiliary Language Association)", unneeded info
UPDATE language SET name = 'Luo'
	WHERE isocode_3t = 'luo'; -- currently "Luo (Kenya and Tanzania)", unneeded info
UPDATE language SET name = 'Turkish, Ottoman'
	WHERE isocode_3t = 'ota'; -- currently "Turkish, Ottoman (1500-1928)", unneeded info

-- get rid of the French names
ALTER TABLE script DROP COLUMN french_name;

-- Japanese and Korean
UPDATE script SET name = 'Japanese', isonumber = 413, isocode = 'Jpan' WHERE isocode = 'Hrkt'; -- Jpan added 2006-06-21, matches our use of Hrkt
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Hrkt', 412, 'Hiragana + Katakana', 3); -- restore Hrkt
UPDATE script SET name = 'Korean', isonumber = 287, isocode = 'Kore' WHERE isocode = 'Hang'; -- Kore added 2007-06-13
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Hang', 286, 'Hangul', 3); -- restore Hang

-- use shorter names like http://www.unicode.org/charts/
UPDATE script SET name = 'Canadian Syllabics' WHERE isocode = 'Cans'; -- currently Unified Canadian Aboriginal Syllabics
UPDATE script SET name = 'Devanagari' WHERE isocode = 'Deva'; -- currently Devanagari (Nagari)
UPDATE script SET name = 'Deseret' WHERE isocode = 'Dsrt'; -- currently Deseret (Mormon)
UPDATE script SET name = 'Ethiopic' WHERE isocode = 'Ethi'; -- currently Ethiopic (Ge'ez)
UPDATE script SET name = 'Georgian' WHERE isocode = 'Geor'; -- currently Georgian (Mkhedruli)
--UPDATE script SET name = 'Han' WHERE isocode = 'Hani'; -- currently Han (Hanzi, Kanji, Hanja)
UPDATE script SET name = 'Hanunoo' WHERE isocode = 'Hano'; -- currently Hanunoo (Hanunóo)
UPDATE script SET name = 'Indus' WHERE isocode = 'Inds'; -- currently Indus (Harappan)
UPDATE script SET name = 'Old Italic' WHERE isocode = 'Ital'; -- currently Old Italic (Etruscan, Oscan, etc.)
UPDATE script SET name = 'Lepcha' WHERE isocode = 'Lepc'; -- currently Lepcha (Róng)
UPDATE script SET name = 'Myanmar' WHERE isocode = 'Mymr'; -- currently Myanmar (Burmese)
UPDATE script SET name = 'Shavian' WHERE isocode = 'Shaw'; -- currently Shavian (Shaw)
UPDATE script SET name = 'Tifinagh' WHERE isocode = 'Tfng'; -- currently Tifinagh (Berber)

-- already in ISO 15924, added to Unicode
UPDATE script SET frequency = 2 WHERE isocode = 'Bali'; -- Balinese
UPDATE script SET frequency = 2 WHERE isocode = 'Bugi'; -- Buginese
UPDATE script SET frequency = 2 WHERE isocode = 'Cham'; -- Cham
UPDATE script SET frequency = 2 WHERE isocode = 'Copt'; -- Copt
UPDATE script SET frequency = 2 WHERE isocode = 'Dsrt'; -- Deseret
UPDATE script SET frequency = 2 WHERE isocode = 'Glag'; -- Glagolitic
UPDATE script SET frequency = 2 WHERE isocode = 'Kali'; -- Kayah Li
UPDATE script SET frequency = 2 WHERE isocode = 'Khar'; -- Khaoshthi
UPDATE script SET frequency = 2 WHERE isocode = 'Lepc'; -- Lepcha
UPDATE script SET frequency = 2 WHERE isocode = 'Phag'; -- Phags-pa
UPDATE script SET frequency = 2 WHERE isocode = 'Phnx'; -- Phoenician
UPDATE script SET frequency = 2 WHERE isocode = 'Shaw'; -- Shavian 
UPDATE script SET frequency = 2 WHERE isocode = 'Sylo'; -- Syloti Nagri
UPDATE script SET frequency = 2 WHERE isocode = 'Talu'; -- New Tai Lue
UPDATE script SET frequency = 3 WHERE isocode = 'Tfng'; -- Tifinagh
UPDATE script SET frequency = 2 WHERE isocode = 'Vaii'; -- Vai
UPDATE script SET frequency = 2 WHERE isocode = 'Xpeo'; -- Old Persian
UPDATE script SET frequency = 2 WHERE isocode = 'Xsux'; -- Cuneiform

-- added to ISO 15924, added to Unicode
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Geok', 241, 'Khutsuri', 2); -- added 2006-12-11
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Nkoo', 165, 'N''ko', 2); -- added 2006-10-10
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Olck', 261, 'Ol Chiki', 2); -- added 2007-07-02
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Rjng', 363, 'Rejang', 2); -- added 2007-07-02
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Saur', 344, 'Saurashtra', 2); -- added 2007-07-02
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Sund', 362, 'Sundanese', 2); -- added 2007-07-02
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Cari', 201, 'Carian', 2); -- added 2007-07-02
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Lyci', 202, 'Lycian', 2); -- added 2007-07-02
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Lydi', 116, 'Lydian', 2); -- added 2007-07-02
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Zmth', 995, 'Mathematical notation', 2); -- added 2007-11-26
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Zsym', 996, 'Symbols', 3); -- added 2007-11-26

-- added to ISO 15924, not yet in Unicode
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Armi', 124, 'Imperial Aramaic', 1); -- added 2007-11-26
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Avst', 134, 'Avestan', 1); -- added 2007-07-15
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Cakm', 349, 'Chakma', 1); -- added 2007-11-26
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Kthi', 317, 'Kaithi', 1); -- added 2007-11-26
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Lana', 351, 'Lanna', 1); -- added 2007-11-26
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Mani', 139, 'Manichaean', 1); -- added 2007-07-15
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Moon', 218, 'Moon', 1); -- added 2006-12-11
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Mtei', 337, 'Meitei Mayek', 1); -- added 2006-12-11
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Phli', 131, 'Inscriptional Pahlavi', 1); -- added 2007-11-26
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Phlp', 132, 'Psalter Pahlavi', 1); -- added 2007-11-26
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Phlv', 133, 'Book Pahlavi', 1); -- added 2007-07-15
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Prti', 130, 'Inscriptional Parthian', 1); -- added 2007-11-26
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Samr', 123, 'Samaritan', 1); -- added 2007-107-15
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Sgnw', 095, 'SignWriting', 1); -- added 2006-10-10
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Tavt', 359, 'Tai Viet', 1); -- added 2007-11-26

-- special codes
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Zxxx', 997, 'Code for unwritten documents', 1); -- added 2007-06-13
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Zyyy', 998, 'Code for undetermined script', 1); -- added 2004-05-29
INSERT INTO script (isocode, isonumber, name, frequency) VALUES ('Zzzz', 999, 'Code for uncoded script', 1); -- added 2006-10-10

COMMIT;