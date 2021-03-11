package MusicBrainz::Server::Entity::ArtistCredit;
use Moose;

use Scalar::Util qw( refaddr );
use MusicBrainz::Server::Entity::Types;
use MusicBrainz::Server::Entity::Util::JSON qw( to_json_array );
use aliased 'MusicBrainz::Server::Entity::Artist';
use aliased 'MusicBrainz::Server::Entity::ArtistCreditName';

use overload
    '==' => \&is_equal,
    '!=' => \&is_different,
    fallback => 1;

extends 'MusicBrainz::Server::Entity';
with 'MusicBrainz::Server::Entity::Role::Editable';

sub entity_type { 'artist_credit' }

has 'names' => (
    is => 'rw',
    isa => 'ArrayRef[ArtistCreditName]',
    default => sub { [] },
    traits => [ 'Array' ],
    handles => {
        add_name => 'push',
        clear_names => 'clear',
        all_names => 'elements',
        name_count => 'count',
    }
);

has 'artist_count' => (
    is => 'rw',
    isa => 'Int'
);

sub is_equal {
    my ($a, $b) = @_;

    return 0 unless
        (defined($a) && defined($b)) &&
        (ref($a) eq ref($b));

    # refaddr is needed since == is overloaded
    return 1 if refaddr($a) == refaddr($b);

    return 0 unless $a->name_count == $b->name_count;

    for my $i (0 .. ($a->name_count - 1)) {
        my ($an, $bn) = ($a->names->[$i], $b->names->[$i]);
        return 0 unless
            ($an->name eq $bn->name) &&
            (($an->join_phrase || '') eq ($bn->join_phrase || '')) &&
            (($an->artist_id || 0) == ($bn->artist_id || 0));
    }

    return 1;
}

sub is_different { !is_equal(@_) }

sub name
{
    my ($self) = @_;
    my $result = '';
    foreach my $name (@{$self->names}) {
        $result .= $name->name;
        $result .= $name->join_phrase if $name->join_phrase;
    }
    return $result;
}

sub change_artist_name
{
    my ($self, $artist, $new_name) = @_;

    my $ret = MusicBrainz::Server::Entity::ArtistCredit->new;
    for my $name ($self->all_names) {
        my %initname = (
            name      => $name->name,
            artist    => $name->artist,
            artist_id => $name->artist_id,
        );
        $initname{join_phrase} = $name->join_phrase if $name->join_phrase;
        if ($name->artist_id == $artist->id) {
            $initname{name} = $new_name;
        }
        $ret->add_name(ArtistCreditName->new(%initname));
    }
    return $ret;
}

sub from_artist
{
    my ($class, $artist) = @_;
    return $class->new(
        names => [
            ArtistCreditName->new(
                artist => $artist,
                artist_id => $artist->id,
                name      => $artist->name
            )
        ]
    );
}

sub from_array
{
    my ($class, @ac) = @_;

    my $ret = $class->new;

    @ac = @{ $ac[0] } if ref $ac[0];

    while (@ac)
    {
        my $artist = shift @ac;

        next unless $artist && defined $artist->{name};

        my %initname = ( name => $artist->{name} );

        $initname{join_phrase} = $artist->{join_phrase} if defined $artist->{join_phrase};
        if ($artist->{artist})
        {
            if (blessed ($artist->{artist}))
            {
                $initname{artist} = $artist->{artist};
            }
            else
            {
                $initname{artist_id} = $artist->{artist}->{id} if $artist->{artist}->{id};
                delete $artist->{artist}->{id} unless $artist->{artist}->{id};
                delete $artist->{artist}->{gid} unless $artist->{artist}->{gid};

                $initname{artist} = Artist->new( %{ $artist->{artist} } );
            }
        }

        $ret->add_name( ArtistCreditName->new(%initname) );
    }

    return $ret;
}

around TO_JSON => sub {
    my ($orig, $self) = @_;

    my $json = $self->$orig;
    $json->{names} = to_json_array($self->names);
    return $json;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2011 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
