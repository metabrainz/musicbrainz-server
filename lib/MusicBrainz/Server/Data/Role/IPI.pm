package MusicBrainz::Server::Data::Role::IPI;
use MooseX::Role::Parameterized;
use MusicBrainz::Server::Data::Utils qw( type_to_model );

parameter 'type' => (
    isa => 'Str',
    required => 1,
);

role
{
    my $params = shift;

    my $entity_type = $params->type;

    with 'MusicBrainz::Server::Data::Role::ValueSet' => {
        entity_type         => $entity_type,
        plural_value_type   => 'ipi_codes',
        value_attribute     => 'ipi',
        value_class         => type_to_model($entity_type) . 'IPI',
        value_type          => 'ipi',
    };

    method find_reused_ipis => sub {
        my ($self, @ipis) = @_;

        my $query = q{SELECT 'artist' AS entity_type, artist_ipi.ipi, COUNT(*) AS count
                    FROM artist
                        JOIN artist_ipi ON artist.id = artist_ipi.artist
                    WHERE artist_ipi.ipi = any(?)
                    GROUP BY artist_ipi.ipi
                    UNION ALL
                    SELECT 'label' AS entity_type, label_ipi.ipi, COUNT(*) AS count
                    FROM label
                        JOIN label_ipi ON label.id = label_ipi.label
                    WHERE label_ipi.ipi = any(?)
                    GROUP BY label_ipi.ipi};
        my $results = $self->sql->select_list_of_hashes($query, \@ipis, \@ipis);

        my %reused_ipis;
        for my $result (@$results) {
            my $ipi = $result->{ipi};
            my $entity_count = $result->{count};
            my $entity_type = $result->{entity_type};
            $reused_ipis{$ipi}{$entity_type} = $entity_count;
        }

        return \%reused_ipis;
    };

};

no Moose::Role;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

