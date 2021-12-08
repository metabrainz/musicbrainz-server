package MusicBrainz::Server::WebService::Serializer::JSON::2::Work;
use Moose;
use MusicBrainz::Server::WebService::Serializer::JSON::2::Utils qw(
    serialize_type
);

extends 'MusicBrainz::Server::WebService::Serializer::JSON::2';

sub element { 'work'; }

sub serialize
{
    my ($self, $entity, $inc, $stash) = @_;
    my %body;

    $body{title} = $entity->name;
    $body{disambiguation} = $entity->comment // '';
    $body{iswcs} = [ map { $_->iswc } @{ $entity->iswcs } ];

    $body{attributes} = [
        map {
            my $attr_output = {
                value => $_->value,
                $_->value_gid ? ('value-id' => $_->value_gid) : (),
            };
            serialize_type($attr_output, $_, $inc, $stash, 1);
            $attr_output
        } $entity->all_attributes
    ];

    my @languages = map { $_->language->alpha_3_code } $entity->all_languages;
    $body{languages} = \@languages;
    # Pre-MBS-5452 property.
    $body{language} = @languages ?
        (@languages > 1 ? 'mul' : $languages[0]) : JSON::null;

    return \%body;
};

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011,2012 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut

