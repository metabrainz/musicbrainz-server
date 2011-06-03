package MusicBrainz::Server::Edit::Historic::RemoveArtistAlias;
use strict;
use warnings;

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';
use MusicBrainz::Server::Translation qw ( l ln );

sub ngs_class { 'MusicBrainz::Server::Edit::Artist::DeleteAlias' }
sub edit_type { 14 }
sub edit_name { l('Remove artist alias') }

sub related_entities {
    my $self = shift;
    return {
        artist => [ $self->artist_id ]
    }
}

sub do_upgrade {
    my $self = shift;
    return {
        entity    => {
            id => $self->artist_id,
            name => '[removed]',
        },
        alias_id  => $self->row_id,
        name      => $self->previous_value
    }
};

sub deserialize_previous_value { my $self = shift; return shift; }
sub deserialize_new_value      { my $self = shift; return shift; }

1;
