package MusicBrainz::Server::Model::Tag;

use strict;
use warnings;

use base 'Catalyst::Model';

use Carp;
use List::Util qw(min max sum);
use MusicBrainz::Server::Tag;
use MusicBrainz::Server::Adapter::Tag qw(PrepareForTagCloud);

sub ACCEPT_CONTEXT
{
    my ($self, $c) = @_;

    bless { _dbh => $c->mb->{DBH} }, ref $self;
}

=head2 top_tags

Returns a sorted array of the top tags for an entity (or the empty list if no
tags have been added).

=cut

sub top_tags
{
    my ($self, $entity, $amount) = @_;

    $amount ||= 5;

    my $t        = MusicBrainz::Server::Tag->new($self->{_dbh});
    my $tag_hash = $t->GetTagHashForEntity($entity->entity_type, $entity->id,
                                           $amount + 1);

    [ sort { $tag_hash->{$b} <=> $tag_hash->{$a}; } keys %{$tag_hash} ];
}

sub generate_tag_cloud
{
    my ($self, $entity, $min_size, $max_size, $bold_threshold) = @_;

    my $t    = MusicBrainz::Server::Tag->new($self->{_dbh});
    my $tags = $t->GetTagHashForEntity($entity->entity_type, $entity->id, 30);

    my @counts = sort { $a <=> $b} values %$tags;
    my $ntags  = scalar @counts;
    
    # No tags, nothing to do!
    return if $ntags == 0;

    # Bizzare tag cloud algorithm...
    my $min = min @counts;
    my $max = max @counts;
    my $sum = sum @counts;
    my $avg = $sum / $ntags;
    my $med = $ntags % 2
        ? $counts[(($ntags + 1) / 2) - 1]
        : ($counts[($ntags / 2) - 1] + $counts[$ntags / 2]) / 2;
    
    $avg /= $max;
    $med /= $max;

    $min_size       ||= 12;
    $max_size       ||= 30;
    $bold_threshold ||= 0.25;

    $max_size =
        $min_size + ($max_size - $min_size) * log(1 + min(1, ($max > 0 ? $max - 1 : 0) / 20) * 1.718);

    $max -= $min;
    if ($max == 0)
    {
        $max = $min;
        $min = 0;
    }

	my $power = 1 + ($avg > $med ? -(($avg - $med) ** 0.6) : ($med - $avg) ** 0.6);

    my @ret;

	my $size_delta = $max_size - $min_size;
    foreach my $tag (sort keys %$tags)
    {
		my $value = (($tags->{$tag} - $min) / $max) ** $power;
        push @ret, {
            size => int($min_size + $value * $size_delta + 0.5),
            bold => $value > $bold_threshold,
            tag => $tag,
        };
    }

    return \@ret;
}

1;
