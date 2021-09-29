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

    eval <<EOF; ## no critic 'ProhibitStringyEval'
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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
