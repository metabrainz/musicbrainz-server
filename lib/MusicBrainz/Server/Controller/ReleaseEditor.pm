package MusicBrainz::Server::Controller::ReleaseEditor;
use utf8;
use Moose;

BEGIN { extends 'MusicBrainz::Server::Controller' }

__PACKAGE__->config(
    namespace => 'release_editor'
);

use List::UtilsBy qw( partition_by );
use Try::Tiny;
use Scalar::Util qw( looks_like_number );
use MusicBrainz::Server::CGI::Expand qw( expand_hash );
use MusicBrainz::Server::Track qw( unformat_track_length );
use MusicBrainz::Server::Translation qw( l );
use MusicBrainz::Server::Data::Utils qw( non_empty sanitize trim );
use MusicBrainz::Server::Form::Utils qw(
    language_options
    script_options
    select_options
    select_options_tree
    build_grouped_options
    build_type_info
);
use aliased 'MusicBrainz::Server::Entity::CDTOC';
use aliased 'MusicBrainz::Server::Entity::PartialDate';

# Methods for the release editor
sub _init_release_editor
{
    my ($self, $c, %options) = @_;

    $options{redirect_uri} = (
        $c->req->query_params->{redirect_uri} //
        $c->req->body_params->{redirect_uri}
    );

    $options{seeded_data} = $c->json->encode($self->_seeded_data($c) // {});

    my $url_link_types = $c->model('LinkType')->get_tree('release', 'url');
    my @link_attribute_types = $c->model('LinkAttributeType')->get_all;

    my @medium_formats = $c->model('MediumFormat')->get_all;
    my $discid_formats = [ grep { $_ } map { $_->has_discids ? ($_->id) : () } @medium_formats ];
    my %medium_format_dates = map { $_->id => $_->year } @medium_formats;

    $c->stash(
        template            => 'release/edit/layout.tt',
        # These need to be accessed by root/release/edit/information.tt.
        primary_types       => select_options_tree($c, 'ReleaseGroupType'),
        secondary_types     => select_options_tree($c, 'ReleaseGroupSecondaryType'),
        statuses            => select_options_tree($c, 'ReleaseStatus'),
        languages           => build_grouped_options($c, language_options($c)),
        scripts             => build_grouped_options($c, script_options($c)),
        packagings          => select_options_tree($c, 'ReleasePackaging'),
        countries           => select_options($c, 'CountryArea'),
        formats             => select_options_tree($c, 'MediumFormat'),
        type_info           => $c->json->encode(build_type_info($c, qr/release-url/, $url_link_types)),
        attr_info           => $c->json->encode(\@link_attribute_types),
        discid_formats      => $c->json->encode($discid_formats),
        medium_format_dates => $c->json->encode(\%medium_format_dates),
        # The merge helper doesn't really work well together with the release editor process
        hide_merge_helper   => 1,
        %options
    );
}

sub edit : Chained('/release/load') PathPart('edit') Edit RequireAuth
{
    my ($self, $c) = @_;

    my $release = $c->stash->{release};

    my @mediums = $release->all_mediums;
    $c->model('MediumCDTOC')->load_for_mediums(@mediums);
    $c->model('CDTOC')->load(map { $_->all_cdtocs } @mediums);
    $c->model('Relationship')->load_cardinal($release->release_group, $release);

    $self->_init_release_editor(
        $c,
        return_to => $c->uri_for_action('/release/show', [ $release->gid ]),
        release_json => $c->json->encode($release),
    );
}

sub add : Path('/release/add') Edit RequireAuth
{
    my ($self, $c) = @_;

    my $release_group_gid = $c->req->query_params->{'release-group'};
    my $label_gid = $c->req->query_params->{'label'};
    my $artist_gid = $c->req->query_params->{'artist'};
    my $return_to;

    if ($release_group_gid) {
        $return_to = $c->uri_for_action('/release_group/show', [ $release_group_gid ]);
    }
    elsif ($label_gid) {
        $return_to = $c->uri_for_action('/label/show', [ $label_gid ]);
    }
    elsif ($artist_gid) {
        $return_to = $c->uri_for_action('/artist/show', [ $artist_gid ]);
    }
    else {
        $return_to = $c->uri_for_action('/index');
    }

    $self->_init_release_editor($c, return_to => $return_to);
}

sub _seeded_data
{
    my ($self, $c) = @_;

    my $params = expand_hash($c->req->body_params) // {};

    my $release_group_gid = $c->req->query_params->{'release-group'};
    my $artist_gid = $c->req->query_params->{'artist'};
    my $label_gid = $c->req->query_params->{'label'};

    $params->{release_group} = $release_group_gid if $release_group_gid;
    $params->{artist_credit} = { names => [ { mbid => $artist_gid } ] } if $artist_gid;
    $params->{labels} = [ { mbid => $label_gid } ] if $label_gid;

    return $self->_process_seeded_data($c, $params);
}

sub _process_seeded_data
{
    my ($self, $c, $params) = @_;

    my $result = {};
    my @errors;

    my @known_fields = qw( name release_group type comment annotation barcode
                           language script status packaging events labels
                           date country artist_credit mediums urls edit_note
                           redirect_uri make_votable );

    _report_unknown_fields('', $params, \@errors, @known_fields);

    if (non_empty(my $name = _seeded_string($params->{name}, 'name', \@errors))) {
        $result->{name} = trim($name);
    }

    if (non_empty(my $comment = _seeded_string($params->{comment}, 'comment', \@errors))) {
        $result->{comment} = trim($comment);
    }

    if (non_empty(my $annotation = _seeded_string($params->{annotation}, 'annotation', \@errors))) {
        $result->{annotation} = $annotation;
    }

    if (non_empty(my $barcode = _seeded_string($params->{barcode}, 'barcode', \@errors))) {
        $result->{barcode} = trim($barcode) || undef;
    }

    if (my $ac = $params->{artist_credit}) {
        $result->{artistCredit} = _seeded_hash($c, \&_seeded_artist_credit,
            $ac, "artist_credit", \@errors);
    }

    if (my $gid = $params->{release_group}) {
        my $release_group = $c->model('ReleaseGroup')->get_by_gid($gid);

        if ($release_group) {
            $c->model('ArtistCredit')->load($release_group);

            $result->{releaseGroup} = $release_group->TO_JSON;
            $result->{name} ||= $result->{releaseGroup}->{name};
            $result->{artistCredit} ||= $result->{releaseGroup}->{artistCredit};
        } else {
            push @errors, "Invalid release_group: “$gid”.";
        }
    } elsif (my $types = $params->{type}) {
        $result->{releaseGroup} = { name => $result->{name} // '' };

        my @secondary_types_result;

        my %primary_types = map { lc($_->name) => $_ }
            $c->model('ReleaseGroupType')->get_all;

        my %secondary_types = map { lc($_->name) => $_ }
            $c->model('ReleaseGroupSecondaryType')->get_all;

        for my $type (ref($types) eq 'ARRAY' ? @$types : ($types)) {
            my $lc_type = lc $type;

            if ($primary_types{$lc_type}) {
                $result->{releaseGroup}->{typeID} = $primary_types{$lc_type}->id;
            }
            elsif ($secondary_types{$lc_type}) {
                push @secondary_types_result, $secondary_types{$lc_type}->id;
            }
            else {
                push @errors, "Invalid release group type: “$type”.";
            }
        }
        $result->{releaseGroup}->{secondaryTypeIDs} = \@secondary_types_result;
    }

    if (my $code = lc($params->{language} // '')) {
        my $language = $c->model('Language')->find_by_code($code);

        if ($language) {
            $result->{languageID} = $language->id;
        } else {
            push @errors, "Invalid language: “$code”.";
        }
    }

    if (my $code = lc ucfirst($params->{script} // '')) {
        my $script = $c->model('Script')->find_by_code($code);

        if ($script) {
            $result->{scriptID} = $script->id;
        } else {
           push @errors, "Invalid script: “$code”.";
        }
    }

    if (my $name = $params->{status}) {
        my $status = $c->model('ReleaseStatus')->find_by_name($name);

        if ($status) {
            $result->{statusID} = $status->id;
        } else {
            push @errors, "Invalid status: “$name”.";
        }
    }

    if (my $name = $params->{packaging}) {
        my $packaging = $c->model('ReleasePackaging')->find_by_name($name);

        if ($packaging) {
            $result->{packagingID} = $packaging->id;
        } else {
            push @errors, "Invalid packaging: “$name”.";
        }
    }

    if (exists $params->{country} || exists $params->{date}) {
        # schema 16 style country/date pair, convert to schema 18 release event.
        $params->{events} = [{}];
        $params->{events}->[0]->{date} = $params->{date} if exists $params->{date};
        $params->{events}->[0]->{country} = $params->{country} if exists $params->{country};
    }

    if (my $events = $params->{events}) {
        $result->{events} = _seeded_array($c, \&_seeded_event, $events, "events", \@errors);
    }

    if (my $labels = $params->{labels}) {
        $result->{labels} = _seeded_array($c, \&_seeded_label, $labels, "labels", \@errors);
    }

    if (my $mediums = $params->{mediums}) {
        $result->{mediums} = _seeded_array($c, \&_seeded_medium, $mediums, "mediums", \@errors);

        my $position = 0;

        for my $medium (@{ $result->{mediums} // [] }) {
            $medium->{position} = ++$position;
        }
    }

    if (my $urls = $params->{urls}) {
        $result->{relationships} = _seeded_array($c, \&_seeded_url, $urls, "urls", \@errors);
    }

    $result->{editNote} = $params->{edit_note} if $params->{edit_note};

    if (defined $params->{make_votable}) {
        $result->{makeVotable} = $params->{make_votable};
    }

    return { seed => $result, errors => \@errors };
}

sub _seeded_string
{
    my ($value, $field_name, $errors) = @_;

    return unless defined $value;

    if (ref $value) {
        push @$errors, "$field_name must be a scalar, not a hash or array.";
        return undef;
    }

    return $value;
}

sub _seeded_hash
{
    my ($c, $parse, $params, $field_name, $errors) = @_;

    return unless defined $params;

    if (ref($params) eq "HASH") {
        return $parse->($c, $params, $field_name, $errors);
    } else {
        push @$errors, "$field_name must be a hash.";
        return undef;
    }
}

sub _seeded_array
{
    my ($c, $parse, $params, $field_name, $errors) = @_;

    unless (ref($params) eq "ARRAY") {
        push @$errors, "$field_name must be an array";

        if (ref($params) eq "HASH") {
            _report_unknown_fields($field_name, $params, $errors);
        }
        return undef;
    }

    my @results;
    my $param_count = scalar @$params;

    if ($param_count > 0 && !defined $params->[0]) {
        push @$errors, "$field_name.0 isn’t defined, do your indexes start at 0?";
    }

    for (my $i = 0; $i < $param_count; $i++) {
        my $param = $params->[$i];

        my $result = _seeded_hash($c, $parse, $param // {}, "$field_name.$i", $errors);

        push @results, $result // {};
    }

    return \@results;
}

sub _seeded_event
{
    my ($c, $params, $field_name, $errors) = @_;

    _report_unknown_fields($field_name, $params, $errors, qw( date country ));

    my $result = {};

    if (my $date = $params->{date}) {
        for my $prop (qw( year month day )) {
            if (my $num = delete $date->{$prop}) {
                if ($num =~ /^[0-9]+$/) {
                    $date->{$prop} = int($num);
                } else {
                    push @$errors, "Invalid $field_name.date.$prop: “$num”.";
                }
            }
        }

        $result->{date} = $date if %$date;
    }

    if (my $iso = uc($params->{country} // '')) {
        my $country = $c->model('Area')->get_by_iso_3166_1($iso)->{$iso};

        if ($country) {
            $result->{country} = $country->TO_JSON;
        } else {
            push @$errors, "Invalid $field_name.country: “$iso”.";
        }
    }
    return $result;
}

sub _seeded_label
{
    my ($c, $params, $field_name, $errors) = @_;

    _report_unknown_fields($field_name, $params, $errors, qw( mbid name catalog_number ));

    my $result = {};

    if (my $gid = $params->{mbid}) {
        my $label = $c->model('Label')->get_by_gid($gid);

        if ($label) {
            $result->{label} = $label->TO_JSON;
        }
        else {
            push @$errors, "Invalid $field_name.mbid: “$gid”."
        }
    }
    elsif (non_empty(my $name = _seeded_string($params->{name}, "$field_name.name", $errors))) {
        $result->{label} = { name => trim($name) };
    }

    $result->{catalogNumber} = trim($params->{catalog_number});
    return $result;
}

sub _seeded_medium
{
    my ($c, $params, $field_name, $errors) = @_;

    my @known_fields = qw( format name track toc );
    _report_unknown_fields($field_name, $params, $errors, @known_fields);

    my $result = { tracks => [] };

    if (my $name = $params->{format}) {
        my $format = $c->model('MediumFormat')->find_by_name($name);

        if ($format) {
            $result->{format_id} = $format->id;
        } else {
            push @$errors, "Invalid $field_name.format: “$name”.";
        }
    }

    if (non_empty(my $name = _seeded_string($params->{name}, "$field_name.name", $errors))) {
        $result->{name} = trim($name);
    }

    if (my $tracks = $params->{track}) {
        $result->{tracks} = _seeded_array($c, \&_seeded_track, $tracks, "$field_name.track", $errors);
    }

    if (my $toc = $params->{toc}) {
        try {
            my $cdtoc = CDTOC->new_from_toc($toc);
            my $tracks = $result->{tracks};
            my $track_count = scalar @$tracks;

            # This can only happen if a "pregap" field was sent for track 0.
            if ($track_count && defined($tracks->[0]->{position}) && $tracks->[0]->{position} == 0) {
                --$track_count;
            }

            if ($track_count > 0 && $track_count != $cdtoc->track_count) {
                push @$errors, "Track counts of $field_name.toc and $field_name.track don’t match.";
            } else {
                my $details = $cdtoc->track_details;

                for my $i (0..$cdtoc->track_count - 1) {
                    $tracks->[$i] //= {};
                    $tracks->[$i]->{length} = $details->[$i]->{length_time};
                }
            }
            $result->{toc} = $toc;
            $result->{cdtocs} = 1;
        }
        catch {
            push @$errors, "Invalid $field_name.toc: “$toc”.";
        };
    }

    my $position = 0;

    for my $track (@{ $result->{tracks} }) {
        $position++;
        $track->{position} = $position unless defined $track->{position};
        $track->{number} = $track->{position} unless defined $track->{number};
    }

    return $result;
}

sub _seeded_track
{
    my ($c, $params, $field_name, $errors) = @_;

    my @known_fields = qw( name number recording length artist_credit pregap );
    _report_unknown_fields($field_name, $params, $errors, @known_fields);

    my $result = {};

    if (non_empty(my $name = _seeded_string($params->{name}, "$field_name.name", $errors))) {
        $result->{name} = trim($name);
    }

    if (non_empty(my $number = _seeded_string($params->{number}, "$field_name.number", $errors))) {
        $result->{number} = trim($number) =~ s/^0+(\d+)/$1/gr;
    }

    if (my $ac = $params->{artist_credit}) {
        $result->{artistCredit} = _seeded_hash($c, \&_seeded_artist_credit,
            $ac, "$field_name.artist_credit", $errors);
    }

    if (my $length = $params->{length}) {
        if ($length =~ /:/) {
            try {
                $result->{length} = unformat_track_length($length);
            } catch {
                if ($_ =~ m/is not a valid track length/) {
                    push @$errors, "Invalid $field_name.length: “$length”.";
                } else {
                    die $_;
                }
            };
        } else {
            $result->{length} = $length;
        }
    }

    if (my $gid = $params->{recording}) {
        if (my $recording = $c->model('Recording')->get_by_gid($gid)) {
            $c->model('ArtistCredit')->load($recording);

            $result->{recording} = $recording->TO_JSON;
        } else {
            push @$errors, "Invalid $field_name.recording: “$gid”.";
        }
    }

    if (my $pregap = $params->{pregap}) {
        $result->{position} = 0;
    }

    return $result;
}

sub _seeded_artist_credit
{
    my ($c, $params, $field_name, $errors) = @_;

    _report_unknown_fields($field_name, $params, $errors, 'names');

    return {
        names => _seeded_array(
            $c, \&_seeded_artist_credit_name, $params->{names},
            "$field_name.names", $errors),
    };
}

sub _seeded_artist_credit_name
{
    my ($c, $params, $field_name, $errors) = @_;

    my @known_fields = qw( mbid name artist join_phrase );
    _report_unknown_fields($field_name, $params, $errors, @known_fields);

    my $result = {};

    my $name = _seeded_string($params->{name}, "$field_name.name", $errors);
    $result->{name} = trim($name);

    if (my $gid = $params->{mbid}) {
        my $entity = $c->model('Artist')->get_by_gid($gid);

        if ($entity) {
            $result->{artist} = $entity->TO_JSON;
            $result->{name} ||= $entity->name;
        } else {
            push @$errors, "Invalid $field_name.mbid: “$gid”.";
        }
    }

    my $join = _seeded_string($params->{join_phrase}, "$field_name.join_phrase", $errors);
    $result->{joinPhrase} = sanitize($join);

    $result->{artist} //= _seeded_hash($c, \&_seeded_artist, $params->{artist},
        "$field_name.artist", $errors);
    $result->{name} ||= ($result->{artist}{name} // '');

    return $result;
}

sub _seeded_artist
{
    my ($c, $params, $field_name, $errors) = @_;

    _report_unknown_fields($field_name, $params, $errors, 'name');

    my $result = {};

    if (non_empty(my $name = _seeded_string($params->{name}, "$field_name.name", $errors))) {
        $result->{name} = trim($name);
    }

    return $result;
}

sub _seeded_url
{
    my ($c, $params, $field_name, $errors) = @_;

    my @known_fields = qw( url link_type );
    _report_unknown_fields($field_name, $params, $errors, @known_fields);

    my $result = {
        target => { name => '', entityType => 'url' },
    };

    if (non_empty(my $url = _seeded_string($params->{url}, "$field_name.url", $errors))) {
        $result->{target}->{name} = trim($url);
    }

    if (non_empty(my $id = _seeded_string($params->{link_type}, "$field_name.link_type", $errors))) {
        my $link_type = $c->model('LinkType')->get_by_id($id);

        if ($link_type && !$link_type->is_deprecated &&
                $link_type->entity0_type eq 'release' &&
                $link_type->entity1_type eq 'url') {

            $result->{linkTypeID} = $id;
        } else {
            push @$errors, "Invalid $field_name.link_type: “$id”.";
        }
    }

    return $result;
}

sub _report_unknown_fields
{
    my ($parent, $fields, $errors, @valid_fields) = @_;

    my %valid_keys = map { $_ => 1 } @valid_fields;
    my @unknown_keys = sort { $a cmp $b } grep { !exists $valid_keys{$_} } keys %$fields;

    push @$errors, map {
        "Unknown field: " . ($parent ? "$parent." : "") . "$_"
    } @unknown_keys;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
