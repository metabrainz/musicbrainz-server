package MusicBrainz::Server::Edit::Historic::Artist;
use Moose;

extends 'MusicBrainz::Server::Edit::Historic::NGSMigration';

use MusicBrainz::Server::Edit::Historic::Utils
    'upgrade_date', 'upgrade_id';

my $value_mapping = {
    type_id    => \&upgrade_id,
    begin_date => \&upgrade_date,
    end_date   => \&upgrade_date,
};

my $key_mapping = {
    ArtistName => 'name',
    SortName   => 'sort_name',
    Resolution => 'comment',
    Type       => 'type_id',
    BeginDate  => 'begin_date',
    EndDate    => 'end_date',
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
