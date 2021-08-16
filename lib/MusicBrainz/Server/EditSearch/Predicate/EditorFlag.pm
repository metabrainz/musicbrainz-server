package MusicBrainz::Server::EditSearch::Predicate::EditorFlag;
use Moose;
use MusicBrainz::Server::Constants qw( $UNTRUSTED_FLAG );
use namespace::autoclean;

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';

has user => (
    isa => 'Editor',
    is => 'ro',
    required => 1,
);

sub valid_flags {
    my ($self) = @_;

    my @flags = @{ $self->sql_arguments->[0] };
    unless ($self->user->is_account_admin) {
        # This flag is only intended to be visible to admins.
        @flags = grep { $_ != $UNTRUSTED_FLAG } @flags;
    }
    return @flags;
}

sub valid {
    my ($self) = @_;
    return $self->valid_flags > 0;
}

sub combine_with_query {
    my ($self, $query) = @_;

    my @flags = $self->valid_flags;
    return unless @flags;

    $query->add_where([
        'EXISTS (SELECT 1 FROM editor WHERE id = edit.editor AND privs & (' . join(' | ', map { '?::integer' } @flags) . ') ' .
             ($self->operator eq '='  ? '!=' :
             $self->operator eq '!=' ? '=' : die 'Shouldnt get here')
         . ' 0)',
        \@flags,
    ]);
}

1;
