package MusicBrainz::Server::Edit::Role::IPI;
use 5.10.0;
use Moose::Role;

use Algorithm::Merge qw( diff3 );
use Clone 'clone';

before initialize => sub {
    my ($self, %opts) = @_;
    die "You must specify ipi_codes" unless defined $opts{ipi_codes};
};

around new_data => sub {
    my $orig = shift;
    my $self = shift;
    my $new = clone ($self->$orig (@_));

    # merge_changes only looks at keys in whatever is returned from
    # new_data(), make it skip ipi_codes so we can handle that
    # seperately.
    delete $new->{ipi_codes};
    return $new;
};

sub ipi_changes
{
   my ($self, $old, $current, $new) = @_;

   # FIXME: check if these lists need to be sorted.
   my @changes = diff3([ sort @$old ], [ sort @$current ], [ sort @$new ]);

   my @add;
   my @del;

    for my $change (@changes)
    {
        given ($change->[0])
        {
            when ('c') { # c - conflict (no two are the same)
                MusicBrainz::Server::Edit::Exceptions::FailedDependency
                    ->throw('IPI codes have changed since this edit was created, and now conflict ' .
                            'with changes made in this edit.');
            }
            when ('l') { # l - left is different
                # other edit made some changes we didn't make, ignore.
            }
            when ('o') { # o - original is different
                # other edit made changes we also made, ignore.
            }
            when ('r') { # r - right is different

                # we made changes, apply.
                if (defined $change->[3])
                {
                    push @add, $change->[3];
                }
                else
                {
                    push @del, $change->[1];
                }
            }
            when ('u') { # u - unchanged
                # no changes at all.
            }
        }
    }

   return { add => \@add, del => \@del };
}

around merge_changes => sub {
    my $orig = shift;
    my $self = shift;

    my $merged = $self->$orig (@_);

    $merged->{ipi_codes} = $self->ipi_changes (
        $self->data->{old}->{ipi_codes},
        $self->c->model($self->_edit_model)->ipi->find_by_entity_id($self->entity_id),
        $self->data->{new}->{ipi_codes})
        if $self->data->{new}->{ipi_codes};

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
