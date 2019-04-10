package MusicBrainz::Server::Entity::URL::CDBaby;

use Moose;

extends 'MusicBrainz::Server::Entity::URL';
with 'MusicBrainz::Server::Entity::URL::Sidebar';

sub pretty_name { 'CD Baby' }
sub sidebar_name { 'CD Baby' }

override affiliate_url => sub {
    my $self = shift;
    my $url = super()->clone;
    $url->path($url->path . '/from/musicbrainz');
    return $url
};

sub url_is_scheme_independent { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
