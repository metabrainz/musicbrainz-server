package MusicBrainz::Server::Edit::Role::EditArtistCredit;

use Data::Compare;
use Moose::Role;
use MusicBrainz::Server::Data::Utils qw(
    artist_credit_to_ref
);
use MusicBrainz::Server::Edit::Utils qw(
    clean_submitted_artist_credits
);

around initialize => sub {
    my ($orig, $self, %opts) = @_;

    my $entity = $opts{to_edit} or return;

    if (exists $opts{artist_credit}) {
        $self->c->model('ArtistCredit')->load($entity) unless $entity->artist_credit;

        my $old_artist_credit = artist_credit_to_ref($entity->artist_credit);
        my $new_artist_credit = clean_submitted_artist_credits($opts{artist_credit});

        $opts{artist_credit} = $new_artist_credit;
        delete $opts{artist_credit} if Compare($old_artist_credit, $new_artist_credit);
    }

    $self->$orig(%opts);
};

no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
