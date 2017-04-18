package MusicBrainz::Server::Controller::WS::2::Role::Lookup;

use aliased 'MusicBrainz::Server::WebService::WebServiceStash';
use Moose::Util qw( apply_all_roles );
use MooseX::Role::Parameterized;
use MusicBrainz::Server::Data::Utils qw( model_to_type );

parameter model => (
    isa => 'Str',
    required => 1,
);

sub allow_multiple {
    my ($c) = @_;

    return $c->stash->{serializer}->fmt eq 'json';
}

role {
    my ($params, %extra) = @_;

    my $entity_type = model_to_type($params->model);
    my $toplevel_routine = $entity_type . '_toplevel';
    my $consumer = $extra{consumer};

    apply_all_roles(
        $consumer,
        'MusicBrainz::Server::Controller::Role::Load' => {
            model => $params->model,
            allow_integer_ids => 0,
            allow_multiple => \&allow_multiple,
        },
    );

    $consumer->name->config(action => {
        lookup => { Chained => 'load', PathPart => '' },
    });

    method lookup => sub {
        my ($self, $c) = @_;

        my $entity = $c->stash->{entity} or return;

        my $stash = WebServiceStash->new;

        my $serialization_routine = $entity_type;

        if (ref $entity eq 'ARRAY') {
            if ($self->can($toplevel_routine)) {
                $self->$toplevel_routine($c, $stash, $entity);
            }
            $entity = {items => $entity};
            $serialization_routine .= '_list';

        } elsif ($self->can($toplevel_routine)) {
            $self->$toplevel_routine($c, $stash, [$entity]);
        }

        $c->res->content_type(
            $c->stash->{serializer}->mime_type . '; charset=utf-8');
        $c->res->body($c->stash->{serializer}->serialize(
            $serialization_routine, $entity, $c->stash->{inc}, $stash));
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
