package MusicBrainz::Server::Form::RelationshipEditor::CreateWorks;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( language_options );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';

has '+name' => ( default => 'create-works' );

has_field 'works' => (
    type => 'Repeatable',
);

has_field 'works.type_id' => (
    type => 'Select',
);

has_field 'works.language_id' => (
    type => 'Select',
);

has_field 'works.name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'works.comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

sub edit_field_names          { qw() }
sub options_works_type_id     { shift->_select_all('WorkType') }
sub options_works_language_id { return language_options (shift->ctx); }

1;
