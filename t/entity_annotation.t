#!/usr/bin/perl
use strict;
use warnings;

use Test::More;
use MusicBrainz::Server::Entity::Artist;

BEGIN { use_ok 'MusicBrainz::Server::Entity::Annotation' };

my $text = <<'TEXT';
This is a ''test'' annotation

This is more of the test annotation!

And '''even''' ''more''.
TEXT

my $annotation = MusicBrainz::Server::Entity::Annotation->new( text => $text );

like($annotation->summary, qr/This is a ''test'' annotation/);
unlike($annotation->summary, qr/This is more of the test annotation!/, 'summary shouldnt have second para');
unlike($annotation->summary, qr/And '''even''' ''more''./, 'summary shouldnt have third para');
unlike($annotation->summary, qr/\n/, 'summary shouldnt have line breaks');

unlike($annotation->summary, qr/This is more of the test annotation!/, 'summary shouldnt have second para');
unlike($annotation->summary, qr{And <strong>even</strong> <em>more</em>.}, 'summary shouldnt have third para');
unlike($annotation->summary, qr/\n/, 'summary shouldnt have line breaks');

my $artist = MusicBrainz::Server::Entity::Artist->new();
$annotation->parent( $artist );
ok( defined $annotation->parent );

done_testing;
