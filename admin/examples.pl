#!/usr/bin/perl -w
#____________________________________________________________________________
#
#   MusicBrainz -- the open internet music database
#
#   Copyright (C) 2000 Johan Pouwelse
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#   $Id$
#____________________________________________________________________________

#this script inserts some example records in the database, showing al the features 
#of the musicBrainz database.
#As an example the National Anthems of several countries are inserted in the database.

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";

use strict;
use DBI;
use DBDefs;
use MusicBrainz;
use Artist;
use Album;
use Track;
use Lyrics;
use Sql;

my ($mb, $al, $ar, $tr, $ly);

#yes, all the lyrics are hand-coded in this Perl file, no include file used.
#everything about the example is now nicely in 1 file.

my $france = 'Allons enfants de la Patrie,
Le jour de gloire est arrivé !
Contre nous de la tyrannie ! 
L\'étendard sanglant est levé (bis) 
Entendez-vous dans nos campagnes
Mugir ces féroces soldats ?
Ils viennent jusque dans vos bras. 
Egorger vos fils, vos compagnes ! 

Refrain

Aux armes citoyens, 
Formez vos bataillons 
Marchons, marchons 
Qu\'un sang impur 
Abreuve nos sillons 

Que veut cette horde d\'esclaves, 
De traîtres, de rois conjurés ? 
Pour qui ces ignobles entraves 
Ces fers dès longtemps préparés ? (bis) 
Français, pour nous, ah! quel outrage 
Quels transports il doit exciter ? 
C\'est nous qu\'on ose méditer 
De rendre à l\'antique esclavage ! 
(Refrain) 

Quoi ces cohortes étrangères ! 
Feraient la loi dans nos foyers ! 
Quoi ! ces phalanges mercenaires 
Terrasseraient nos fils guerriers ! (bis) 
Grand Dieu! par des mains enchaînées 
Nos fronts sous le joug se ploieraient 
De vils despotes deviendraient 
Les maîtres des destinées. 
(Refrain) 

Tremblez, tyrans et vous perfides 
L\'opprobre de tous les partis, 
Tremblez ! vos projets parricides 
Vont enfin recevoir leurs prix ! (bis) 
Tout est soldat pour vous combattre, 
S\'ils tombent, nos jeunes héros, 
La France en produit de nouveaux, 
Contre vous tout prêts à se battre 
(Refrain) 

Français, en guerriers magnanimes 
Portez ou retenez vos coups ! 
Épargnez ces tristes victimes, 
A regret s\'armant contre nous (bis) 
Mais ces despotes sanguinaires, 
Mais ces complices de Bouillé, 
Tous ces tigres qui, sans pitié, 
Déchirent le sein de leur mère ! 
(Refrain) 

Nous entrerons dans la carrière 
Quand nos aînés n\'y seront plus, 
Nous y trouverons leur poussière 
Et la trace de leurs vertus (bis) 
Bien moins jaloux de leur survivre 
Que de partager leur cercueil, 
Nous aurons le sublime orgueil 
De les venger ou de les suivre ! 
(Refrain) 

Amour sacré de la Patrie, 
Conduis, soutiens nos bras vengeurs 
Liberté, Liberté chérie 
Combats avec tes défenseurs ! (bis) 
Sous nos drapeaux, que la victoire 
Accoure à tes mâles accents 
Que tes ennemis expirants 
Voient ton triomphe et notre gloire ! 
(Refrain)';

my $dutch = 'Wilhelmus van Nassouwe
ben ik van Duitsen bloed
den vaderland getrouwe
blijf ik tot in den dood.
Een Prinse van Oranje
ben ik, vrij onverveerd,
den Koning van Hispanje
heb ik altijd geëerd

Mijn schild ende betrouwen
zijt Gij, o God mijn Heer,
op U zo wil ik bouwen,
verlaat mij nimmermeer.
Dat ik doch vroom mag blijven,
uw dienaar t\'aller stond,
de tirannie verdrijven
die mij mijn hert doorwondt.';

my $uk='God save our gracious Queen,
Long live our noble Queen,
God save the Queen!
Send her victorious,
Happy and glorious,
Long to reign over us,
God save the Queen!

O lord God arise,
Scatter our enemies,
And make them fall!
Confound their knavish tricks,
Confuse their politics,
On you our hopes we fix,
God save the Queen!

Not in this land alone,
But be God\'s mercies known,
From shore to shore!
Lord make the nations see,
That men should brothers be,
And form one family,
The wide world ov\'er

From every latent foe,
From the assasins blow,
God save the Queen!
O\'er her thine arm extend,
For Britain\'s sake defend,
Our mother, prince, and friend,
God save the Queen!

Thy choicest gifts in store,
On her be pleased to pour,
Long may she reign!
May she defend our laws,
And ever give us cause,
To sing with heart and voice,
God save the Queen!';

my $us='Oh, say, can you see, by the dawn\'s early light,
What so proudly we hail\'d at the twilight\'s last gleaming?
Whose broad stripes and bright stars, thro\' the perilous fight, 
O\'er the ramparts we watch\'d, were so gallantly streaming?
And the rocket\'s red glare, the bombs bursting in air
Gave proof thro\' the night that our flag was still there.
Oh, say, does that Star-Spangled Banner yet wave
O\'er the land of the free and the home of the brave? 

On the shore, dimly seen thro\' the mists of the deep,
Where the foe\'s haughty host in dread silence reposes,
What is that which the breeze, o\'er the towering steep,
As it fitfully blows half conceals, half discloses?
Now it catches the gleam of the morning\'s first beam,
In full glory reflected now shines in the stream;
\'Tis the Star-Spangled Banner, O long may it wave
O\'er the land of the free and the home of the brave. 

Oh, thus be it ever when free men shall stand
Between their loved homes and the war\'s desolation!
Blest with vict\'ry and peace, may the heav\'n rescued land
Praise the Pow\'r that hath made and preserved us a nation!
Then conquer we must, when our cause it is just,
And this be our motto, "In God is our trust"
And the Star-Spangled Banner in triumph shall wave
O\'er the land of the free and the home of the brave!';


my %dutch_trackinfo = (
1000=>'Het Wilhelmus is geschreven tussen 1568 en 1572 en is daarmee het oudste volkslied ter wereld.',
10000=>'De auteur is waarschijnlijk Marnix van St. Allegonde, alhoewel sommigen beweren dat het Coornhert is geweest.',
24000=>'Het Wilhelmus is een ode aan Willem van Oranje en alhoewel het dateert uit de zestiende eeuw, is het pas in 1932 het officiële Nederlandse volkslied geworden.',
37000=>'Kijk voor meer informatie bij <A HREF="http://www.wilhelmus.nl/OntstaanWilhelmus.html">Onstaan en Geschiedenis</A> van het Wilhelmus.');

my %dutch_artistinfo = (
10000=>' Voor de jaartelling kreeg het Nederlandse landschap vorm als gevolg van fluctuaties in de zee-spiegel, door afzetting van gletjers in het noorden en van rivieren in het zuiden.',
25000=>'De oudste bewoners leefden van jacht op rendieren en ander wild en van het verzamelen van vruchten.',
35000=>'Rond 4000 voor de jaartelling vestigden zich in het zuiden de eerste landbouwers.',
45000=>'De grens van het Romeise rijk liep langs de Rijn van Nijmegen, Utrecht en Leiden. Legerkampen en wegen maakten verdedeging van het zuiden tegen Friezen en andere volkeren mogelijk. De \'limes\' stond overigens handel en culturele uitwisseling niet in de weg.',
55000=>'Het Romeinse leger bracht handel op gang. In de landbouw waren grote bedrijven met landhuizen een nieuw verschijnsel.',
75000=>'De Germanen hadden goden: o.a. Wodam en Feia. Zendelingen zetten de bijl in de Wodaneik. Zij brachten het evangelie.',
100000=>'Het rijk van Karel de Grote strekte zich uit tot in Duitsland, Frankrijk en Italie. Ook in Nederland bracht het na de volksverhuizingen politieke orde, onderwijs, kunst en beschaving. De Friezen profiteerden van de rust met hun handel vanuit het knooppunt Dorestad.');

sub EnterRecord
{
    my $title = shift @_;
    my $artistname = shift @_;
    my $al = shift @_;
    my $songtext = shift @_;
    my $writer = shift @_;
    my $seq = shift @_;

    if ($artistname eq '')
    {
        $artistname = "Unknown";
    }
    
    $ar->SetName($artistname);
    $ar->SetSortName($artistname);
    my $artist = $ar->Insert();
    if (!defined $artist)
    {
        print "Cannot insert artist.\n";
        $mb->Logout();
        exit 0;
    }
    $al->SetArtist($artist);

    $tr->SetName($title);
    $tr->SetArtist($artist);
    $tr->SetAlbum($al->GetId());
    $tr->SetSequence($seq);
    my $track = $tr->Insert($al, $ar);
    if (!defined $track)
    {
        print "Cannot insert track.\n";
        $mb->Logout();
        exit 0;
    }
    #does the user have the lyrics turned on?
    if (!DBDefs::USE_LYRICS) { return $track }

    my $lyrics = $ly->InsertLyrics($track, $songtext, $writer);
    if ($track < 0)
    {
        print "Cannot insert lyrics.\n";
        $mb->Logout();
        exit 0;
    }
    return $track;
}

sub add_examples
{
    my ($track, $artist);

    #Make 1 album for all examples
    #multiple artist album with artistid 0

    $al->SetName("National Anthems");
    $al->SetArtist(ModDefs::VARTIST_ID);
    my $album = $al->Insert();
    if ($album < 0)
    {
        print "Cannot insert album.\n";
        $mb->Logout();
        exit 0;
    }
    EnterRecord('La Marseillaise', 'France', $al, $france, 'Napoleon', 1);
    $track = EnterRecord('Het Wilhelmus', 'Nederland', $al, $dutch, 'St. Allegonde', 2);
    EnterRecord('God Save The Queen', 'United Kingdom', $al, $uk, 'Nelson', 3);
    EnterRecord('The Star Spangled Banner', 'United States of America', $al, $us, 'Columbus', 4);

    #does the user have the lyrics turned on?
    if (!DBDefs::USE_LYRICS) { return $album }

    #Inserting examples of SyncText; Additional side information about the song
    #enhanced with timestamps.
    my $synctext = $ly->InsertSyncText($track, 4, 'http://www.wilhelmus.nl', 'Coornhert');
    if ($synctext < 0)
    {
        print "Cannot insert SyncText.\n";
        $mb->Logout();
        exit 0;
    }
    while ((my $t,my $txt) = each %dutch_trackinfo) 
    {
        $ly->InsertSyncEvent($synctext, $t, $txt);
    }
    #the 'trackinfo' type of SyncText is translated into information about the 
    #National Anthem country.
    $synctext = $ly->InsertSyncText($track, 2, 'http://www.wilhelmus.nl', 'St. Allegonde');
    if ($synctext < 0)
    {
        print "Cannot insert SyncText.\n";
        $mb->Logout();
        exit 0;
    }
    while ((my $t,my $txt) = each %dutch_artistinfo) 
    {
        $ly->InsertSyncEvent($synctext, $t, $txt);
    }
    return $album;
}

$mb = new MusicBrainz(1);		#no cgi stuff
if (!$mb->Login(1))			#be quiet
{
    printf("Cannot log into musicbrainz database.\n");
    exit(0);
}
$al = Album->new($mb->{DBH});
$ar = Artist->new($mb->{DBH});
$tr = Track->new($mb->{DBH});
$ly = Lyrics->new($mb->{DBH});

my $album = add_examples();
print "added National Anthems album as number $album.\n";

$mb->Logout();
