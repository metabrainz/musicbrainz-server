package MusicBrainz::Server::Form::ReleaseEditor::Tracklist;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form::Step';

has_field 'mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'mediums.id' => ( type => 'Integer' );
has_field 'mediums.name' => ( type => 'Text' );
has_field 'mediums.deleted' => ( type => 'Checkbox' );
has_field 'mediums.format_id' => ( type => 'Select' );
has_field 'mediums.position' => ( type => 'Integer' );
has_field 'mediums.tracklist_id' => ( type => 'Integer' );
has_field 'mediums.edits' => ( type => 'Text' );

sub options_mediums_format_id { shift->_select_all('MediumFormat') }

sub validate {
    my $self = shift;

    for my $medium ($self->field('mediums')->fields)
    {
        next if $medium->field('tracklist_id')->value || $medium->field('edits')->value;

        $medium->add_error (l('A tracklist is required'));
    }
};

1;
