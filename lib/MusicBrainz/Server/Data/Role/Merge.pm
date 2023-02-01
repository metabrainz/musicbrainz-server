package MusicBrainz::Server::Data::Role::Merge;
use Moose::Role;

use Carp qw( croak );

requires '_merge_impl';

# XXX HACK
# This is a bit ugly as Data::Entity already provides sub merge { }
# and roles will not overwrite methods that already exist (it assumes
# the method has already been provided). Here we ensure sub merge { }
# exists in some form, and then immeidately replace all the behaviour
# with an 'around' modifier.
#
# This will be solved by MBS-2618

sub merge { }
around merge => sub {
    my ($orig, $self, $new_id, @old_ids) = @_;

    croak('new_id must be a positive integer')
        unless $new_id && $new_id > 0;

    my @to_merge = grep { $_ != $new_id } @old_ids
        or croak('Attempted to merge empty list of IDs into target');

    @to_merge == @old_ids
        or croak('Attempted to merge an object into itself');

    $self->_merge_impl($new_id, @to_merge);
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
