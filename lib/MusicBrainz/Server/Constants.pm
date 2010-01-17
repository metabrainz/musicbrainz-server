package MusicBrainz::Server::Constants;

use strict;
use warnings;

use base 'Exporter';

use Readonly;

sub _get
{
    my $re = shift;
    return [
        map { "\$$_" }
        grep { $_ =~ $re }
        keys %MusicBrainz::Server::Constants::
    ];
}

our %EXPORT_TAGS = (
    edit_type => _get(qr/^EDIT_/),
    expire_action => _get(qr/^EXPIRE_/),
    quality => _get(qr/^QUALITY_/),
    annotation => _get(qr/^EDIT_.*_ADD_ANNOTATION/),
);

our @EXPORT_OK = (
    qw( $DLABEL_ID $DARTIST_ID $VARTIST_ID $VARTIST_GID ),
    @{ _get(qr/^(EDIT|EXPIRE|QUALITY)_/) },
);

Readonly our $DLABEL_ID => 1;
Readonly our $DARTIST_ID => 2;

Readonly our $VARTIST_GID => '89ad4ac3-39f7-470e-963a-56509c546377';
Readonly our $VARTIST_ID  => 1;

Readonly our $EXPIRE_ACCEPT => 1;
Readonly our $EXPIRE_REJECT => 2;

Readonly our $QUALITY_UNKNOWN        => -1;
Readonly our $QUALITY_UNKNOWN_MAPPED => 1;
Readonly our $QUALITY_LOW            => 0;
Readonly our $QUALITY_NORMAL         => 1;
Readonly our $QUALITY_HIGH           => 2;

Readonly our $EDIT_ARTIST_CREATE => 1;
Readonly our $EDIT_ARTIST_EDIT => 2;
Readonly our $EDIT_ARTIST_DELETE => 3;
Readonly our $EDIT_ARTIST_MERGE => 4;
Readonly our $EDIT_ARTIST_ADD_ANNOTATION => 5;
Readonly our $EDIT_ARTIST_ADD_ALIAS => 6;
Readonly our $EDIT_ARTIST_DELETE_ALIAS => 7;
Readonly our $EDIT_ARTIST_EDIT_ALIAS => 8;

Readonly our $EDIT_LABEL_CREATE => 10;
Readonly our $EDIT_LABEL_EDIT => 11;
Readonly our $EDIT_LABEL_DELETE => 13;
Readonly our $EDIT_LABEL_MERGE => 14;
Readonly our $EDIT_LABEL_ADD_ANNOTATION => 15;
Readonly our $EDIT_LABEL_ADD_ALIAS => 16;
Readonly our $EDIT_LABEL_DELETE_ALIAS => 17;
Readonly our $EDIT_LABEL_EDIT_ALIAS => 18;

Readonly our $EDIT_RELEASEGROUP_CREATE => 20;
Readonly our $EDIT_RELEASEGROUP_DELETE => 23;
Readonly our $EDIT_RELEASEGROUP_MERGE => 24;
Readonly our $EDIT_RELEASEGROUP_EDIT => 21;
Readonly our $EDIT_RELEASEGROUP_ADD_ANNOTATION => 25;

Readonly our $EDIT_RELEASE_EDIT => 32;
Readonly our $EDIT_RELEASE_ADD_ANNOTATION => 35;
Readonly our $EDIT_RELEASE_DELETERELEASELABEL => 36;
Readonly our $EDIT_RELEASE_EDITRELEASELABEL => 37;

Readonly our $EDIT_WORK_EDIT => 42;
Readonly our $EDIT_WORK_ADD_ANNOTATION => 45;

Readonly our $EDIT_MEDIUM_CREATE => 51;
Readonly our $EDIT_MEDIUM_EDIT => 52;
Readonly our $EDIT_MEDIUM_DELETE => 53;

Readonly our $EDIT_TRACK_EDIT => 62;

Readonly our $EDIT_RECORDING_EDIT => 72;
Readonly our $EDIT_RECORDING_MERGE => 74;
Readonly our $EDIT_RECORDING_ADD_ANNOTATION => 75;

Readonly our $EDIT_TRACKLIST_CREATE => 81;
Readonly our $EDIT_TRACKLIST_ADDTRACK => 85;
Readonly our $EDIT_TRACKLIST_DELETETRACK => 86;

Readonly our $EDIT_RELATIONSHIP_CREATE => 90;
Readonly our $EDIT_RELATIONSHIP_EDIT => 91;
Readonly our $EDIT_RELATIONSHIP_DELETE => 92;

Readonly our $EDIT_WIKIDOC_CHANGE => 93;

Readonly our $EDIT_URL_EDIT => 101;

Readonly our $EDIT_PUID_DELETE => 113;

=head1 NAME

MusicBrainz::Server::Constant - constants used in the database that
have a specific meaning

=head1 DESCRIPTION

Various row IDs have a specific meaning in the database, such as representing
special entities like "Various Artists" and "Deleted Label"

=head1 CONSTANTS

=over 4

=item $DLABEL_ID

Row ID for the Deleted Label entity

=item $VARTIST_ID, $VARTIST_GID

Row ID and GID's for the special artist "Various Artists"

=item $DARTIST_ID

Row ID for the Deleted Artist entity

=back

=head1 COPYRIGHT

Copyright (C) 2009 Oliver Charles

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
