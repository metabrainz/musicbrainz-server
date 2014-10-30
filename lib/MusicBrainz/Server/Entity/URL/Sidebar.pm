package MusicBrainz::Server::Entity::URL::Sidebar;
use Moose::Role;
use base 'Exporter';

requires 'sidebar_name';

use constant FAVICON_CLASSES => {
    'amazon'                    => 'amazon',
    'allmusic.com'              => 'allmusic',
    'animenewsnetwork.com'      => 'animenewsnetwork',
    'wikipedia.org'             => 'wikipedia',
    'facebook.com'              => 'facebook',
    'generasia.com'             => 'generasia',
    'last.fm'                   => 'lastfm',
    'myspace.com'               => 'myspace',
    'twitter.com'               => 'twitter',
    'youtube.com'               => 'youtube',
    'discogs.com'               => 'discogs',
    'secondhandsongs.com'       => 'secondhandsongs',
    'songfacts.com'             => 'songfacts',
    'soundcloud.com'            => 'soundcloud',
    'ibdb.com'                  => 'ibdb',
    'imslp.org'                 => 'imslp',
    'ester.ee'                  => 'ESTER',
    'worldcat.org'              => 'worldcat',
    '45cat.com'                 => 'fortyfivecat',
    'rateyourmusic.com'         => 'rateyourmusic',
    'rolldabeats.com'           => 'rolldabeats',
    'psydb.net'                 => 'psydb',
    'metal-archives.com'        => 'metalarchives',
    'spirit-of-metal.com'       => 'spiritofmetal',
    'theatricalia.com'          => 'theatricalia',
    'whosampled.com'            => 'whosampled',
    'ocremix.org'               => 'ocremix',
    'musik-sammler.de'          => 'musiksammler',
    'encyclopedisque.fr'        => 'encyclopedisque',
    'nla.gov.au'                => 'trove',
    'rockensdanmarkskort.dk'    => 'rockensdanmarkskort',
    'rockinchina.com'           => 'ric',
    'rockipedia.no'             => 'rockipedia',
    'viaf.org'                  => 'viaf',
    'vk.com'                    => 'vk',
    'vkdb.jp'                   => 'vkdb',
    'dhhu.dk'                   => 'dhhu',
    'thesession.org'            => 'thesession',
    'plus.google.com'           => 'googleplus',
    'openlibrary.org'           => 'openlibrary',
    'bandcamp.com'              => 'bandcamp',
    'itunes.apple.com'          => 'iTunes',
    'spotify.com'               => 'spotify',
    'soundtrackcollector.com'   => 'STcollector',
    'wikidata.org'              => 'wikidata',
    'recmusic.org/lieder'       => 'lieder',
    'genius.com'                => 'genius',
    'imvdb.com'                 => 'imvdb',
    'residentadvisor.net'       => 'residentadvisor',
    'd-nb.info'                 => 'dnb',
    'iss.ndl.go.jp'             => 'ndl',
    'ci.nii.ac.jp'              => 'cinii',
    'finnmusic.net'             => 'finnmusic',
    'fono.fi'                   => 'fonofi',
    'stage48.net'               => 'stage48',
};

our @EXPORT_OK = qw( FAVICON_CLASSES );

=method show_in_sidebar

Returns true if this URL should be displayed in the sidebar, or false if it
should not. Allows URLs to do per-value checks on URLs.

=cut

sub show_in_sidebar { 1 }

1;
