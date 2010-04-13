#!/usr/bin/perl
use strict;
use warnings;
use LWP::UserAgent;
use HTTP::Response;
use Test::Moose;
use MusicBrainz::Server::Context;
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;
use Encode qw( encode );
use File::Temp qw(tempfile);
use Test::More;
use XML::LibXML;

# These relation inc arguments will be attached to each URL if it contains the string &RELS&
my $rels = '+artist-rels+release-group-rels+release-rels+recording-rels+work-rels+label-rels+url-rels';

my $test_data =
[
   {
     url => '/ws/2/artist/5441c29d-3602-4898-b1a1-b77fa23b8e50/?inc=sa-album+sa-official+aliases+labels+discs+tags&RELS&',
     resource => 'artist'
   },
   {
     url => '/ws/2/release-group/234c079d-374e-4436-9448-da92dedef3ce/?inc=artists+releases+tags&RELS&',
     resource => 'release-group'
   },
   {
     url => '/ws/2/release/f205627f-b70a-409d-adbe-66289b614e80?inc=artists+discs+labels+isrcs+recordings+release-groups&RELS&',
     resource => 'release'
   },
   {
     url => '/ws/2/recording/54b9d183-7dab-42ba-94a3-7388a66604b8?inc=artists+isrcs+releases+tags&RELS&',
     resource => 'recording'
   },
   {
     url => '/ws/2/label/46f0f4cd-8aab-4b33-b698-f459faf64190?inc=aliases+tags&RELS&',
     resource => 'label'
   },
   {
     url => '/ws/2/work/745c079d-374e-4436-9448-da92dedef3ce?inc=artists+tags&RELS&',
     resource => 'work'
   },
   {
     url => '/ws/2/puid/b9c8f51f-cc9a-48fa-a415-4c91fcca80f0?inc=artists+releases+release-groups',
     resource => 'puid'
   },
   {
     url => '/ws/2/isrc/DEE250800230?inc=artists+releases+release-groups',
     resource => 'isrc'
   },
   {
     url => '/ws/2/disc/tLGBAiCflG8ZI6lFcOt87vXjEcI-?inc=artists+release-groups',
     resource => 'disc'
   },
];


my $rng_file = $ENV{'MMDFILE'} || "../mmd-schema/schema/musicbrainz_mmd-2.0.rng";
my $rngschema;
eval
{
    $rngschema = XML::LibXML::RelaxNG->new( location => $rng_file );
};
if ($@)
{
    print STDERR "Cannot find or parse RNG schema. Set evn var MMDFILE to point to the mmd-schema file "  .
                 " or check out the mmd-schema in parallel to the mb_server source. No schema validation will happen.\n";
    undef $rngschema;
}

my $c = MusicBrainz::Server::Test->create_test_context();
MusicBrainz::Server::Test->prepare_test_server($c);
MusicBrainz::Server::Test->prepare_test_database($c);

foreach my $test (@{$test_data})
{
    my $url = $test->{url};
    $url =~ s/&RELS&/$rels/;
    my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');
    $mech->get_ok($url, $test->{resource} . " webservice test");
    xml_ok($mech->content);

    if ($rngschema)
    {
        my $doc = XML::LibXML->new()->parse_string($mech->content);
        eval
        {
            $rngschema->validate( $doc );
        };
        is( $@, '');
    }
}

done_testing;

1;
