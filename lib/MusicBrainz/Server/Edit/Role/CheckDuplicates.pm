package MusicBrainz::Server::Edit::Role::CheckDuplicates;
use Moose::Role;

after initialize => sub {
    my ($self, %opts) = @_;

    my $table = $self->c->model($self->_create_model)->_table;

    # Allow only concurrent reads while we check for uniqueness.
    $self->c->sql->do("LOCK $table IN SHARE ROW EXCLUSIVE MODE");

    my @keys = qw(name comment);
    my $conditions = join ' AND ', map {
        "musicbrainz_unaccent(lower($_)) = musicbrainz_unaccent(lower(?))"
    } @keys;

    my $duplicate_violation = $self->c->sql->select_single_value(
        "SELECT 1 FROM $table WHERE $conditions LIMIT 1", map {$opts{$_}} @keys
    );

    if ($duplicate_violation) {
        MusicBrainz::Server::Edit::Exceptions::DuplicateViolation->throw(
            'The given values duplicate an existing row.'
        );
    }
};

1;
