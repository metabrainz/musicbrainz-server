#!/usr/bin/perl -w

use strict;

use FindBin;
use lib "$FindBin::Bin/../cgi-bin";



# login
require MusicBrainz;
my $mbraw = MusicBrainz->new();
$mbraw->Login(db => 'RAWDATA');
my $mbro = MusicBrainz->new();
$mbro->Login();


# set up SQL identifiers
my $sqlraw = Sql->new($mbraw->{DBH});
my $sqlro = Sql->new($mbro->{DBH});


# select all collections that shall receive notifications by e-mail
my $collections = $sqlraw->SelectSingleColumnArray('SELECT id FROM collection_info WHERE emailnotifications = TRUE');


exit 1;


sub sendMail($collectionId, @releasesIds)
{
	
}