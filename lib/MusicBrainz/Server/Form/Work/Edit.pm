package MusicBrainz::Server::Form::Work::Edit;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Work';

has_field 'revision_id' => (
    type => 'Integer',
    required => 1
);

__PACKAGE__->meta->make_immutable;
1;
