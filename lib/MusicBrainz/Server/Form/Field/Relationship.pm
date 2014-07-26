package MusicBrainz::Server::Form::Field::Relationship;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l N_l );
extends 'HTML::FormHandler::Field::Compound';

has_field 'relationship_id' => (
    type => 'Integer',
    required_when => { removed => 1 },
);

has_field 'link_type_id' => (
    type => 'Integer',
);

has_field 'text' => (
    type => '+MusicBrainz::Server::Form::Field::URL',
);

has_field 'target' => (
    type => '+MusicBrainz::Server::Form::Field::GID',
);

has_field 'attributes' => (
    type => 'Repeatable',
);

has_field 'attributes.type' => (
    type => 'Compound',
);

has_field 'attributes.type.gid' => (
    type => '+MusicBrainz::Server::Form::Field::GID',
);

has_field 'attributes.credited_as' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'attributes.text_value' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
);

has_field 'link_order' => (
    type => 'Integer',
);

has_field 'period' => (
    type => '+MusicBrainz::Server::Form::Field::DatePeriod',
);

has_field 'backward' => (
    type => 'Boolean',
    default => 0,
);

has_field 'removed' => (
    type => 'Boolean',
    default => 0,
);

sub is_empty {
    my ($self) = @_;

    my $value = $self->value;
    return 1 unless (
        $value->{link_type_id} ||
        $value->{text} ||
        $value->{target} ||
        $value->{relationship_id}
    );
    return 0;
}

1;
