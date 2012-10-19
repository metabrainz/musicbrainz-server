package MusicBrainz::Server::Edit::Role::ISNI;
use 5.10.0;
use Moose::Role;

use Algorithm::Merge qw( diff3 );
use Clone 'clone';

before initialize => sub {
    my ($self, %opts) = @_;
    die "You must specify isni_codes" unless defined $opts{isni_codes};
};

around new_data => sub {
    my $orig = shift;
    my $self = shift;
    my $new = clone ($self->$orig (@_));

    # merge_changes only looks at keys in whatever is returned from
    # new_data(), make it skip isni_codes so we can handle that
    # seperately.
    delete $new->{isni_codes};
    return $new;
};

sub isni_changes
{
    my ($self, $old, $current, $new) = @_;

    my $old_set     = Set::Scalar->new(@$old);
    my $current_set = Set::Scalar->new(@$current);
    my $new_set     = Set::Scalar->new(@$new);

    # An ISNI can be present in or absent from each set.
    # There are these seven possible cases:
    #   OCN: never changed
    #   O-N: removed by previous edit, we shouldn't undo that (*)
    #   O--: has already been deleted by previous edit
    #   -CN: has already been added by previous edit
    #   -C-: has been added by previous edit (*)
    #   --N: add completely new ISN
    #   OC-: delete ISNIs that weren't touched by previous edit
    # (*) marks the cases where the intended result diverges from N.

    my $result_set = ($new_set
        - ($old_set - $current_set))  # leave out those removed in the meantime
        + ($current_set - $old_set);  # ... and include those added

    return [ $result_set->members ];
}

around merge_changes => sub {
    my $orig = shift;
    my $self = shift;

    my $merged = $self->$orig (@_);

    my $current_isnis = $self->c->model($self->_edit_model)
        ->isni->find_by_entity_id($self->entity_id);

    $merged->{isni_codes} = $self->isni_changes (
        $self->data->{old}->{isni_codes},
        [ map { $_->isni } @$current_isnis ],
        $self->data->{new}->{isni_codes})
        if $self->data->{new}->{isni_codes};

    return $merged;
};

no Moose;
1;

=head1 LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

=cut
