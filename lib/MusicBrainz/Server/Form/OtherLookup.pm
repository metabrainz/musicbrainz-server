package MusicBrainz::Server::Form::OtherLookup;
use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'other-lookup' );

has_field 'catno' => (
    type => 'Text'
);

has_field 'barcode'  => (
    type => '+MusicBrainz::Server::Form::Field::Barcode',
    trim => { transform => sub {
        my $string = shift;
        # Remove all spaces for barcode search since we don't store them
        $string =~ s/\s+//g;
        return $string;
    } }
);

has_field 'url'  => (
    type => '+MusicBrainz::Server::Form::Field::URL',
);

has_field 'mbid'     => (
    type => '+MusicBrainz::Server::Form::Field::GID',
);

has_field 'isrc' => (
    type => '+MusicBrainz::Server::Form::Field::ISRC',
);

has_field 'iswc'     => (
    type => '+MusicBrainz::Server::Form::Field::ISWC',
);

has_field 'artist-ipi' => (
    type => '+MusicBrainz::Server::Form::Field::IPI',
);

has_field 'artist-isni' => (
    type => '+MusicBrainz::Server::Form::Field::ISNI',
);

has_field 'label-ipi' => (
    type => '+MusicBrainz::Server::Form::Field::IPI',
);

has_field 'label-isni' => (
    type => '+MusicBrainz::Server::Form::Field::ISNI',
);

has_field 'discid' => (
    type => '+MusicBrainz::Server::Form::Field::DiscID',
);

has_field 'freedbid' => (
    type => '+MusicBrainz::Server::Form::Field::FreeDBID',
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
