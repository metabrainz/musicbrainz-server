package MusicBrainz::Server::Form::Instrument;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::Relationships';

has '+name' => ( default => 'edit-instrument' );

has_field 'type_id' => (
    type => 'Select',
);

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'description' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    not_nullable => 1,
);

sub edit_field_names { qw( name comment type_id description ) }

sub options_type_id { select_options_tree(shift->ctx, 'InstrumentType') }

1;
