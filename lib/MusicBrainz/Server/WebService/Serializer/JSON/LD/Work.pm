package MusicBrainz::Server::WebService::Serializer::JSON::LD::Work;
use Moose;

use MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils qw( list_or_single serialize_entity );

extends 'MusicBrainz::Server::WebService::Serializer::JSON::LD';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::GID';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Name';
with 'MusicBrainz::Server::WebService::Serializer::JSON::LD::Role::Aliases';

around serialize => sub {
    my ($orig, $self, $entity, $inc, $stash, $toplevel) = @_;
    my $ret = $self->$orig($entity, $inc, $stash, $toplevel);

    $ret->{'@type'} = 'MusicComposition';

    if ($entity->all_iswcs) {
       $ret->{'iswcCode'} = list_or_single(map { $_->iswc } $entity->all_iswcs);
    }

    my @languages = $entity->all_languages;
    if (@languages) {
        $ret->{inLanguage} =
            list_or_single(map { $_->language->bcp47 } @languages);
    }

    if ($toplevel) {
        my @recordings = @{ $entity->relationships_by_link_type_names('performance') };
        if (@recordings) {
            $ret->{recordedAs} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @recordings);
        }

        my @composers =  @{ $entity->relationships_by_link_type_names('composer', 'writer') };
        if (@composers) {
            $ret->{composer} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @composers);
        }

        my @lyricists =  @{ $entity->relationships_by_link_type_names('lyricist') };
        if (@lyricists) {
            $ret->{lyricist} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @lyricists);
        }

        my @publishers = @{ $entity->relationships_by_link_type_names('publishing') };
        if (@publishers) {
            $ret->{publisher} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @publishers);
        }

        my @subworks = grep { $_->direction == 1 } @{ $entity->relationships_by_link_type_names('parts') };
        if (@subworks) {
            $ret->{includedComposition} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @subworks);
        }

        my @arrangements = (
            (grep { $_->direction == 1 } @{ $entity->relationships_by_link_type_names('arrangement') }),
            (grep { $_->direction == 2 } @{ $entity->relationships_by_link_type_names('medley') }),
        );

        if (@arrangements) {
            $ret->{musicArrangement} = list_or_single(map { serialize_entity($_->target, $inc, $stash) } @arrangements);
        }
    }

    return $ret;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

