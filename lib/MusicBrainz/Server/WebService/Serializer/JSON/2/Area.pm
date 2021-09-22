package MusicBrainz::Server::WebService::Serializer::JSON::2::Area;
use Moose;

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub serialize
{
    my ($self, $entity, $inc, $stash, $toplevel) = @_;
    my %body;

    $body{name} = $entity->name;
    $body{'sort-name'} = $entity->name;
    $body{disambiguation} = $entity->comment // '';
    $body{'iso-3166-1-codes'} = [$entity->iso_3166_1_codes] if $entity->iso_3166_1_codes;
    $body{'iso-3166-2-codes'} = [$entity->iso_3166_2_codes] if $entity->iso_3166_2_codes;
    $body{'iso-3166-3-codes'} = [$entity->iso_3166_3_codes] if $entity->iso_3166_3_codes;

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

