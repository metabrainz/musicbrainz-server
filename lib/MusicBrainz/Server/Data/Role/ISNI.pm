package MusicBrainz::Server::Data::Role::ISNI;
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
        plural_value_type   => 'isni_codes',
        value_attribute     => 'isni',
        value_class         => type_to_model($entity_type) . 'ISNI',
        value_type          => 'isni',
    };

    method find_reused_isnis => sub {
        my ($self, @isnis) = @_;
        my $query = "SELECT 'artist' AS entity_type, artist_isni.isni, COUNT(*) AS count
                    FROM artist
                        JOIN artist_isni ON artist.id = artist_isni.artist
                    WHERE artist_isni.isni = any(?)
                    GROUP BY artist_isni.isni
                    UNION ALL
                    SELECT 'label' AS entity_type, label_isni.isni, COUNT(*) AS count
                    FROM label
                        JOIN label_isni ON label.id = label_isni.label
                    WHERE label_isni.isni = any(?)
                    GROUP BY label_isni.isni";
        my $results = $self->sql->select_list_of_hashes($query, \@isnis, \@isnis);
        my %reused_isnis;
        for my $result (@$results) {
            my $isni = $result->{isni};
            my $entity_count = $result->{count};
            my $entity_type = $result->{entity_type};
            $reused_isnis{$isni}{$entity_type} = $entity_count;
        }

        return \%reused_isnis;
    };

};

no Moose::Role;
1;

=head1 COPYRIGHT

Copyright (C) 2012-2017 MetaBrainz Foundation

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
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

