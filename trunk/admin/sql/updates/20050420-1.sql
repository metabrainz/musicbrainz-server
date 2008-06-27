-- Abstract: create the "language" table and add album.language
-- Abstract: create the "script" table and add album.script
-- Abstract: create the "script_language" table
-- Abstract: populate the "language" and "script" related tables
-- Abstract: add a language attribute to the "moderation_*" tables

\set ON_ERROR_STOP 1

BEGIN;

-- tables

CREATE TABLE language
(
     id                 SERIAL,
     isocode_3t         CHAR(3) NOT NULL, -- ISO 639-2 (T)
     isocode_3b         CHAR(3) NOT NULL, -- ISO 639-2 (B)
     isocode_2          CHAR(2), -- ISO 639
     name               VARCHAR(100) NOT NULL,
     french_name        VARCHAR(100) NOT NULL,
     frequency          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE script
(
     id                 SERIAL,
     isocode            CHAR(4) NOT NULL, -- ISO 15924
     isonumber          CHAR(3) NOT NULL, -- ISO 15924
     name               VARCHAR(100) NOT NULL,
     french_name        VARCHAR(100) NOT NULL,
     frequency          INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE script_language
(
     id                 SERIAL,
     script		        INTEGER,
     language           INTEGER NOT NULL,
     frequency          INTEGER NOT NULL DEFAULT 0
);

CREATE TEMPORARY TABLE tmp_sl
(
     language           CHAR(3) NOT NULL,
     script             CHAR(4) NOT NULL
);

-- data
-- see http://www.loc.gov/standards/iso639-2/langcodes.html
COPY language (frequency, isocode_3b, isocode_3t, isocode_2, name, french_name) FROM stdin;
1	aar	aar	aa	Afar	afar
1	abk	abk	ab	Abkhazian	abkhaze
1	ace	ace	 	Achinese	aceh
1	ach	ach	 	Acoli	acoli
1	ada	ada	 	Adangme	adangme
1	ady	ady	 	Adyghe; Adygei	adyghé
0	afa	afa	 	Afro-Asiatic (Other)	afro-asiatiques, autres langues
1	afh	afh	 	Afrihili	afrihili
1	afr	afr	af	Afrikaans	afrikaans
1	aka	aka	ak	Akan	akan
0	akk	akk	 	Akkadian	akkadien
1	alb	sqi	sq	Albanian	albanais
1	ale	ale	 	Aleut	aléoute
0	alg	alg	 	Algonquian languages	algonquines, langues
1	amh	amh	am	Amharic	amharique
0	ang	ang	 	English, Old (ca.450-1100)	anglo-saxon (ca.450-1100)
0	apa	apa	 	Apache languages	apache
2	ara	ara	ar	Arabic	arabe
1	arc	arc	 	Aramaic	araméen
1	arg	arg	an	Aragonese	aragonais
1	arm	hye	hy	Armenian	arménien
1	arn	arn	 	Araucanian	araucan
1	arp	arp	 	Arapaho	arapaho
0	art	art	 	Artificial (Other)	artificielles, autres langues
1	arw	arw	 	Arawak	arawak
1	asm	asm	as	Assamese	assamais
1	ast	ast	 	Asturian; Bable	asturien; bable
0	ath	ath	 	Athapascan languages	athapascanes, langues
0	aus	aus	 	Australian languages	australiennes, langues
1	ava	ava	av	Avaric	avar
1	ave	ave	ae	Avestan	avestique
1	awa	awa	 	Awadhi	awadhi
1	aym	aym	ay	Aymara	aymara
1	aze	aze	az	Azerbaijani	azéri
1	bad	bad	 	Banda	banda
0	bai	bai	 	Bamileke languages	bamilékés, langues
1	bak	bak	ba	Bashkir	bachkir
1	bal	bal	 	Baluchi	baloutchi
1	bam	bam	bm	Bambara	bambara
1	ban	ban	 	Balinese	balinais
1	baq	eus	eu	Basque	basque
1	bas	bas	 	Basa	basa
0	bat	bat	 	Baltic (Other)	baltiques, autres langues
1	bej	bej	 	Beja	bedja
1	bel	bel	be	Belarusian	biélorusse
1	bem	bem	 	Bemba	bemba
1	ben	ben	bn	Bengali	bengali
0	ber	ber	 	Berber (Other)	berbères, autres langues
1	bho	bho	 	Bhojpuri	bhojpuri
1	bih	bih	bh	Bihari	bihari
1	bik	bik	 	Bikol	bikol
1	bin	bin	 	Bini	bini
1	bis	bis	bi	Bislama	bichlamar
1	bla	bla	 	Siksika	blackfoot
0	bnt	bnt	 	Bantu (Other)	bantoues, autres langues
1	bos	bos	bs	Bosnian	bosniaque
1	bra	bra	 	Braj	braj
1	bre	bre	br	Breton	breton
1	btk	btk	 	Batak (Indonesia)	batak (Indonésie)
1	bua	bua	 	Buriat	bouriate
1	bug	bug	 	Buginese	bugi
1	bul	bul	bg	Bulgarian	bulgare
1	bur	mya	my	Burmese	birman
1	byn	byn	 	Blin; Bilin	blin; bilen
1	cad	cad	 	Caddo	caddo
0	cai	cai	 	Central American Indian (Other)	indiennes d'Amérique centrale, autres langues
1	car	car	 	Carib	caribe
1	cat	cat	ca	Catalan; Valencian	catalan; valencien
0	cau	cau	 	Caucasian (Other)	caucasiennes, autres langues
1	ceb	ceb	 	Cebuano	cebuano
0	cel	cel	 	Celtic (Other)	celtiques, autres langues
1	cha	cha	ch	Chamorro	chamorro
1	chb	chb	 	Chibcha	chibcha
1	che	che	ce	Chechen	tchétchène
1	chg	chg	 	Chagatai	djaghataï
2	chi	zho	zh	Chinese	chinois
1	chk	chk	 	Chuukese	chuuk
1	chm	chm	 	Mari	mari
1	chn	chn	 	Chinook jargon	chinook, jargon
1	cho	cho	 	Choctaw	choctaw
1	chp	chp	 	Chipewyan	chipewyan
1	chr	chr	 	Cherokee	cherokee
1	chu	chu	cu	Church Slavic; Old Slavonic; Church Slavonic; Old Bulgarian; Old Church Slavonic	slavon d'église; vieux slave; slavon liturgique; vieux bulgare
1	chv	chv	cv	Chuvash	tchouvache
1	chy	chy	 	Cheyenne	cheyenne
0	cmc	cmc	 	Chamic languages	chames, langues
1	cop	cop	 	Coptic	copte
1	cor	cor	kw	Cornish	cornique
1	cos	cos	co	Corsican	corse
0	cpe	cpe		Creoles and pidgins, English based (Other)	créoles et pidgins anglais, autres
0	cpf	cpf		Creoles and pidgins, French-based (Other)	créoles et pidgins français, autres
0	cpp	cpp	 	Creoles and pidgins, Portuguese-based (Other)	créoles et pidgins portugais, autres
1	cre	cre	cr	Cree	cree
1	crh	crh	 	Crimean Tatar; Crimean Turkish	tatar de Crimé
0	crp	crp	 	Creoles and pidgins (Other)	créoles et pidgins divers
1	csb	csb	 	Kashubian	kachoube
0	cus	cus	 	Cushitic (Other)	couchitiques, autres langues
1	cze	ces	cs	Czech	tchèque
1	dak	dak	 	Dakota	dakota
1	dan	dan	da	Danish	danois
1	dar	dar	 	Dargwa	dargwa
1	day	day	 	Dayak	dayak
1	del	del	 	Delaware	delaware
1	den	den	 	Slave (Athapascan)	esclave (athapascan)
1	dgr	dgr	 	Dogrib	dogrib
1	din	din	 	Dinka	dinka
1	div	div	dv	Divehi	maldivien
1	doi	doi	 	Dogri	dogri
0	dra	dra	 	Dravidian (Other)	dravidiennes, autres langues
1	dsb	dsb	 	Lower Sorbian	bas-sorabe
1	dua	dua	 	Duala	douala
0	dum	dum	 	Dutch, Middle (ca.1050-1350)	néerlandais moyen (ca. 1050-1350)
1	dut	nld	nl	Dutch; Flemish	néerlandais; flamand
1	dyu	dyu	 	Dyula	dioula
1	dzo	dzo	dz	Dzongkha	dzongkha
1	efi	efi	 	Efik	efik
0	egy	egy	 	Egyptian (Ancient)	égyptien
1	eka	eka	 	Ekajuk	ekajuk
1	elx	elx	 	Elamite	élamite
2	eng	eng	en	English	anglais
0	enm	enm	 	English, Middle (1100-1500)	anglais moyen (1100-1500)
1	epo	epo	eo	Esperanto	espéranto
1	est	est	et	Estonian	estonien
1	ewe	ewe	ee	Ewe	éwé
1	ewo	ewo	 	Ewondo	éwondo
1	fan	fan	 	Fang	fang
1	fao	fao	fo	Faroese	féroïen
1	fat	fat	 	Fanti	fanti
1	fij	fij	fj	Fijian	fidjien
1	fil	fil	 	Filipino; Pilipino	filipino; pilipino
1	fin	fin	fi	Finnish	finnois
0	fiu	fiu	 	Finno-Ugrian (Other)	finno-ougriennes, autres langues
1	fon	fon	 	Fon	fon
2	fre	fra	fr	French	français
0	frm	frm	 	French, Middle (ca.1400-1800)	français moyen (1400-1800)
0	fro	fro	 	French, Old (842-ca.1400)	français ancien (842-ca.1400)
1	fry	fry	fy	Frisian	frison
1	ful	ful	ff	Fulah	peul
1	fur	fur		Friulian	frioulan
1	gaa	gaa	 	Ga	ga
1	gay	gay	 	Gayo	gayo
1	gba	gba	 	Gbaya	gbaya
0	gem	gem	 	Germanic (Other)	germaniques, autres langues
1	geo	kat	ka	Georgian	géorgien
1	ger	deu	de	German	allemand
1	gez	gez	 	Geez	guèze
1	gil	gil	 	Gilbertese	kiribati
1	gla	gla	gd	Gaelic; Scottish Gaelic	gaélique; gaélique écossais
1	gle	gle	ga	Irish	irlandais
1	glg	glg	gl	Gallegan	galicien
1	glv	glv	gv	Manx	manx; mannois
0	gmh	gmh	 	German, Middle High (ca.1050-1500)	allemand, moyen haut (ca. 1050-1500)
0	goh	goh	 	German, Old High (ca.750-1050)	allemand, vieux haut (ca. 750-1050)
1	gon	gon	 	Gondi	gond
1	gor	gor	 	Gorontalo	gorontalo
1	got	got	 	Gothic	gothique
1	grb	grb	 	Grebo	grebo
0	grc	grc	 	Greek, Ancient (to 1453)	grec ancien (jusqu'à 1453)
1	gre	ell	el	Greek, Modern (1453-)	grec moderne (après 1453)
1	grn	grn	gn	Guarani	guarani
1	guj	guj	gu	Gujarati	goudjrati
1	gwi	gwi	 	Gwich´in	gwich´in
1	hai	hai	 	Haida	haida
1	hat	hat	ht	Haitian; Haitian Creole	haïtien; créole haïtien
1	hau	hau	ha	Hausa	haoussa
1	haw	haw	 	Hawaiian	hawaïen
1	heb	heb	he	Hebrew	hébreu
1	her	her	hz	Herero	herero
1	hil	hil	 	Hiligaynon	hiligaynon
1	him	him	 	Himachali	himachali
1	hin	hin	hi	Hindi	hindi
0	hit	hit	 	Hittite	hittite
1	hmn	hmn	 	Hmong	hmong
1	hmo	hmo	ho	Hiri Motu	hiri motu
1	hsb	hsb	 	Upper Sorbian	haut-sorabe
1	hun	hun	hu	Hungarian	hongrois
1	hup	hup	 	Hupa	hupa
1	iba	iba	 	Iban	iban
1	ibo	ibo	ig	Igbo	igbo
1	ice	isl	is	Icelandic	islandais
1	ido	ido	io	Ido	ido
1	iii	iii	ii	Sichuan Yi	yi de Sichuan
1	ijo	ijo	 	Ijo	ijo
1	iku	iku	iu	Inuktitut	inuktitut
1	ile	ile	ie	Interlingue	interlingue
1	ilo	ilo	 	Iloko	ilocano
1	ina	ina	ia	Interlingua (International Auxiliary Language Association)	interlingua (langue auxiliaire internationale)
0	inc	inc	 	Indic (Other)	indo-aryennes, autres langues
1	ind	ind	id	Indonesian	indonésien
0	ine	ine	 	Indo-European (Other)	indo-européennes, autres langues
1	inh	inh	 	Ingush	ingouche
1	ipk	ipk	ik	Inupiaq	inupiaq
0	ira	ira	 	Iranian (Other)	iraniennes, autres langues
0	iro	iro	 	Iroquoian languages	iroquoises, langues (famille)
1	ita	ita	it	Italian	italien
1	jav	jav	jv	Javanese	javanais
1	jbo	jbo	 	Lojban	lojban
1	jpn	jpn	ja	Japanese	japonais
1	jpr	jpr	 	Judeo-Persian	judéo-persan
1	jrb	jrb	 	Judeo-Arabic	judéo-arabe
1	kaa	kaa	 	Kara-Kalpak	karakalpak
1	kab	kab	 	Kabyle	kabyle
1	kac	kac	 	Kachin	kachin
1	kal	kal	kl	Kalaallisut; Greenlandic	groenlandais
1	kam	kam	 	Kamba	kamba
1	kan	kan	kn	Kannada	kannada
1	kar	kar	 	Karen	karen
1	kas	kas	ks	Kashmiri	kashmiri
1	kau	kau	kr	Kanuri	kanouri
0	kaw	kaw	 	Kawi	kawi
1	kaz	kaz	kk	Kazakh	kazakh
1	kbd	kbd	 	Kabardian	kabardien
1	kha	kha	 	Khasi	khasi
0	khi	khi	 	Khoisan (Other)	khoisan, autres langues
1	khm	khm	km	Khmer	khmer
0	kho	kho	 	Khotanese	khotanais
1	kik	kik	ki	Kikuyu; Gikuyu	kikuyu
1	kin	kin	rw	Kinyarwanda	rwanda
1	kir	kir	ky	Kirghiz	kirghize
1	kmb	kmb	 	Kimbundu	kimbundu
1	kok	kok	 	Konkani	konkani
1	kom	kom	kv	Komi	kom
1	kon	kon	kg	Kongo	kongo
1	kor	kor	ko	Korean	coréen
1	kos	kos	 	Kosraean	kosrae
1	kpe	kpe	 	Kpelle	kpellé
1	krc	krc	 	Karachay-Balkar	karatchaï balkar
1	kro	kro	 	Kru	krou
1	kru	kru	 	Kurukh	kurukh
1	kua	kua	kj	Kuanyama; Kwanyama	kuanyama; kwanyama
1	kum	kum	 	Kumyk	koumyk
1	kur	kur	ku	Kurdish	kurde
1	kut	kut	 	Kutenai	kutenai
1	lad	lad	 	Ladino	judéo-espagnol
1	lah	lah	 	Lahnda	lahnda
1	lam	lam	 	Lamba	lamba
1	lao	lao	lo	Lao	lao
1	lat	lat	la	Latin	latin
1	lav	lav	lv	Latvian	letton
1	lez	lez	 	Lezghian	lezghien
1	lim	lim	li	Limburgan; Limburger; Limburgish	limbourgeois
1	lin	lin	ln	Lingala	lingala
1	lit	lit	lt	Lithuanian	lituanien
1	lol	lol	 	Mongo	mongo
1	loz	loz	 	Lozi	lozi
1	ltz	ltz	lb	Luxembourgish; Letzeburgesch	luxembourgeois
1	lua	lua	 	Luba-Lulua	luba-lulua
1	lub	lub	lu	Luba-Katanga	luba-katanga
1	lug	lug	lg	Ganda	ganda
1	lui	lui	 	Luiseno	luiseno
1	lun	lun	 	Lunda	lunda
1	luo	luo	 	Luo (Kenya and Tanzania)	luo (Kenya et Tanzanie)
1	lus	lus	 	Lushai	lushai
1	mac	mkd	mk	Macedonian	macédonien
1	mad	mad	 	Madurese	madourais
1	mag	mag	 	Magahi	magahi
1	mah	mah	mh	Marshallese	marshall
1	mai	mai	 	Maithili	maithili
1	mak	mak	 	Makasar	makassar
1	mal	mal	ml	Malayalam	malayalam
1	man	man	 	Mandingo	mandingue
1	mao	mri	mi	Maori	maori
0	map	map	 	Austronesian (Other)	malayo-polynésiennes, autres langues
1	mar	mar	mr	Marathi	marathe
1	mas	mas	 	Masai	massaï
1	may	msa	ms	Malay	malais
1	mdf	mdf	 	Moksha	moksa
1	mdr	mdr	 	Mandar	mandar
1	men	men	 	Mende	mendé
0	mga	mga	 	Irish, Middle (900-1200)	irlandais moyen (900-1200)
1	mic	mic	 	Mi'kmaq; Micmac	mi'kmaq; micmac
1	min	min	 	Minangkabau	minangkabau
0	mis	mis	 	Miscellaneous languages	diverses, langues
0	mkh	mkh	 	Mon-Khmer (Other)	môn-khmer, autres langues
1	mlg	mlg	mg	Malagasy	malgache
1	mlt	mlt	mt	Maltese	maltais
1	mnc	mnc	 	Manchu	mandchou
1	mni	mni	 	Manipuri	manipuri
0	mno	mno	 	Manobo languages	manobo, langues
1	moh	moh	 	Mohawk	mohawk
1	mol	mol	mo	Moldavian	moldave
1	mon	mon	mn	Mongolian	mongol
1	mos	mos	 	Mossi	moré
2	mul	mul	 	Multiple languages	multilingue
0	mun	mun	 	Munda languages	mounda, langues
1	mus	mus	 	Creek	muskogee
1	mwl	mwl	 	Mirandese	mirandais
1	mwr	mwr	 	Marwari	marvari
0	myn	myn	 	Mayan languages	maya, langues
1	myv	myv	 	Erzya	erza
1	nah	nah	 	Nahuatl	nahuatl
0	nai	nai	 	North American Indian	indiennes d'Amérique du Nord, autres langues
1	nap	nap	 	Neapolitan	napolitain
1	nau	nau	na	Nauru	nauruan
1	nav	nav	nv	Navajo; Navaho	navaho
1	nbl	nbl	nr	Ndebele, South; South Ndebele	ndébélé du Sud
1	nde	nde	nd	Ndebele, North; North Ndebele	ndébélé du Nord
1	ndo	ndo	ng	Ndonga	ndonga
1	nds	nds	 	Low German; Low Saxon; German, Low; Saxon, Low	bas allemand; bas saxon; allemand, bas; saxon, bas
1	nep	nep	ne	Nepali	népalais
1	new	new	 	Newari; Nepal Bhasa	newari; nepal bhasa
1	nia	nia	 	Nias	nias
0	nic	nic	 	Niger-Kordofanian (Other)	nigéro-congolaises, autres langues
1	niu	niu	 	Niuean	niué
1	nno	nno	nn	Norwegian Nynorsk; Nynorsk, Norwegian	norvégien nynorsk; nynorsk, norvégien
1	nob	nob	nb	Norwegian Bokmål; Bokmål, Norwegian	norvégien bokmål; bokmål, norvégien
1	nog	nog	 	Nogai	nogaï; nogay
0	non	non	 	Norse, Old	norrois, vieux
1	nor	nor	no	Norwegian	norvégien
1	nso	nso	 	Northern Sotho, Pedi; Sepedi	sotho du Nord; pedi; sepedi
0	nub	nub	 	Nubian languages	nubiennes, langues
1	nwc	nwc	 	Classical Newari; Old Newari; Classical Nepal Bhasa	newari classique
1	nya	nya	ny	Chichewa; Chewa; Nyanja	chichewa; chewa; nyanja
1	nym	nym	 	Nyamwezi	nyamwezi
1	nyn	nyn	 	Nyankole	nyankolé
1	nyo	nyo	 	Nyoro	nyoro
1	nzi	nzi	 	Nzima	nzema
1	oci	oci	oc	Occitan (post 1500); Provençal	occitan (après 1500); provençal
1	oji	oji	oj	Ojibwa	ojibwa
1	ori	ori	or	Oriya	oriya
1	orm	orm	om	Oromo	galla
1	osa	osa	 	Osage	osage
1	oss	oss	os	Ossetian; Ossetic	ossète
1	ota	ota	 	Turkish, Ottoman (1500-1928)	turc ottoman (1500-1928)
0	oto	oto	 	Otomian languages	otomangue, langues
0	paa	paa	 	Papuan (Other)	papoues, autres langues
1	pag	pag	 	Pangasinan	pangasinan
0	pal	pal	 	Pahlavi	pahlavi
1	pam	pam	 	Pampanga	pampangan
1	pan	pan	pa	Panjabi; Punjabi	pendjabi
1	pap	pap	 	Papiamento	papiamento
1	pau	pau	 	Palauan	palau
0	peo	peo	 	Persian, Old (ca.600-400 B.C.)	perse, vieux (ca. 600-400 av. J.-C.)
1	per	fas	fa	Persian	persan
0	phi	phi	 	Philippine (Other)	philippines, autres langues
0	phn	phn	 	Phoenician	phénicien
1	pli	pli	pi	Pali	pali
1	pol	pol	pl	Polish	polonais
1	pon	pon	 	Pohnpeian	pohnpei
1	por	por	pt	Portuguese	portugais
0	pra	pra	 	Prakrit languages	prâkrit
0	pro	pro	 	Provençal, Old (to 1500)	provençal ancien (jusqu'à 1500)
1	pus	pus	ps	Pushto	pachto
1	que	que	qu	Quechua	quechua
1	raj	raj	 	Rajasthani	rajasthani
1	rap	rap	 	Rapanui	rapanui
1	rar	rar	 	Rarotongan	rarotonga
0	roa	roa		Romance (Other)	romanes, autres langues
1	roh	roh	rm	Raeto-Romance	rhéto-roman
1	rom	rom	 	Romany	tsigane
1	rum	ron	ro	Romanian	roumain
1	run	run	rn	Rundi	rundi
2	rus	rus	ru	Russian	russe
1	sad	sad	 	Sandawe	sandawe
1	sag	sag	sg	Sango	sango
1	sah	sah	 	Yakut	iakoute
0	sai	sai	 	South American Indian (Other)	indiennes d'Amérique du Sud, autres langues
0	sal	sal	 	Salishan languages	salish, langues
1	sam	sam	 	Samaritan Aramaic	samaritain
1	san	san	sa	Sanskrit	sanskrit
1	sas	sas	 	Sasak	sasak
1	sat	sat	 	Santali	santal
1	scc	srp	sr	Serbian	serbe
1	scn	scn	 	Sicilian	sicilien
1	sco	sco	 	Scots	écossais
1	scr	hrv	hr	Croatian	croate
1	sel	sel	 	Selkup	selkoupe
0	sem	sem	 	Semitic (Other)	sémitiques, autres langues
0	sga	sga	 	Irish, Old (to 900)	irlandais ancien (jusqu'à 900)
0	sgn	sgn	 	Sign Languages	langues des signes
1	shn	shn	 	Shan	chan
1	sid	sid	 	Sidamo	sidamo
1	sin	sin	si	Sinhala; Sinhalese	singhalais
0	sio	sio	 	Siouan languages	sioux, langues
0	sit	sit	 	Sino-Tibetan (Other)	sino-tibétaines, autres langues
0	sla	sla	 	Slavic (Other)	slaves, autres langues
1	slo	slk	sk	Slovak	slovaque
1	slv	slv	sl	Slovenian	slovène
1	sma	sma	 	Southern Sami	sami du Sud
1	sme	sme	se	Northern Sami	sami du Nord
0	smi	smi	 	Sami languages (Other)	sami, autres langues
1	smj	smj	 	Lule Sami	sami de Lule
1	smn	smn	 	Inari Sami	sami d'Inari
1	smo	smo	sm	Samoan	samoan
1	sms	sms	 	Skolt Sami	sami skolt
1	sna	sna	sn	Shona	shona
1	snd	snd	sd	Sindhi	sindhi
1	snk	snk	 	Soninke	soninké
0	sog	sog	 	Sogdian	sogdien
1	som	som	so	Somali	somali
1	son	son	 	Songhai	songhai
1	sot	sot	st	Sotho, Southern	sotho du Sud
2	spa	spa	es	Spanish; Castilian	espagnol; castillan
1	srd	srd	sc	Sardinian	sarde
1	srr	srr	 	Serer	sérère
0	ssa	ssa	 	Nilo-Saharan (Other)	nilo-sahariennes, autres langues
1	ssw	ssw	ss	Swati	swati
1	suk	suk	 	Sukuma	sukuma
1	sun	sun	su	Sundanese	soundanais
1	sus	sus	 	Susu	soussou
0	sux	sux	 	Sumerian	sumérien
1	swa	swa	sw	Swahili	swahili
1	swe	swe	sv	Swedish	suédois
1	syr	syr	 	Syriac	syriaque
1	tah	tah	ty	Tahitian	tahitien
0	tai	tai	 	Tai (Other)	thaïes, autres langues
1	tam	tam	ta	Tamil	tamoul
1	tat	tat	tt	Tatar	tatar
1	tel	tel	te	Telugu	télougou
1	tem	tem	 	Timne	temne
1	ter	ter	 	Tereno	tereno
1	tet	tet	 	Tetum	tetum
1	tgk	tgk	tg	Tajik	tadjik
1	tgl	tgl	tl	Tagalog	tagalog
1	tha	tha	th	Thai	thaï
1	tib	bod	bo	Tibetan	tibétain
1	tig	tig	 	Tigre	tigré
1	tir	tir	ti	Tigrinya	tigrigna
1	tiv	tiv	 	Tiv	tiv
1	tkl	tkl	 	Tokelau	tokelau
1	tlh	tlh	 	Klingon; tlhIngan-Hol	klingon
1	tli	tli	 	Tlingit	tlingit
1	tmh	tmh	 	Tamashek	tamacheq
1	tog	tog	 	Tonga (Nyasa)	tonga (Nyasa)
1	ton	ton	to	Tonga (Tonga Islands)	tongan (Îles Tonga)
1	tpi	tpi	 	Tok Pisin	tok pisin
1	tsi	tsi	 	Tsimshian	tsimshian
1	tsn	tsn	tn	Tswana	tswana
1	tso	tso	ts	Tsonga	tsonga
1	tuk	tuk	tk	Turkmen	turkmène
1	tum	tum	 	Tumbuka	tumbuka
0	tup	tup	 	Tupi languages	tupi, langues
1	tur	tur	tr	Turkish	turc
0	tut	tut	 	Altaic (Other)	altaïques, autres langues
1	tvl	tvl	 	Tuvalu	tuvalu
1	twi	twi	tw	Twi	twi
1	tyv	tyv	 	Tuvinian	touva
1	udm	udm	 	Udmurt	oudmourte
0	uga	uga	 	Ugaritic	ougaritique
1	uig	uig	ug	Uighur; Uyghur	ouïgour
1	ukr	ukr	uk	Ukrainian	ukrainien
1	umb	umb	 	Umbundu	umbundu
0	und	und	 	Undetermined	indéterminée
1	urd	urd	ur	Urdu	ourdou
1	uzb	uzb	uz	Uzbek	ouszbek
1	vai	vai	 	Vai	vaï
1	ven	ven	ve	Venda	venda
1	vie	vie	vi	Vietnamese	vietnamien
1	vol	vol	vo	Volapük	volapük
1	vot	vot	 	Votic	vote
0	wak	wak	 	Wakashan languages	wakashennes, langues
1	wal	wal	 	Walamo	walamo
1	war	war	 	Waray	waray
1	was	was	 	Washo	washo
1	wel	cym	cy	Welsh	gallois
0	wen	wen	 	Sorbian languages	sorabes, langues
1	wln	wln	wa	Walloon	wallon
1	wol	wol	wo	Wolof	wolof
1	xal	xal	 	Kalmyk	kalmouk
1	xho	xho	xh	Xhosa	xhosa
1	yao	yao	 	Yao	yao
1	yap	yap	 	Yapese	yapois
1	yid	yid	yi	Yiddish	yiddish
1	yor	yor	yo	Yoruba	yoruba
0	ypk	ypk	 	Yupik languages	yupik, langues
1	zap	zap	 	Zapotec	zapotèque
1	zen	zen	 	Zenaga	zenaga
1	zha	zha	za	Zhuang; Chuang	zhuang; chuang
1	znd	znd	 	Zande	zandé
1	zul	zul	zu	Zulu	zoulou
1	zun	zun	 	Zuni	zuni
\.
-- ' -- Vim syntax catch-up
UPDATE language SET isocode_2 = NULL WHERE isocode_2 = '  ';

-- see http://www.unicode.org/iso15924/iso15924-num.html
COPY script (frequency, isonumber, isocode, name, french_name) FROM stdin;
1	020	Xsux	Cuneiform, Sumero-Akkadian	cunéiforme suméro-akkadien
1	030	Xpeo	Old Persian	cunéiforme persépolitain
2	040	Ugar	Ugaritic	ougaritique
1	050	Egyp	Egyptian hieroglyphs	hiéroglyphes égyptiens
1	060	Egyh	Egyptian hieratic	hiératique égyptien
1	070	Egyd	Egyptian demotic	démotique égyptien
1	090	Maya	Mayan hieroglyphs	hiéroglyphes mayas
1	100	Mero	Meroitic	méroïtique
1	115	Phnx	Phoenician	phénicien
1	120	Tfng	Tifinagh (Berber)	tifinagh (berbère)
4	125	Hebr	Hebrew	hébreu
2	135	Syrc	Syriac	syriaque
1	136	Syrn	Syriac (Eastern variant)	syriaque (variante orientale)
1	137	Syrj	Syriac (Western variant)	syriaque (variante occidentale)
1	138	Syre	Syriac (Estrangelo variant)	syriaque (variante estranghélo)
1	140	Mand	Mandaean	mandéen
3	145	Mong	Mongolian	mongol
4	160	Arab	Arabic	arabe
2	170	Thaa	Thaana	thâna
1	175	Orkh	Orkhon	orkhon
1	176	Hung	Old Hungarian	ancien hongrois
4	200	Grek	Greek	grec
1	204	Copt	Coptic	copte
2	206	Goth	Gothic	gotique
2	210	Ital	Old Italic (Etruscan, Oscan, etc.)	ancien italique (étrusque, osque, etc.)
2	211	Runr	Runic	runique
2	212	Ogam	Ogham	ogam
4	215	Latn	Latin	latin
1	216	Latg	Latin (Gaelic variant)	latin (variante gaélique)
1	217	Latf	Latin (Fraktur variant)	latin (variante brisée)
4	220	Cyrl	Cyrillic	cyrillique
1	221	Cyrs	Cyrillic (Old Church Slavonic variant)	cyrillique (variante slavonne)
1	225	Glag	Glagolitic	glagolitique
1	227	Perm	Old Permic	ancien permien
3	230	Armn	Armenian	arménien
3	240	Geor	Georgian (Mkhedruli)	géorgien (mkhédrouli)
1	250	Dsrt	Deseret (Mormon)	déseret (mormon)
2	260	Osma	Osmanya	osmanais
1	280	Visp	Visible Speech	parole visible
1	281	Shaw	Shavian (Shaw)	shavien (Shaw)
1	282	Plrd	Pollard Phonetic	phonétique de Pollard
3	285	Bopo	Bopomofo	bopomofo
4	286	Hang	Hangul	hangûl
1	290	Teng	Tengwar	tengwar
1	291	Cirt	Cirth	cirth
1	292	Sara	Sarati	sarati
1	300	Brah	Brahmi	brâhmî
1	305	Khar	Kharoshthi	kharochthî
3	310	Guru	Gurmukhi	gourmoukhî
3	315	Deva	Devanagari (Nagari)	dévanâgarî
1	316	Sylo	Syloti Nagri	sylotî nâgrî
3	320	Gujr	Gujarati	goudjarâtî (gujrâtî)
3	325	Beng	Bengali	bengalî
3	327	Orya	Oriya	oriyâ
3	330	Tibt	Tibetan	tibétain
1	331	Phag	Phags-pa	'phags pa
1	335	Lepc	Lepcha (Róng)	lepcha (róng)
2	336	Limb	Limbu	limbou
3	340	Telu	Telugu	télougou
3	345	Knda	Kannada	kannara (canara)
3	346	Taml	Tamil	tamoul
3	347	Mlym	Malayalam	malayâlam
3	348	Sinh	Sinhala	singhalais
3	350	Mymr	Myanmar (Burmese)	birman
4	352	Thai	Thai	thaï
2	353	Tale	Tai Le	taï le
1	354	Talu	Tai Lue	taï lue
3	355	Khmr	Khmer	khmer
3	356	Laoo	Lao	laotien
1	357	Kali	Kayah Li	kayah li
1	358	Cham	Cham	cham (čam, tcham)
1	360	Bali	Balinese	balinais
1	361	Java	Javanese	javanais
1	365	Batk	Batak	batak
1	367	Bugi	Buginese	bouguis
2	370	Tglg	Tagalog	tagal
2	371	Hano	Hanunoo (Hanunóo)	hanounóo
2	372	Buhd	Buhid	bouhide
2	373	Tagb	Tagbanwa	tagbanoua
1	400	Lina	Linear A	linéaire A
2	401	Linb	Linear B	linéaire B
2	403	Cprt	Cypriot	syllabaire chypriote
3	410	Hira	Hiragana	hiragana
4	411	Kana	Katakana	katakana
4	412	Hrkt	Kanji & Kana	kanji & kana
3	430	Ethi	Ethiopic (Ge'ez)	éthiopique (éthiopien, ge'ez)
2	440	Cans	Unified Canadian Aboriginal Syllabics	syllabaire autochtone canadien unifié
2	445	Cher	Cherokee	tchérokî
1	450	Hmng	Pahawh Hmong	pahawh hmong
2	460	Yiii	Yi	yi
1	470	Vaii	Vai	vaï
4	500	Hani	Han (Hanzi, Kanji, Hanja)	idéogrammes han
4	501	Hans	Han (Simplified variant)	idéogrammes han (variante simplifiée)
4	502	Hant	Han (Traditional variant)	idéogrammes han (variante traditionelle)
1	550	Blis	Blissymbols	symboles Bliss
1	570	Brai	Braille	braille
1	610	Inds	Indus (Harappan)	indus
1	620	Roro	Rongorongo	rongorongo
\.
-- 900	Qaaa	Reserved for private use (start)	réservé à l'usage privé (début)
-- 949	Qabx	Reserved for private use (end)	réservé à l'usage privé (fin)
-- 997	Zxxx	Code for unwritten languages	codet pour les langues non écrites
-- 998	Zyyy	Code for undetermined script	codet pour écriture indéterminée
-- 999	Zzzz	Code for uncoded script	codet pour écriture non codée
-- ' -- Vim syntax catch-up

-- see http://www.unicode.org/onlinedat/languages-scripts.html
COPY tmp_sl FROM stdin;
afr	Latn
sqi	Latn
ara	Arab
hye	Armn
hye	Syrc
asm	Beng
aym	Latn
aze	Arab
aze	Cyrl
aze	Latn
bak	Cyrl
eus	Latn
bel	Cyrl
ben	Beng
bos	Latn
bre	Latn
bul	Cyrl
che	Cyrl
chr	Cher
chr	Latn
chv	Cyrl
cop	Grek
cor	Latn
cos	Latn
cre	Latn
hrv	Latn
ces	Latn
dan	Latn
dar	Cyrl
dzo	Tibt
eng	Latn
epo	Latn
est	Latn
fao	Latn
fij	Latn
fin	Latn
fra	Latn
fry	Latn
deu	Latn
gon	Telu
grn	Latn
guj	Gujr
hau	Latn
hau	Arab
haw	Latn
heb	Hebr
hmn	Latn
hun	Latn
isl	Latn
ind	Arab
ind	Latn
inh	Arab
inh	Latn
iku	Latn
gle	Latn
ita	Latn
jav	Latn
jav	Java
kbd	Cyrl
xal	Cyrl
kan	Knda
kau	Latn
kas	Arab
kaz	Cyrl
kha	Latn
kha	Beng
khm	Khmr
kir	Arab
kir	Latn
kir	Cyrl
kom	Cyrl
kom	Latn
kur	Arab
kur	Cyrl
kur	Latn
lad	Hebr
lao	Laoo
lat	Latn
lav	Latn
lez	Cyrl
lit	Latn
mkd	Cyrl
msa	Arab
msa	Latn
mal	Mlym
mlt	Latn
mnc	Mong
chm	Cyrl
chm	Latn
mol	Cyrl
mon	Mong
mon	Cyrl
nog	Cyrl
nor	Latn
ori	Orya
pli	Sinh
pli	Thai
pol	Latn
por	Latn
que	Latn
ron	Latn
ron	Cyrl
rom	Cyrl
rom	Latn
rus	Cyrl
san	Sinh
sat	Beng
sat	Orya
sel	Cyrl
srp	Cyrl
sna	Latn
snd	Arab
slk	Latn
slv	Latn
som	Latn
swa	Latn
swe	Latn
syr	Syrc
tgl	Latn
tgl	Tglg
tah	Latn
tgk	Arab
tgk	Latn
tam	Taml
tat	Cyrl
tel	Telu
tha	Thai
bod	Tibt
tur	Arab
tur	Latn
tuk	Arab
tuk	Latn
udm	Cyrl
udm	Latn
urd	Arab
uzb	Cyrl
uzb	Latn
vie	Latn
sah	Cyrl
yid	Hebr
yor	Latn
\.
-- ' -- Vim syntax catch-up

INSERT INTO script_language (script, language)
SELECT  s.id, l.id
FROM    tmp_sl t, language l, script s
WHERE   l.isocode_3t = t.language
AND     s.isocode = t.script;

-- alter moderation_open and moderation_closed
ALTER TABLE moderation_open ADD COLUMN language INTEGER;
ALTER TABLE moderation_closed ADD COLUMN language INTEGER;

-- primary keys
ALTER TABLE language ADD CONSTRAINT language_pkey PRIMARY KEY (id);
ALTER TABLE script ADD CONSTRAINT script_pkey PRIMARY KEY (id);
ALTER TABLE script_language ADD CONSTRAINT script_language_pkey PRIMARY KEY (id);

-- sequence values
SELECT SETVAL('language_id_seq', ( SELECT MAX(id)+1 FROM language ));
SELECT SETVAL('script_id_seq', ( SELECT MAX(id)+1 FROM script ));
SELECT SETVAL('script_language_id_seq', ( SELECT MAX(id)+1 FROM script_language ));

-- indexes
CREATE UNIQUE INDEX language_isocode_3b ON language (isocode_3b);
CREATE UNIQUE INDEX language_isocode_3t ON language (isocode_3t);
CREATE UNIQUE INDEX language_isocode_2 ON language (isocode_2);
CREATE UNIQUE INDEX script_isocode ON script (isocode);
CREATE UNIQUE INDEX script_isonumber ON script (isonumber);
CREATE UNIQUE INDEX script_language_sl ON script_language (script, language);
CREATE INDEX moderation_open_idx_language ON moderation_open (language);
CREATE INDEX moderation_closed_idx_language ON moderation_closed (language);

-- add new columns to album
ALTER TABLE album ADD COLUMN language INTEGER;
ALTER TABLE album ADD COLUMN script INTEGER;
ALTER TABLE album ADD COLUMN modpending_lang INTEGER;

-- FKs
ALTER TABLE album
    ADD CONSTRAINT album_fk_language
    FOREIGN KEY (language)
    REFERENCES language(id);

ALTER TABLE album
    ADD CONSTRAINT album_fk_script
    FOREIGN KEY (script)
    REFERENCES script(id);

ALTER TABLE script_language
    ADD CONSTRAINT script_language_fk_language
    FOREIGN KEY (language)
    REFERENCES language(id);

ALTER TABLE script_language
    ADD CONSTRAINT script_language_fk_script
    FOREIGN KEY (script)
    REFERENCES script(id);

ALTER TABLE moderation_open
    ADD CONSTRAINT moderation_open_fk_language
    FOREIGN KEY (language)
    REFERENCES language(id);

ALTER TABLE moderation_closed
    ADD CONSTRAINT moderation_closed_fk_language
    FOREIGN KEY (language)
    REFERENCES language(id);

-- views
DROP VIEW moderation_all;

CREATE VIEW moderation_all AS
    SELECT * FROM moderation_open
    UNION ALL
    SELECT * FROM moderation_closed;

COMMIT;

\unset ON_ERROR_STOP

-- vi: set ts=4 sw=4 et :
