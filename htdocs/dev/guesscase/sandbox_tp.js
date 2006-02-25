function TrackParserCases(va, url, name, pages) {	
	this.va = va;
	this.url = url;
	this.name = name;
	this.pages = pages;
	this.getURL = function() { return this.url; };
	this.isVA = function() { return this.va; };
	this.getName = function() { return this.name; };
	this.getPages = function() { return this.pages; };
}
function TrackParserPage(site, description, listing) {	
	this.site = site;
	this.description = description;
	this.listing = listing;
	this.getSite = function() { return this.site; };
	this.getDescription = function() { return this.description; };
	this.getListing = function() { return this.listing; };
}
function TrackParserTest() {	
	this.sa = false;
	this.va = true;
	this.LOGID = "tptest";

	this.testCases = [
		new TrackParserCases(
			this.sa,
			'http://www.discogs.com/release/345107',	
			'The Prodigy - Always Outnumbered, Never Outgunned',
			[
			new TrackParserPage(	
				'discogs.com', 
				'Featuring artists',
				'1   Spitfire (5:08)\nVocals - Juliette Lewis\n2   Girls (4:07)\nVocals - Ping Pong Bitches\n3   Memphis Bells (4:28)\nVocals - Princess Superstar\n4   Get Up Get Off (4:19)\nCo-producer - Dave Pemberton\n  Vocals - Twista\n5   Hotride (4:36)\nVocals - Juliette Lewis\n6   Wake Up Call (4:56)\nVocals - Hannah Robinson , Kool Keith , Louise Boone\n7   Action Radar (5:32)\nVocals - Louise Boone , Paul \'Dirtcandy\' Jackson\n8   Medusa\'s Path (6:08)\n9   Phoenix (4:38)\nVocals - Louise Boone\n10   You\'ll Be Under My Wheels (3:56)\nVocals - Kool Keith\n11   The Way It Is (5:46)\nVocals - Louise Boone , Neil McLellan\n12   Shoot Down (4:32)\nCo-producer - Jan \'Stan\' Kybert\n  Featuring - Noel Gallagher\n  Vocals - Liam Gallagher\n13   More Girls (4:26)\nVocals - Juliette Lewis\n'
			),
			new TrackParserPage(	
				'amazon.de', 
				'Plain tracklisting',
				'1. Spitfire        \n2. Girls        \n3. Memphis Bells        \n4. Get Up Get Off        \n5. Hot Ride        \n6. Wake Up Call        \n7. Action Radar        \n8. Medusa\'s Path        \n9. Phoenix        \n10. You\'ll Be Under My Wheels        \n11. Way It Is        \n12. Shootdown        \n13. More Girls [*]     \n'
			),
			new TrackParserPage(	
				'amazon.com',
				'With listen links',
				'1. Spitfire        Listen Listen Listen\n2. Girls        Listen Listen Listen\n3. Memphis Bells        Listen Listen Listen\n4. Get Up Get Off        Listen Listen Listen\n5. Hot Ride        Listen Listen Listen\n6. Wake Up Call        Listen Listen Listen\n7. Action Radar        Listen Listen Listen\n8. Medusa\'s Path        Listen Listen Listen\n9. Phoenix        Listen Listen Listen\n10. You\'ll Be Under My Wheels        Listen Listen Listen\n11. Way It Is        Listen Listen Listen\n12. Shootdown        Listen Listen Listen\n13. More Girls [*]     Listen Listen Listen\n'
			)
		]),

		new TrackParserCases(
			this.sa,
			'http://www.discogs.com/release/368764',	
			'Nightwish - Century Child',
			[
			new TrackParserPage(	
				'discogs.com', 
				'Vinyl numbering scheme<br/>&raquo; Mark the checkbox \'Detect Vinyl track numbers\' in the TrackParser UI',
				'A1   Bless The Child \nA2   End Of All Hope \nA3   Dead To The World \nA4   Ever Dream \nB1   Slaying The Dreamer \nB2   Forever Yours \nB3   Ocean Soul \nB4   Feel For You \nB5   The Phantom Of The Opera \nC   Beauty Of The Beast: Long Lost Love - One More Night To Live - Christabel'
			)
		]),

		new TrackParserCases(this.sa,
			'http://www.babyblaue-seiten.de/index.php?albumId=464&content=review',	
			'Threshold - Wounded land',
			[
			new TrackParserPage(	
				'babyblaue-seiten.de', 
				'No brackets around the track times',
				'1.Consume to live  8:11  \n2.Days of dearth  5:26  \n3.Sanity\'s end  10:21  \n4.Paradox  7:15  \n5.Surface to air  10:14  \n6.Mother earth  5:52  \n7.Siege of Baghdad  7:44  \n8.Keep it with mine  2:27'
			)
		]),

		new TrackParserCases(this.sa,
		   'http://www.metal-archives.com/release.php?id=1374',	
		   'Dream Theater - Metropolis Pt. 2: Scenes from a Memory ',
		   [
			new TrackParserPage(	
				'metal-archives.com', 
				'Additional info (lyrics links)<br/>&raquo; Mark the checkbox \'Remove text in brackets \' in the TrackParser UI',
				'1. Regression 02:06 [view lyrics] \n2. Overture 1928 03:38  \n3. Strange Deja Vu 05:12 [view lyrics] \n4. Through My Words 01:03 [view lyrics] \n5. Fatal Tragedy 06:49 [view lyrics] \n6. Beyond This Life 11:23 [view lyrics] \n7. Through Her Eyes 05:29 [view lyrics] \n8. Home 12:53 [view lyrics] \n9. The Dance of Eternity 06:14  \n10. One Last Time 03:47 [view lyrics] \n11. The Spirit Carries On 06:38 [view lyrics] \n12. Finally Free 12:00 [view lyrics] '
			),
			new TrackParserPage(	
				'discogs.com', 
				'Additional info, ACT information',
				'   ACT I \n1   Scene One: Regression (2:06) \n2   Scene Two: I. Overture 1928 (3:37) \n3   Scene Two: II. Strange Deja Vu (5:12) \n4   Scene Three: I. Through My Words (1:02) \n5   Scene Three: II. Fatal Tragedy (6:49) \n6   Scene Four: Beyond This Life (11:22) \n7   Scene Five: Through Her Eyes (5:29) \n   ACT II \n8   Scene Six: Home (12:53) \n9   Scene Seven: I. The Dance Of Eternity (6:13) \n10   Scene Seven: II. One Last Time (3:46) \n11   Scene Eight: The Spirit Carries On (6:38) \n12   Scene Nine: Finally Free (11:59) '
			)
		]),
	
		new TrackParserCases(this.va,
			'http://www.discogs.com/release/171251',	
			'Factor E',
			[
			new TrackParserPage(	
				'Discogs',
				'Artist-Tracktitle separated by 2xWhiteSpace', 
				"01 DJ Quest  Fuct Beat (Autobots Remix) (5:33) \n    Remix - Autobots  \n02 Factor E  Swing Punk (4:59) \n03 Knick  Kool Down (6:29) \n    Featuring - Factor E  \n04 Factor E  Street Schit (6:01) \n    Featuring - Knick  \n05 DJ Infiniti  Motormouth (Knick & Factor E Remix) (5:06) \n    Featuring - Franco D \n  Remix - Factor E , Knick  \n06 Pimphand Army  Ghetto Dope (4:38) \n07 Autobots  Rocky (Distortionz Remix) (6:29) \n    Remix - Distortionz  \n08 Rick West  The Flow (Factor E vs. Knick Remix) (4:38) \n    Remix - Factor E , Knick  \n09 Autobots  From Outerspace (5:06) \n    Featuring - Prodigy, The  \n10 Pimphand Army  Revenge (5:06) \n11 POF  Freakquency (Factor E Remix) (4:38) \n    Remix - Factor E  \n12 Factor E  CTM (Jackal & Hyde Remix) (5:12) \n    Remix - Jackal & Hyde  \n13 Factor E  Move This Bass (Infiniti Remix) (6:36) \n    Remix - DJ Infiniti  \n14 Knick & Factor E  Bounce Dem (5:06) \n    Featuring - Autobots"
			)
		]),

		new TrackParserCases(this.va,
			'http://www.amazon.de/exec/obidos/ASIN/B0000C6IY4/302-0112881-8345672',	
			'Best of Cafe Del Mar',
			[
			new TrackParserPage(	
				'amazon.com',
				'Artist-Tracktitle separated by \' - \'', 
				"1.Paco De Lucia - Entre Dos Aguas\n2.Karen Ramirez - Troubled Girl\n3.Ben Onono - Tatouage Blue\n4.Mari Boine - Gula Gula\n5.Lux - Norther Light\n6.Jose Padilla - Adios Ayer\n7.Lamb - Angelica\n 8.Sabres Of Paradise - Smoke Belch\n9.Phil Mison - Lula\n10.Coldplay - God Put A Smile On My Face - Chris Martin\'s Brother Mix)\n11.Moonrock - Hill Street Blues\n12.The Ballistic Brothers - Uschi\'s Groove\n13.New Funky Generation - The Messanger"
			)
		]),

		new TrackParserCases(this.va,
			'http://www.amazon.de/exec/obidos/ASIN/B00094OC3I/ref%3Dpd%5Fbxgy%5Fimg%5F2/028-4941168-6103723',	
			'Schattenreich Vol.2',
			[
			new TrackParserPage(	
				'amazon.com',
				'Artist with hyphens', 
				"1.Nightwish - Nemo 4:36\n2.Qntal - Flamma 3:58\n3.ASP - Ich will brennen 4:44\n4.Oomph! - Sex hat keine Macht 3:43\n5.Xandria - Ravenheart 3:44\n6.Schandmaul - Leb! 3:52\n7.Frontline Assembly - Maniacal 5:14\n8.XPQ-21 - Rockin´ Silver Knight 5:21\n9.Exilia - Can`t break me down 3:10\n 10.Dreden Dolls Coin-Operated Boy 3:33\n11.Lab - Where heaven ends 3:38\n12.Unheilig - Freiheit 3:54\n13.Escape With Romeo - It`s loneliness 4:24\n14.Pink Turns Blue - True Love 5:00\n15.Blutengel - Forever 4:34\n16.Paradise Lost - Forever after 3:47\n17.Gothminister - Monsters 3:12\n18.Project Pitchfork - Schall und Rauch 4:20"
			),
			new TrackParserPage(	
				'amazon.com',
				'Unicode, Hyphens and Slashes mixed', 
				"1.HIM - And love said no 3:42\n2.Within Temptation - Stand my ground 3:49\n3.miLù mit Kim Sanders & Peter Heppner - Aus Gold 3:38\n4.De/Vision - Turn me on ( Wave In Head Mix ) 4:35\n5.2Raumwohnung - Spiel mit 3:47\n6.Angelzoom feat. Joachim Witt - Back in the moment 3:16\n7.L`ame Immortelle - 5 Jahre 3:42\n8.Regicide - The Fragrance 5:13\n9.Billy Idol - White wedding ( Parts I & II ) ( Shotgun Mix ) 8:25\n 10.Zeraphine - Die Macht in Dir 3:14\n11.Covenant - Bullet 3:38\n12.[:SITD:] - Richtfest 6:17\n13.Lacrimosa - Kelch der Liebe 6:02\n14.Tanzwut - Caupona 4:43\n15.Haggard - The final victory 3 :35\n16.The 69 Eyes - Lost Boys 3:23\n17.Deine Lakaien - Over and done 4:25"
			)
		])
	];

	// Print the different test cases
	// ----------------------------------------------------------------------------
	this.writeUI = function(isVA) {
		s = [];
		s.push('<tr>');
		s.push('<td colspan="5" style="font-size: 12px">');
		s.push('<div style="background: #ffeeff; border: 1px solid black; padding: 4px; margin-bottom: 10px;">');
		s.push('<div style="float:right"><a href="javascript: void(0)" onClick="sandBox.tp.setVisible(); return false;"><img src="/images/es/maximize.gif"></a></div>');
		s.push('<div style="font-size: 13px; font-weight: bold;">Track Parser Tests</div>');
		s.push('<div id="testlist" style="display: none; padding-bottom: 4px">');
		for (var i=0; i<this.testCases.length; i++) {
			var tc = this.testCases[i];
			if (tc.isVA() == isVA) {
				s.push(''+tc.getName()+' <small>(<a target="_blank" href="'+tc.getURL()+'">View</a>)</small>');
				s.push('<ul style="margin-top: 0px; margin-bottom: 0px; padding-left: 25px; margin-left: 0px">');
				var pages = tc.getPages();
				for (var j=0; j<pages.length; j++) {
					var page = pages[j];
					s.push('<li><a href="javascript: sandBox.tp.onRunTest('+i+','+j+'); // run test" ');
					s.push('onFocus="this.blur()">');
					s.push(page.getSite());
					s.push('</a> <br/>&nbsp;<small>');
					s.push(page.getDescription());
					s.push('</small></li>');
				}
				s.push('</ul>');
			}
		}
		s.push('</div>');
		s.push('</div>');
		s.push('</td>');
		s.push('</tr>');			
		document.write(s.join(""));
	};

	// Run the testcase i.
	// ----------------------------------------------------------------------------
	this.setVisible = function() {
		var obj;
		if ((obj = document.getElementById("testlist")) != null) {
			obj.style.display = (obj.style.display == "none" ? "" : "none");
		}
	};

	// Run the testcase i.
	// ----------------------------------------------------------------------------
	this.onRunTest = function(i,j) {
		mb.log.scopeStart("Running TrackParser TestCase");
		mb.log.enter(this.LOGID, "onRunTest");
		mb.log.info("Running tests: $, $");
		var obj = null;
		if ((obj = document.getElementById(es.tp.TRACKSAREA)) != null) {
			var tc = this.testCases[i];
			if (tc instanceof TrackParserCases) {
				var tp = tc.getPages()[j];
				if (tp instanceof TrackParserPage) {
					mb.log.info("Loading test: $, site: ", tc.getName(), tp.getSite());
					obj.value = tp.getListing();
					es.tp.parseNow(tc.isVA());  
				}
			}
		}
		mb.log.exit();
		mb.log.scopeEnd();
	};
}
