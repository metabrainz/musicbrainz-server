package MusicBrainz::Server::Form::ReleaseEditor::Preview;
use HTML::FormHandler::Moose;

extends 'MusicBrainz::Server::Form::Step';

has_field 'mediums' => ( type => 'Repeatable', num_when_empty => 0 );
has_field 'mediums.associations' => ( type => 'Repeatable',  num_when_empty => 0 );
has_field 'mediums.associations.matches' => ( type => 'Select' );
has_field 'mediums.associations.id' => ( type => 'Integer' );
has_field 'mediums.associations.addnew' => (
    type => 'Select',
    options => [  # FIXME: i18n.
        { value => 1, label => 'Add new recording', },
        { value => 2, label => 'Use recording: ', },
    ],
);

sub options_mediums_associations_matches
{
    my $self = shift;
    my $field = shift;

    my $matches = $field->form->params->{mediums}->
        [$field->parent->parent->parent->name]->{associations}->
        [$field->parent->name]->{matches};

    return map { { label => $_->name, value => $_->id, } } @$matches;
}

1;
