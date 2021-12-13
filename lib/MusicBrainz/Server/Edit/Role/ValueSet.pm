package MusicBrainz::Server::Edit::Role::ValueSet;
use 5.10.0;
use MooseX::Role::Parameterized;

use Clone qw( clone );
use List::AllUtils qw( nsort_by uniq );
use MusicBrainz::Server::Edit::Utils qw( merge_set );

parameter prop_name => ( isa => 'Str', required => 1 );
parameter get_current => ( isa => 'CodeRef', required => 1 );
parameter extract_value => ( isa => 'CodeRef', required => 1 );
parameter hash => ( isa => 'CodeRef', default => sub { sub { shift } } );

sub hashed {
    my ($f, @xs) = @_;
    my $i = 0;
    return map { $f->($_) => [$_, $i++] } @xs;
}

role {
    my $params = shift;
    my $prop_name = $params->prop_name;

    before initialize => sub {
        my ($self, %opts) = @_;
        die 'You must specify ' . $prop_name unless defined $opts{$prop_name};
    };

    around new_data => sub {
        my $orig = shift;
        my $self = shift;
        my $new = clone($self->$orig(@_));

        # merge_changes only looks at keys in whatever is returned from
        # new_data(), make it skip this property so we can handle that
        # seperately.
        delete $new->{$prop_name};
        return $new;
    };

    around merge_changes => sub {
        my $orig = shift;
        my $self = shift;

        my $merged = $self->$orig(@_);

        if ($self->data->{new}->{$prop_name}) {
            my $current = $params->get_current->($self);

            my %old = hashed(
                $params->hash,
                @{ $self->data->{old}->{$prop_name} }
            );

            my %current = hashed(
                $params->hash,
                map { $params->extract_value->($_) } @$current
            );

            my %new = hashed(
                $params->hash, @{ $self->data->{new}->{$prop_name} }
            );

            my @old_keys = nsort_by { $old{$_}->[1] } keys %old;
            my @current_keys = nsort_by { $current{$_}->[1] } keys %current;
            my @new_keys = nsort_by { $new{$_}->[1] } keys %new;

            my @keys = merge_set(
                \@old_keys,
                \@current_keys,
                \@new_keys,
            );

            my %all_values = (%old, %current, %new);
            my @all_keys = uniq @new_keys, @current_keys, @old_keys;
            my $index = 0;
            my %key_indices = map { $_ => ($index++) } @all_keys;

            $merged->{$prop_name} = [
                map { $all_values{$_}->[0] }
                nsort_by { $key_indices{$_} }
                @keys
            ];
        }

        return $merged;
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
