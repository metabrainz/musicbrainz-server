use strict;
use warnings;
use Test::More tests => 7;
use_ok 'MusicBrainz::Server::Entity::WikiDoc';

use MusicBrainz::Server::Context;

my $c = MusicBrainz::Server::Context->new();

my $wikidoc = MusicBrainz::Server::Entity::WikiDoc->new(result   => 1, 
                                                        status   => 'Index not available',
                                                        body     => '<body/>', 
                                                        id       => 'About_MusicBrainz', 
                                                        title    => 'About MusicBrainz',
                                                        version  => 14508); 
is ( $wikidoc->result, 1 );
is ( $wikidoc->status, 'Index not available' );
is ( $wikidoc->body, '<body/>' );
is ( $wikidoc->id, 'About_MusicBrainz' );
is ( $wikidoc->title, 'About MusicBrainz' );
is ( $wikidoc->version, 14508 );
