package MusicBrainz::Server::Entity::Util::MediumFormat;

use strict;
use warnings;

use Sub::Exporter -setup => { exports => [qw(
    combined_medium_format_name
)] };

sub combined_medium_format_name
{
    my (@medium_format_names) = @_;
    return "" if !@medium_format_names;
    my %formats_count;
    my @formats_order;
    foreach my $format_name (@medium_format_names) {
        if (exists $formats_count{$format_name}) {
            $formats_count{$format_name} += 1;
        }
        else {
            $formats_count{$format_name} = 1;
            push @formats_order, $format_name;
        }
    }
    my @formats;
    foreach my $format (@formats_order) {
        my $count = $formats_count{$format};
        if ($count > 1 && $format) {
            $format = $count . "\x{00D7}" . $format;
        }
        push @formats, $format;
    }
    return join " + ", @formats;
}

1;
