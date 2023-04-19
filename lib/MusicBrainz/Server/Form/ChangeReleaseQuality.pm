package MusicBrainz::Server::Form::ChangeReleaseQuality;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Constants qw( :quality );
use MusicBrainz::Server::Translation qw( l );

extends 'MusicBrainz::Server::Form';
with 'MusicBrainz::Server::Form::Role::Edit';

sub edit_field_names { qw(quality) }

has '+name' => ( default => 'change-release-quality' );

has_field 'quality' => (
    type => 'Select',
    required => 1
);

sub options_quality
{
    return [
        $QUALITY_LOW => l('Low'),
        $QUALITY_NORMAL => l('Normal'),
        $QUALITY_HIGH => l('High'),
    ]
}

no Moose;
__PACKAGE__->meta->make_immutable;
