package MusicBrainz::Server::Entity::Role::Type;
use MooseX::Role::Parameterized;

parameter model => (
    isa => 'Str',
    required => 1,
);

role {
    my $params = shift;

    has type_id => (
        is => 'rw',
        isa => 'Int',
    );

    has type_gid => (
        is => 'rw',
        isa => 'Str',
    );

    has type => (
        is => 'rw',
        isa => $params->model,
    );

    sub type_name {
        my ($self) = @_;
        return $self->type ? $self->type->name : undef;
    }

    sub l_type_name {
        my ($self) = @_;
        return $self->type ? $self->type->l_name : undef;
    }

    around TO_JSON => sub {
        my ($orig, $self) = @_;

        return {
            %{ $self->$orig },
            typeID => $self->type_id,
            $self->type ? (typeName => $self->type->name) : (),
        };
    };
};

1;

=head1 COPYRIGHT

This file is part of MusicBrainz, the open internet music database.
Copyright (C) 2015 MetaBrainz Foundation
Licensed under the GPL version 2, or (at your option) any later version:
http://www.gnu.org/licenses/gpl-2.0.txt

=cut
