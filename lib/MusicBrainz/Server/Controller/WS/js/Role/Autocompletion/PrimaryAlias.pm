package MusicBrainz::Server::Controller::WS::js::Role::Autocompletion::PrimaryAlias;
use MooseX::Role::Parameterized;

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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
