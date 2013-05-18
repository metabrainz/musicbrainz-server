package MusicBrainz::Server::Edit::Role::ValueSet;
use 5.10.0;
use MooseX::Role::Parameterized;

use Clone 'clone';
use MusicBrainz::Server::Edit::Utils qw( merge_set );

parameter prop_name => ( isa => 'Str', required => 1 );
parameter get_current => ( isa => 'CodeRef', required => 1 );
parameter extract_value => ( isa => 'CodeRef', required => 1 );

role {
    my $params = shift;
    my $prop_name = $params->prop_name;

    before initialize => sub {
        my ($self, %opts) = @_;
        die "You must specify " . $prop_name unless defined $opts{$prop_name};
    };

    around new_data => sub {
        my $orig = shift;
        my $self = shift;
        my $new = clone ($self->$orig (@_));

        # merge_changes only looks at keys in whatever is returned from
        # new_data(), make it skip this property so we can handle that
        # seperately.
        delete $new->{$prop_name};
        return $new;
    };

    around merge_changes => sub {
        my $orig = shift;
        my $self = shift;

        my $merged = $self->$orig (@_);

        my $current = $params->get_current->($self);

        $merged->{$prop_name} = merge_set(
            $self->data->{old}->{$prop_name},
            [ map { $params->extract_value->($_) } @$current ],
            $self->data->{new}->{$prop_name})
            if $self->data->{new}->{$prop_name};

        return $merged;
    };
};

1;

=head1 LICENSE

Copyright (C) 2013 MetaBrainz Foundation

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
