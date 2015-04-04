package MusicBrainz::Server::Edit::Role::CheckDuplicates;
use Moose::Role;
use MusicBrainz::Server::Data::Utils qw( non_empty );

requires '_is_disambiguation_needed';

sub is_disambiguation_needed {
    my ($self, %opts) = @_;

    return 0 if non_empty($opts{comment});
    return $self->_is_disambiguation_needed(%opts);
}

after initialize => sub {
    my ($self, %opts) = @_;

    my $model = $self->can('_create_model') ? $self->_create_model : $self->_edit_model;
    my $table = $self->c->model($model)->_table;

    # Allow only concurrent reads while we check for uniqueness.
    $self->c->sql->do("LOCK $table IN SHARE ROW EXCLUSIVE MODE");

    if ($self->is_disambiguation_needed(%opts)) {
        MusicBrainz::Server::Edit::Exceptions::NeedsDisambiguation->throw(
            'A disambiguation comment is required for this entity.'
        );
    }

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
