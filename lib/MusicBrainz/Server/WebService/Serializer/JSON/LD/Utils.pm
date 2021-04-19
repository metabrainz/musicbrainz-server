package MusicBrainz::Server::WebService::Serializer::JSON::LD::Utils;

use warnings;
use strict;

use base 'Exporter';
use Class::Load qw( load_class );
use aliased 'MusicBrainz::Server::Entity::PartialDate';

our @EXPORT_OK = qw(
    serializer
    serialize_entity
    list_or_single
    artwork
    format_date
);

#        ArtistCredit
#        CDStub
#        CDTOC
#        Collection
#        Instrument
#        Medium
#        Relationship
#        Series
#        URL

my %serializers =
    map {
        my $class = "MusicBrainz::Server::WebService::Serializer::JSON::LD::$_";
        load_class($class);
        "MusicBrainz::Server::Entity::$_" => $class->new
    } qw(
        Area
        Artist
        Label
        Place
        Recording
        Release
        ReleaseGroup
        Work
    );

sub serializer
{
    my $entity = shift;

    for my $class (keys %serializers) {
        if ($entity->isa($class)) {
            return $serializers{$class};
        }
    }

    die 'No serializer found for ' . ref($entity);
}

sub serialize_entity
{
    return unless defined $_[0];
    return serializer($_[0])->serialize(@_);
}

=head2 list_or_single

Given a list, return the first element if there's only one,
otherwise return an arrayref. To be used for sets which are
potentially only one element.

=cut

sub list_or_single {
    return scalar @_ == 1 ? $_[0] : \@_;
}

=head2 artwork

Provides serialization given an Entity::Artwork. Used by both
Release and ReleaseGroup, hence being here.

=cut

sub artwork {
    my ($artwork) = @_;
    return { '@type' => 'ImageObject',
             contentUrl => $artwork->image,
             encodingFormat => $artwork->suffix,
             ($artwork->is_front ? (representativeOfPage => 'True') : ()),
             thumbnail => [
                 {'@type' => 'ImageObject', contentUrl => $artwork->small_thumbnail, encodingFormat => 'jpg'},
                 {'@type' => 'ImageObject', contentUrl => $artwork->large_thumbnail, encodingFormat => 'jpg'},
                 {'@type' => 'ImageObject', contentUrl => $artwork->huge_thumbnail, encodingFormat => 'jpg'}
             ]
           };
}

=head2 format_date

Given an Entity::PartialDate object, returns a formatted string
of the first defined run of numbers.

=cut

sub format_date {
    my ($date) = @_;

    my @run = $date->defined_run if $date;
    return PartialDate->new(year => $run[0], month => $run[1], day => $run[2])->format if @run;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
