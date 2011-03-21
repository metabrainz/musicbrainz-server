package MusicBrainz::Server::Form::Merge::Release;
use HTML::FormHandler::Moose;
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form::Merge';

has_field 'merge_strategy' => (
    type => 'Select',
    required => 1
);

has_field 'mediums' => (
    type => 'Repeatable'
);

has_field 'mediums.id' => (
    type => 'Integer',
);

has_field 'mediums.position' => (
    type => 'Integer',
);

sub edit_field_names { return ('merge_strategy') }

sub options_merge_strategy {
    return [
        $MusicBrainz::Server::Data::Release::MERGE_APPEND, l('Append mediums to target release'),
        $MusicBrainz::Server::Data::Release::MERGE_MERGE, l('Merge mediums and recordings')
    ]
}

sub validate {
    my ($self) = @_;
    if($self->field('merge_strategy')->value == $MusicBrainz::Server::Data::Release::MERGE_APPEND) {
        my %positions;
        for my $field ($self->field('mediums')->fields) {
            my $pos_field = $field->field('position');
            $pos_field->add_error(l('Another medium is already in this position'))
                if exists $positions{$pos_field->value};

            $pos_field->add_error(l('Positions must be greater than 0'))
                if $pos_field->value < 1;

            $positions{ $pos_field->value }++;
        }
    }
}

1;
