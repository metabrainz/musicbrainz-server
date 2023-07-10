package MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias;
use MooseX::Role::Parameterized;
use namespace::autoclean;

parameter model => (
    isa => 'Str',
    required => 1
);

role {
    my $params = shift;

    method _format_output => sub { };

    around _format_output => sub {
        my ($orig, $self, $c, @entities) = @_;
        my $aliases = $c->model($params->model)->alias->find_by_entity_ids(
            map { $_->id } @entities
        );

        return map +{
            entity => $_,
            aliases => $aliases->{$_->id},
            current_language => $c->stash->{current_language} // 'en'
        }, $self->$orig($c, @entities);
    };
};

1;
