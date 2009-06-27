#!/bin/sh

# The AR conversion script move all ARs to release_group-release_group. If that is the final destination
# for a given AR type, use the # no action required script just so we can track what has been taken care of and what hasn't.

# album-album -----------------------------------------------
# command               Name                                   From                           To
# no action required    'covers and versions'     
ngs-copy-ars.pl -r      'first album release'     
ngs-copy-ars.pl -m      'remaster'                             release_group-release_group    release-release 
# no action required    'remixes' 
# no action required    'mashes up'
# no action required    'remix'
                        'compilations'
                        'DJ-mix'                               release_group-release-group    release-release         
                        'live performance'                     release_group-release-group    release-release         
# no action required    'cover'
<custom>                'transl-tracklisting'
ngs-copy-ars.pl -r      'part of set'

# album-artist -----------------------------------------------
                        'performance '
ngs-copy-ars.pl         'performer'                            artist-release_group           artist-release
ngs-copy-ars.pl         'instrument'                           artist-release_group           artist-release
ngs-copy-ars.pl         'vocal'                                artist-release_group           artist-release
ngs-copy-ars.pl         'performing orchestra'                 artist-release_group           artist-release
ngs-copy-ars.pl         'conductor'                            artist-release_group           artist-release
                        'remixes '
                        'remixer'
                        'samples from artist'
                        'composition '
                        'composer'
                        'arranger'
                        'lyricist'
                        'production '
ngs-copy-ars.pl         'producer'                             artist-release_group           artist-release
ngs-copy-ars.pl         'engineer'                             artist-release_group           artist-release
ngs-copy-ars.pl         'audio'                                artist-release_group           artist-release
ngs-copy-ars.pl         'sound'                                artist-release_group           artist-release
ngs-copy-ars.pl         'live sound'                           artist-release_group           artist-release
ngs-copy-ars.pl         'mix'                                  artist-release_group           artist-release
ngs-copy-ars.pl         'recording'                            artist-release_group           artist-release
                        'misc'
# no action required    'legal representation'
# no action required    'booking'
                        'artists and repertoire'
                        'creative direction'
ngs-copy-ars.pl         'art direction'                        artist-release_group           artist-release
ngs-copy-ars.pl         'design/illustration'                  artist-release_group           artist-release
ngs-copy-ars.pl         'graphic design'                       artist-release_group           artist-release
ngs-copy-ars.pl         'photography'                          artist-release_group           artist-release
# no action required    'travel'
                        'publishing'
                        'merchandise'
ngs-copy-ars.pl         'mix-DJ'                               artist-release_group           artist-release
                        'compilations'
ngs-copy-ars.pl         'compiler'                             artist-release_group           artist-release
                        'librettist'
ngs-copy-ars.pl         'chorus master'                        artist-release_group           artist-release
                        'tribute'
                        'mastering'
                        'instrumentator'
                        'orchestrator'
                        'liner notes'
                        'programming'
                        'editor'

# album-label ------------------------------------------------
                        'publishing'

# album-track ------------------------------------------------
                        'samples material'

# album-url   ------------------------------------------------
                        'discography'
# no action required         'review'
                        'get the music'
ngs-copy-ars.pl         'purchase for mail-order'              release_group-url      release-url
ngs-copy-ars.pl         'purchase for download'                release_group-url      release-url
ngs-copy-ars.pl         'download for free'                    release_group-url      release-url
                        'other databases'
                        'wikipedia'
                        'discogs'
                        'musicmoz'
# no action required         'IMDb'
                        'Affiliate links'
<custom>                'amazon asin'                          release_group-url      release-url
ngs-copy-ars.pl         'creative commons licensed download'   release_group-url      release-url
ngs-copy-ars.pl         'cover art link'                       release_group-url      release-url
# no action required    'ibdb'
# no action required    'iobdb'
