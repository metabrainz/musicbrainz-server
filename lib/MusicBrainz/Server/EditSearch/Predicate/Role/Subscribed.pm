package MusicBrainz::Server::EditSearch::Predicate::Role::Subscribed;
use 5.10.0;
use MooseX::Role::Parameterized;
use namespace::autoclean;

no if $] >= 5.018, warnings => 'experimental::smartmatch';

parameter type => (
    isa => 'Str',
    required => 1
);

parameter template_clause => (
    isa => 'Str',
    required => 1
);

parameter subscribed_column => (
    isa => 'Str',
    required => 1
);

role {
    my $params = shift;
    my $type = $params->type;
    my $template_clause = $params->template_clause;
    my $subscribed_column = $params->subscribed_column;

    has user => (
        is => 'ro',
        isa => 'MusicBrainz::Server::Authentication::User',
        required => 1
    );

    around operator_cardinality_map => sub {
        my ($orig, $self) = @_;
        return (
            $self->$orig,
            'subscribed' => undef,
            'not_subscribed' => undef
        );
    };

    around combine_with_query => sub {
        my ($orig, $self) = splice(@_, 0, 2);
        my ($query) = @_;

        given ($self->operator) {
            when ('subscribed') {
                my $subscribed_clause = "IN (
                    SELECT $subscribed_column
                      FROM editor_subscribe_$type
                     WHERE editor = ?
                )";

                $query->add_where([
                    $template_clause =~ s/ROLE_CLAUSE\(([^)]*)\)/$1 $subscribed_clause/r,
                    [ $self->user->id ]
                ]);
            }

            when ('not_subscribed') {
                my $subscribed_clause = "NOT IN (
                    SELECT $subscribed_column
                      FROM editor_subscribe_$type
                     WHERE editor = ?
                )";

                $query->add_where([
                    $template_clause =~ s/ROLE_CLAUSE\(([^)]*)\)/$1 $subscribed_clause/r,
                    [ $self->user->id ]
                ]);
            }

            default {
                $self->$orig(@_);
            }
        }
    };

    around valid => sub {
        my ($orig, $self) = @_;
        return ($self->operator eq 'subscribed' || $self->operator eq 'not_subscribed') || $self->$orig;
    };
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
