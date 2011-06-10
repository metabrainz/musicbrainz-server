package MusicBrainz::Server::EditSearch::Predicate::LinkedEntity;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use feature 'switch';

parameter type => (
    required => 1
);

role {
    my $params = shift;
    my $type = $params->type;

    has name => (
        is => 'ro',
        required => 1
    );

    method operator_cardinality_map => sub {
        return (
            '=' => 1,
            '!=' => 1
        );
    };

    method combine_with_query => sub {
        my ($self, $query) = @_;
        given($self->operator) {
            when('=') {
                $query->add_join('JOIN edit_artist ON edit_artist.edit = edit.id');
                $query->add_where([
                    'edit_artist.artist = ?', $self->sql_arguments
                ]);
            }
        };
    };
};

for my $type (qw( artist label recording release release_group work )){
    Moose::Meta::Class->create(
        'MusicBrainz::Server::EditSearch::Predicate::' . ucfirst($type),
        superclasses => [ 'Moose::Object' ],
        roles => [
            'MusicBrainz::Server::EditSearch::Predicate::LinkedEntity' => {
                type => $type
            },
            'MusicBrainz::Server::EditSearch::Predicate',
        ]
    )->name
}

1;
