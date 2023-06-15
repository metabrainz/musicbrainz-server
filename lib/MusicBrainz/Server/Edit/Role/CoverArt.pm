package MusicBrainz::Server::Edit::Role::CoverArt;
use MooseX::Role::Parameterized;
use namespace::autoclean;

role
{
    requires qw( cover_art_id release_ids);

    method 'alter_edit_pending' => sub {
        my $self = shift;

        return {
            Release => [ $self->release_ids ],
            Artwork => [ $self->cover_art_id ],
        };
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

