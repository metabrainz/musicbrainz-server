-- Abstract: create the "release" and "countries" tables and associated objects

\set ON_ERROR_STOP 1

BEGIN;

CREATE TABLE country
(
        id              SERIAL PRIMARY KEY,
        isocode         VARCHAR(2) NOT NULL,
        name            VARCHAR(100) NOT NULL
);

COPY country (id, isocode, name) FROM stdin;
1	AF	Afghanistan
2	AL	Albania
3	DZ	Algeria
4	AS	American Samoa
5	AD	Andorra
6	AO	Angola
7	AI	Anguilla
8	AQ	Antarctica
9	AG	Antigua and Barbuda
10	AR	Argentina
11	AM	Armenia
12	AW	Aruba
13	AU	Australia
14	AT	Austria
15	AZ	Azerbaijan
16	BS	Bahamas
17	BH	Bahrain
18	BD	Bangladesh
19	BB	Barbados
20	BY	Belarus
21	BE	Belgium
22	BZ	Belize
23	BJ	Benin
24	BM	Bermuda
25	BT	Bhutan
26	BO	Bolivia
27	BA	Bosnia and Herzegowina
28	BW	Botswana
29	BV	Bouvet Island
30	BR	Brazil
31	IO	British Indian Ocean Territory
32	BN	Brunei Darussalam
33	BG	Bulgaria
34	BF	Burkina Faso
35	BI	Burundi
36	KH	Cambodia
37	CM	Cameroon
38	CA	Canada
39	CV	Cape Verde
40	KY	Cayman Islands
41	CF	Central African Republic
42	TD	Chad
43	CL	Chile
44	CN	China
45	CX	Christmas Island
46	CC	Cocos (Keeling) Islands
47	CO	Colombia
48	KM	Comoros
49	CG	Congo
50	CK	Cook Islands
51	CR	Costa Rica
52	CI	Cote d'Ivoire
53	HR	Croatia (Local Name: Hrvatska)
54	CU	Cuba
55	CY	Cyprus
56	CZ	Czech Republic
57	DK	Denmark
58	DJ	Djibouti
59	DM	Dominica
60	DO	Dominican Republic
61	TP	East Timor
62	EC	Ecuador
63	EG	Egypt
64	SV	El Salvador
65	GQ	Equatorial Guinea
66	ER	Eritrea
67	EE	Estonia
68	ET	Ethiopia
69	FK	Falkland Islands (Malvinas)
70	FO	Faroe Islands
71	FJ	Fiji
72	FI	Finland
73	FR	France
74	FX	France, Metropolitan
75	GF	French Guiana
76	PF	French Polynesia
77	TF	French Southern Territories
78	GA	Gabon
79	GM	Gambia
80	GE	Georgia
81	DE	Germany
82	GH	Ghana
83	GI	Gibraltar
84	GR	Greece
85	GL	Greenland
86	GD	Grenada
87	GP	Guadeloupe
88	GU	Guam
89	GT	Guatemala
90	GN	Guinea
91	GW	Guinea-Bissau
92	GY	Guyana
93	HT	Haiti
94	HM	Heard and Mc Donald Islands
95	HN	Honduras
96	HK	Hong Kong
97	HU	Hungary
98	IS	Iceland
99	IN	India
100	ID	Indonesia
101	IR	Iran (Islamic Republic of)
102	IQ	Iraq
103	IE	Ireland
104	IL	Israel
105	IT	Italy
106	JM	Jamaica
107	JP	Japan
108	JO	Jordan
109	KZ	Kazakhstan
110	KE	Kenya
111	KI	Kiribati
112	KP	Korea, Democratic People's Republic of
113	KR	Korea, Republic of
114	KW	Kuwait
115	KG	Kyrgyzstan
116	LA	Lao People's Democratic Republic
117	LV	Latvia
118	LB	Lebanon
119	LS	Lesotho
120	LR	Liberia
121	LY	Libyan Arab Jamahiriya
122	LI	Liechtenstein
123	LT	Lithuania
124	LU	Luxembourg
125	MO	Macau
126	MK	Macedonia, The Former Yugoslav Republic of
127	MG	Madagascar
128	MW	Malawi
129	MY	Malaysia
130	MV	Maldives
131	ML	Mali
132	MT	Malta
133	MH	Marshall Islands
134	MQ	Martinique
135	MR	Mauritania
136	MU	Mauritius
137	YT	Mayotte
138	MX	Mexico
139	FM	Micronesia, Federated States of
140	MD	Moldova, Republic of
141	MC	Monaco
142	MN	Mongolia
143	MS	Montserrat
144	MA	Morocco
145	MZ	Mozambique
146	MM	Myanmar
147	NA	Namibia
148	NR	Nauru
149	NP	Nepal
150	NL	Netherlands
151	AN	Netherlands Antilles
152	NC	New Caledonia
153	NZ	New Zealand
154	NI	Nicaragua
155	NE	Niger
156	NG	Nigeria
157	NU	Niue
158	NF	Norfolk Island
159	MP	Northern Mariana Islands
160	NO	Norway
161	OM	Oman
162	PK	Pakistan
163	PW	Palau
164	PA	Panama
165	PG	Papua New Guinea
166	PY	Paraguay
167	PE	Peru
168	PH	Philippines
169	PN	Pitcairn
170	PL	Poland
171	PT	Portugal
172	PR	Puerto Rico
173	QA	Qatar
174	RE	Reunion
175	RO	Romania
176	RU	Russian Federation
177	RW	Rwanda
178	KN	Saint Kitts and Nevis
179	LC	Saint Lucia
180	VC	Saint Vincent and The Grenadines
181	WS	Samoa
182	SM	San Marino
183	ST	Sao Tome and Principe
184	SA	Saudi Arabia
185	SN	Senegal
186	SC	Seychelles
187	SL	Sierra Leone
188	SG	Singapore
189	SK	Slovakia (Slovak Republic)
190	SI	Slovenia
191	SB	Solomon Islands
192	SO	Somalia
193	ZA	South Africa
194	ES	Spain
195	LK	Sri Lanka
196	SH	St. Helena
197	PM	St. Pierre and Miquelon
198	SD	Sudan
199	SR	Suriname
200	SJ	Svalbard and Jan Mayen Islands
201	SZ	Swaziland
202	SE	Sweden
203	CH	Switzerland
204	SY	Syrian Arab Republic
205	TW	Taiwan, Province of China
206	TJ	Tajikistan
207	TZ	Tanzania, United Republic of
208	TH	Thailand
209	TG	Togo
210	TK	Tokelau
211	TO	Tonga
212	TT	Trinidad and Tobago
213	TN	Tunisia
214	TR	Turkey
215	TM	Turkmenistan
216	TC	Turks and Caicos Islands
217	TV	Tuvalu
218	UG	Uganda
219	UA	Ukraine
220	AE	United Arab Emirates
221	GB	United Kingdom
222	US	United States
223	UM	United States Minor Outlying Islands
224	UY	Uruguay
225	UZ	Uzbekistan
226	VU	Vanuatu
227	VA	Vatican City State (Holy See)
228	VE	Venezuela
229	VN	Viet Nam
230	VG	Virgin Islands (British)
231	VI	Virgin Islands (U.S.)
232	WF	Wallis and Futuna Islands
233	EH	Western Sahara
234	YE	Yemen
235	YU	Yugoslavia
236	ZR	Zaire
237	ZM	Zambia
238	ZW	Zimbabwe
\.
-- ' -- Vim syntax catch-up
SELECT SETVAL('country_id_seq', ( SELECT MAX(id)+1 FROM country ));

CREATE TABLE release
(
        id              SERIAL PRIMARY KEY,
        album           INTEGER NOT NULL, -- references album
        country         INTEGER NOT NULL, -- references country
        releasedate     CHAR(10) NOT NULL,
        modpending      INTEGER DEFAULT 0
);

CREATE UNIQUE INDEX country_isocode ON country (isocode);
CREATE UNIQUE INDEX country_name ON country (name);

CREATE INDEX release_album ON release (album);

ALTER TABLE release
    ADD CONSTRAINT release_fk_album
    FOREIGN KEY (album)
    REFERENCES album(id);

ALTER TABLE release
    ADD CONSTRAINT release_fk_country
    FOREIGN KEY (country)
    REFERENCES country(id);

--'-----------------------------------------------------------------
-- Populate the albummeta table, one-to-one join with album.
-- All columns are non-null integers, except firstreleasedate
-- which is CHAR(10) WITH NULL
--'-----------------------------------------------------------------

create or replace function fill_album_meta () returns integer as '
declare

   table_count integer;

begin

   table_count := (SELECT count(*) FROM pg_class WHERE relname = ''albummeta'');
   if table_count > 0 then
       raise notice ''Dropping existing albummeta table'';
       drop table albummeta;
   end if;

   raise notice ''Counting tracks'';
   create temporary table albummeta_tracks as select album.id, count(albumjoin.album) 
                from album left join albumjoin on album.id = albumjoin.album group by album.id;

   raise notice ''Counting discids'';
   create temporary table albummeta_discids as select album.id, count(discid.album) 
                from album left join discid on album.id = discid.album group by album.id;

   raise notice ''Counting trmids'';
   create temporary table albummeta_trmids as select album.id, count(trmjoin.track) 
                from album, albumjoin left join trmjoin on albumjoin.track = trmjoin.track 
                where album.id = albumjoin.album group by album.id;

    raise notice ''Finding first release dates'';
    CREATE TEMPORARY TABLE albummeta_firstreleasedate AS
        SELECT  album AS id, MIN(releasedate)::CHAR(10) AS firstreleasedate
        FROM    release
        GROUP BY album;

   raise notice ''Creating albummeta table'';
   create table albummeta as
   select a.id,
            COALESCE(t.count, 0) AS tracks,
            COALESCE(d.count, 0) AS discids,
            COALESCE(m.count, 0) AS trmids,
            r.firstreleasedate
    FROM    album a
            LEFT JOIN albummeta_tracks t ON t.id = a.id
            LEFT JOIN albummeta_discids d ON d.id = a.id
            LEFT JOIN albummeta_trmids m ON m.id = a.id
            LEFT JOIN albummeta_firstreleasedate r ON r.id = a.id
            ;

    ALTER TABLE albummeta ALTER COLUMN id SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN tracks SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN discids SET NOT NULL;
    ALTER TABLE albummeta ALTER COLUMN trmids SET NOT NULL;
    -- firstreleasedate stays "WITH NULL"

   create unique index albummeta_id on albummeta(id);

   drop table albummeta_tracks;
   drop table albummeta_discids;
   drop table albummeta_trmids;
   drop table albummeta_firstreleasedate;

   return 1;

end;
' language 'plpgsql';

-- At this point we could do: SELECT fill_album_meta()
-- but this is quicker, and has the same effect:
ALTER TABLE albummeta ADD COLUMN firstreleasedate CHAR(10);

--'-----------------------------------------------------------------
-- Ensure release.releasedate is always valid
--'-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION before_insertupdate_release () RETURNS TRIGGER AS '
DECLARE
    y CHAR(4);
    m CHAR(2);
    d CHAR(2);
    teststr VARCHAR(10);
    testdate DATE;
BEGIN
    -- Check that the releasedate looks like this: yyyy-mm-dd
    IF (NOT(NEW.releasedate ~ ''^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$''))
    THEN
        RAISE EXCEPTION ''Invalid release date specification'';
    END IF;

    y := SUBSTR(NEW.releasedate, 1, 4);
    m := SUBSTR(NEW.releasedate, 6, 2);
    d := SUBSTR(NEW.releasedate, 9, 2);

    -- Disallow yyyy-00-dd
    IF (m = ''00'' AND d != ''00'')
    THEN
        RAISE EXCEPTION ''Invalid release date specification'';
    END IF;

    -- Check that the y/m/d combination is valid (e.g. disallow 2003-02-31)
    IF (m = ''00'') THEN m:= ''01''; END IF;
    IF (d = ''00'') THEN d:= ''01''; END IF;
    teststr := ( y || ''-'' || m || ''-'' || d );
    -- TO_DATE allows 2003-08-32 etc (it becomes 2003-09-01)
    -- So we will use the ::date cast, which catches this error
    testdate := teststr;

    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

--'-----------------------------------------------------------------
-- Maintain albummeta.firstreleasedate
--'-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION set_album_firstreleasedate(INTEGER)
RETURNS VOID AS '
BEGIN
    UPDATE albummeta SET firstreleasedate = (
        SELECT MIN(releasedate) FROM release WHERE album = $1
    ) WHERE id = $1;
    RETURN;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_ins_release () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_firstreleasedate(NEW.album);
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_upd_release () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_firstreleasedate(NEW.album);
    IF (OLD.album != NEW.album)
    THEN
        EXECUTE set_album_firstreleasedate(OLD.album);
    END IF;
    RETURN NEW;
END;
' LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION a_del_release () RETURNS TRIGGER AS '
BEGIN
    EXECUTE set_album_firstreleasedate(OLD.album);
    RETURN OLD;
END;
' LANGUAGE 'plpgsql';

CREATE TRIGGER b_iu_release BEFORE INSERT OR UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE before_insertupdate_release();
CREATE TRIGGER a_ins_release AFTER INSERT ON release
    FOR EACH ROW EXECUTE PROCEDURE a_ins_release();
CREATE TRIGGER a_upd_release AFTER UPDATE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_upd_release();
CREATE TRIGGER a_del_release AFTER DELETE ON release
    FOR EACH ROW EXECUTE PROCEDURE a_del_release();

COMMIT;

-- vi: set ts=4 sw=4 et :
