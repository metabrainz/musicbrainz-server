package MusicBrainz::Server::Form::Collection;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );

extends 'MusicBrainz::Server::Form';

has '+name' => ( default => 'edit-list' );

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'type_id' => (
    type => 'Select',
);

has_field 'description' => (
    type => 'TextArea',
    required => 0,
    not_nullable => 1,
);

has_field 'public' => (
    type => 'Boolean',
);

sub edit_field_names
{
    return qw( name description public type_id );
}

sub options_type_id { select_options_tree(shift->ctx, 'CollectionType') }

1;
