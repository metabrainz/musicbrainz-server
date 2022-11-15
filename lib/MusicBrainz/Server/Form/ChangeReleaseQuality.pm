package MusicBrainz::Server::Form::ChangeReleaseQuality;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Constants qw( :quality );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw(quality) }

has '+name' => ( default => 'change-release-quality' );

has_field 'quality' => (
    type => 'Select',
    required => 1
);

sub options_quality
{
    return [
        $QUALITY_LOW => 'Low',
        $QUALITY_NORMAL => 'Normal',
        $QUALITY_HIGH => 'High'
    ]
}

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
