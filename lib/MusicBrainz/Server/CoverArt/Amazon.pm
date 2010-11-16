package MusicBrainz::Server::CoverArt::Amazon;
use Moose;

extends 'MusicBrainz::Server::CoverArt';

has 'asin' => (
    isa => 'Str',
    is  => 'ro',
);

override 'cache_data' => sub
{
    my $self = shift;
    my $data = super();
    $data->{amazon_asin} = $self->asin;

    return $data;
};

__PACKAGE__->meta->make_immutable;
no Moose;
