package MusicBrainz::Server::Form::Merge;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use namespace::autoclean;
use MusicBrainz::Server::Translation qw( l N_l );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw() }

has '+requires_edit_note' => ( default => 1 );

has '+name' => ( default => 'merge' );

has_field 'target' => (
    type => '+MusicBrainz::Server::Form::Field::Integer',
    required => 1,
    required_message => N_l('Please pick the entity you want the others merged into.'),
    localize_meth => sub { my ($self, @message) = @_; return l(@message); }
);

has_field 'merging' => (
    type => 'Repeatable',
    required => 1
);

has_field 'merging.contains' => (
    type => '+MusicBrainz::Server::Form::Field::Integer'
);

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
