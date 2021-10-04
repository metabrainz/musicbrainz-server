package MusicBrainz::Server::EditSearch::Predicate::Role::User;
use MooseX::Role::Parameterized;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( $EDITOR_MODBOT $STATUS_APPLIED );
use MusicBrainz::Server::Validation qw( is_database_row_id );

parameter template_clause => (
    isa => 'Str',
    required => 1
);

role {
    my $params = shift;
    my $template_clause = $params->template_clause;

    with 'MusicBrainz::Server::EditSearch::Predicate::Role::Subscribed' => {
        type => 'editor',
        template_clause => "$template_clause",
        subscribed_column => 'subscribed_editor'
    };

    has name => (
        is => 'ro',
        isa => 'Str'
    );

    method operator_cardinality_map => sub {
        return (
            '=' => 1,
            '!=' => 1,
            'me' => 0,
            'not_me' => 0,
            'limited' => 0,
            'not_edit_author' => 0,
        );
    };

    method combine_with_query => sub {
        my ($self, $query) = @_;

        my $sql = $template_clause =~ s/ROLE_CLAUSE\(([^)]*)\)/$1 = ?/r;

        if ($self->operator eq '!=' || $self->operator eq 'not_me') {
            $sql = 'NOT ' . $sql;
        }

        if ($self->operator eq 'me' || $self->operator eq 'not_me') {
            $query->add_where([ $sql, [ $self->user->id ] ]);
        } elsif ($self->operator eq 'limited') {
            # Please keep the logic in sync with Report::LimitedEditors and Entity::Editor
            $sql = q{
              edit.editor != ?
              AND (
                NOT EXISTS (
                  SELECT 1
                  FROM editor
                  WHERE id = edit.editor
                  AND deleted = TRUE
                )
              ) AND (
                  NOT EXISTS (
                    SELECT 1
                    FROM edit e2
                    WHERE e2.editor = edit.editor
                    AND e2.autoedit = 0
                    AND e2.status = ?
                    OFFSET 9
                  )
                OR
                  EXISTS (
                    SELECT 1
                    FROM editor
                    WHERE id = edit.editor
                    AND member_since > NOW() - INTERVAL '2 weeks'
                  )
              )
            };
            $query->add_where([ $sql, [ $EDITOR_MODBOT, $STATUS_APPLIED ] ]);
        } elsif ($self->operator eq 'not_edit_author') {
            $query->add_where([
                'EXISTS (
                    SELECT TRUE FROM edit_note
                        WHERE edit_note.edit = edit.id
                        AND edit_note.editor != edit.editor
                )',
                [ ]
            ]);
        } else {
            $query->add_where([ $sql, [ $self->arguments ] ]);
        }
    };

    method valid => sub {
        my ($self) = @_;

        my $cardinality = $self->operator_cardinality($self->operator) or return 1;
        my @args = $self->arguments;
        return scalar(@args) == 1 && is_database_row_id($args[0]);
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
