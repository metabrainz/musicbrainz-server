package MusicBrainz::Server::Data::Role::Subscription;
use MooseX::Role::Parameterized;
use namespace::autoclean;

use MusicBrainz::Server::Data::Subscription;

parameter 'table' => (
    isa => 'Str',
    required => 1,
);

parameter 'column' => (
    isa => 'Str',
    required => 1,
);

parameter 'active_class' => (
    isa => 'Str',
    required => 1
);

parameter 'deleted_class' => (
    isa => 'Str',
);

role
{
    my $params = shift;

    requires 'c';

    has 'subscription' => (
        is => 'ro',
        lazy => 1,
        builder => '_build_subscription_data',
    );

    method '_build_subscription_data' => sub
    {
        my $self = shift;
        return MusicBrainz::Server::Data::Subscription->new(
            c => $self->c,
            table => $params->table,
            column => $params->column,
            active_class => $params->active_class,
            deleted_class => $params->deleted_class
        );
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

