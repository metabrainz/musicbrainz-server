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

    my @keys;
    my %values;
    my @conditions;

    if ($self->can('current_instance')) {
        push @keys, qw(id name comment);
        %values = map { $_ => $opts{$_} // $self->current_instance->$_ } @keys;
        push @conditions, 'id != ?';
    } else {
        push @keys, qw(name comment);
        %values = map { $_ => $opts{$_} } @keys;
    }

    if ($self->is_disambiguation_needed(%values)) {
        MusicBrainz::Server::Edit::Exceptions::NeedsDisambiguation->throw(
            'A disambiguation comment is required for this entity.'
        );
    } elsif (!non_empty($values{comment})) {
        # If a disambiguation comment isn't needed despite being empty,
        # then either there aren't any other entities with the given name
        # (in which case we don't need to further check for uniqueness),
        # or this is a place entity, and is already disambiguated by its
        # area information. Places have no unique index on (name, comment).
        # Neither do series, but we enforce it anyway.
        return;
    }

    push @conditions, map { "lower(musicbrainz_unaccent($_)) = lower(musicbrainz_unaccent(?))" } qw(name comment);
    my $conditions = join ' AND ', @conditions;

    my $duplicate_violation = $self->c->sql->select_single_value(
        "SELECT 1 FROM $table WHERE $conditions LIMIT 1", @values{@keys}
    );

    if ($duplicate_violation) {
        MusicBrainz::Server::Edit::Exceptions::DuplicateViolation->throw(
            'The given values duplicate an existing row.'
        );
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
