package MusicBrainz::Server::Form::ReleaseGroup;
use strict;
use warnings;

use HTML::FormHandler::Moose;
use MusicBrainz::Server::Form::Utils qw( select_options_tree );

extends 'MusicBrainz::Server::Form';

with 'MusicBrainz::Server::Form::Role::Edit';
with 'MusicBrainz::Server::Form::Role::Relationships';

# MBS-11428: When making changes to this module, please make sure to
# keep MusicBrainz::Server::Controller::WS::js::Edit in sync with it

has '+name' => ( default => 'edit-release-group' );

has_field 'primary_type_id' => (
    type => 'Select',
);

has_field 'name' => (
    type => '+MusicBrainz::Server::Form::Field::Text',
    required => 1,
);

has_field 'comment' => (
    type => '+MusicBrainz::Server::Form::Field::Comment',
);

has_field 'artist_credit' => (
    type => '+MusicBrainz::Server::Form::Field::ArtistCredit',
);

has_field 'secondary_type_ids' => (
    type => 'Select',
    multiple => 1,
);

sub options_primary_type_id { select_options_tree(shift->ctx, 'ReleaseGroupType') }
sub options_secondary_type_ids { select_options_tree(shift->ctx, 'ReleaseGroupSecondaryType') }

sub edit_field_names { qw( primary_type_id name comment artist_credit secondary_type_ids ) }

after BUILD => sub {
    my $self = shift;

    if (defined $self->init_object) {
        $self->field('secondary_type_ids')->value(
            [ map { $_->id } $self->init_object->all_secondary_types ],
        );
    }
};

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
