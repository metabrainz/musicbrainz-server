package MusicBrainz::Server::Edit::Historic::AddReleaseGroup;
use strict;
use warnings;

use MusicBrainz::Server::Edit::Historic::Utils 'upgrade_id';
use MusicBrainz::Server::Translation qw ( l ln );

use base 'MusicBrainz::Server::Edit::Historic::NGSMigration';

my $value_mapping = {
    type_id       => \&upgrade_id,
};

my $key_mapping = {
    Name       => 'name',
    Type       => 'type_id',
};

sub edit_name { l('Add release group') }
sub edit_type { 66 }
sub ngs_class { 'MusicBrainz::Server::Edit::ReleaseGroup::Create' }

sub related_entities {
    my $self = shift;
    return {
        artist => [ $self->data->{artist_credit}[0]{artist} ],
        release_group => [ $self->row_id ]
    }
}

sub do_upgrade
{
    my $self = shift;
    my $artist_id = $self->new_value->{ArtistId};
    return {
        %{ $self->upgrade_hash($self->new_value) },
        artist_credit => [
            {
                artist => $artist_id,
                name   => $self->artist_name($artist_id)
            }
        ]
    };
};

sub extra_parameters
{
    my $self = shift;
    return ( entity_id => $self->row_id );
};

sub upgrade_attribute {
    my ($self, $key, $value) = @_;

    my $attribute = $key_mapping->{$key} or return ();
    my $inflator  = $value_mapping->{$attribute};

    $value = defined $inflator
        ? $inflator->($value)
            : $value eq '' ? undef : $value;

    return ($attribute => $value);
};

sub upgrade_hash {
    my ($self, $hash) = @_;
    return {
        map {
            $self->upgrade_attribute($_, $hash->{$_});
        } keys %$hash
    };
};

1;
