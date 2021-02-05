package MusicBrainz::Server::CoverArt::Provider;
use Moose;
use MooseX::ABC;

has 'name' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1
);

has 'link_type_name' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

requires 'lookup_cover_art';

sub fallback_meta { return undef; }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
