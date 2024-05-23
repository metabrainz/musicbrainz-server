package MusicBrainz::Server::Edit::Role::Art;
use MooseX::Role::Parameterized;
use namespace::autoclean;

role {
    requires qw( art_ids entity_ids art_archive_model );

    method alter_edit_pending => sub {
        my $self = shift;

        my $art_archive_model = $self->art_archive_model;
        my $entity_model_name = $art_archive_model->entity_model_name;
        my $art_model_name = $art_archive_model->art_model_name;
        my @art_ids = $self->art_ids;

        return {
            $entity_model_name => [ $self->entity_ids ],
            @art_ids ? ($art_model_name => \@art_ids) : (),
        };
    };
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2023 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
