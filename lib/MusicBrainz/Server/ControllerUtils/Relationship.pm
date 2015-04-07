package MusicBrainz::Server::ControllerUtils::Relationship;

use base 'Exporter';
use MusicBrainz::Server::Data::Utils qw( trim non_empty );

our @EXPORT_OK = qw(
    merge_link_attributes
);

sub _clean_link_attribute {
    my ($data) = @_;

    my $credited_as = trim($data->{credited_as});
    my $text_value = trim($data->{text_value});

    return {
        type => { gid => $data->{type}{gid} },
        non_empty($credited_as) ? (credited_as => $credited_as) : (),
        non_empty($text_value) ? (text_value => $text_value) : (),
    };
}

sub merge_link_attributes {
    my ($submitted, $existing) = @_;

    my %new;
    my %existing = map { $_->type->gid => $_->to_json_hash } @$existing;

    for my $attr (@$submitted) {
        my $gid = $attr->{type}{gid} or next;

        if ($attr->{removed}) {
            delete $existing{$gid};
        } else {
            $new{$gid} = _clean_link_attribute($attr);
        }
    }

    while (my ($gid, $attr) = each %existing) {
        $new{$gid} = $attr unless exists $new{$gid};
    }

    return [values %new];
}
