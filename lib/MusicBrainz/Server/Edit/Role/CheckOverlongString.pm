package MusicBrainz::Server::Edit::Role::CheckOverlongString;
use MooseX::Role::Parameterized;
use namespace::autoclean;
use MusicBrainz::Server::Validation qw(
    is_overlong_string
);

parameter get_string => ( isa => 'CodeRef', required => 1 );

role {
    my $params = shift;

    after initialize => sub {
        my ($self, %opts) = @_;

        MusicBrainz::Server::Edit::Exceptions::OverlongString->throw
            if is_overlong_string($params->get_string->($self->data));
    };
};

1;

=head1 NAME

MusicBrainz::Server::Edit::Role::CheckOverlongString - check overlong string

=head1 DESCRIPTION

This role can be applied to edit types in order to add checking of string
properties that can be of any length in the database schema (using unlimited
C<VARCHAR> or C<TEXT>) but still have to hold in one line of limited length
and to be indexable by Postgres. If any of these two conditions is unmet a
L<MusicBrainz::Server::Edit::Exceptions::OverlongString> exception is raised
causing the edit to not be created.

To use this role, for each string property to be checked,
you need to consume this role and provide the C<get_string> subroutine.

String properties in array (such as tracks) have to be checked separately.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2024 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
