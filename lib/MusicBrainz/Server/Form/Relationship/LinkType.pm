package MusicBrainz::Server::Form::Relationship::LinkType;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation 'l';

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::LinkType' => {
    -alias    => { field_list => '_field_list' },
    -excludes => 'field_list'
};

has root => (
    is => 'ro',
    required => 1
);

has_field 'link_type_id' => (
    type => 'Select',
    required => 1,
    required_message => l('Link type is required')
);

has_field 'attrs' => (
    type => 'Compound'
);

sub options_link_type_id
{
    my ($self) = @_;

    my $root = $self->root;
    return [ $self->_build_options($root, 'l_short_link_phrase', 'ROOT', '&nbsp;') ];
}

sub field_list
{
    my ($self) = @_;

    return $self->_field_list('', '');
}

after validate => sub {
    my ($self) = @_;

    $self->validate_link_type($self->ctx,
        $self->field('link_type_id'), $self->field('attrs'));
};

sub edit_field_names { qw() }

1;
