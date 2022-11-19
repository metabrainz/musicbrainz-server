package MusicBrainz::Server::Form::Admin::StatisticsEvent;
use strict;
use warnings;

use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::CSRFToken';

has '+name' => ( default => 'edit-statistics-event' );

has_field 'date' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'title' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'description' => (
    type => 'TextArea',
    required => 0,
    not_nullable => 1,
);

has_field 'link' => (
    type => '+MusicBrainz::Server::Form::Field::URL',
    required => 0,
    not_nullable => 1,
);

sub edit_field_names { qw( date title description link ) }

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2021 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
