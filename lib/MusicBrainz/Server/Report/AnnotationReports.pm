use MusicBrainz::Server::Constants qw( %ENTITIES entities_with );

for my $type (grep { $_ ne 'instrument' && $_ ne 'area' } entities_with('annotations')) {
    my $model = $ENTITIES{$type}{model};
    my $plural = $type eq 'series' ? $model : "${model}s";
    my $has_subs = $ENTITIES{$type}{report_filter};
    my $subs_section = '';

    if ($has_subs) {
        $subs_section = <<EOF;
     'MusicBrainz::Server::Report::FilterForEditor::${model}ID',
EOF
    }

    eval <<EOF;
package MusicBrainz::Server::Report::Annotations$plural;
use Moose;

with 'MusicBrainz::Server::Report::${model}Report',
$subs_section
     'MusicBrainz::Server::Report::AnnotationReport';

sub entity_type { '$type' }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
EOF
}

1;

=head1 COPYRIGHT

Copyright (C) 2014 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut
