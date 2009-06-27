#!/bin/sh

# TODO
# - make copy/move ambidextrous
# - create separate copy/move/remove scripts

# The AR conversion script move all ARs to release_group-release_group. If that is the final destination
# for a given AR type, use the ngs-noop-ars.pl script just so we can track what has been taken care of and what hasn't.

# album-album -----------------------------------------------
# command               Name                                   From                           To
ngs-noop-ars.pl         'covers and versions'     
ngs-rem-ars.pl          'first album release'     
ngs-move-ars.pl         'remaster'                             release_group-release_group    release-release 
ngs-noop-ars.pl         'remixes' 
ngs-noop-ars.pl         'mashes up'
ngs-noop-ars.pl         'remix'
                        'compilations'
                        'DJ-mix'                               release_group-release-group    release-release         
                        'live performance'                     release_group-release-group    release-release         
ngs-noop-ars.pl         'cover'
<custom>                'transl-tracklisting'
ngs-rem-ars.pl          'part of set'

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
ngs-noop-ars.pl         'legal representation'
ngs-noop-ars.pl         'booking'
                        'artists and repertoire'
                        'creative direction'
ngs-copy-ars.pl         'art direction'                        artist-release_group           artist-release
ngs-copy-ars.pl         'design/illustration'                  artist-release_group           artist-release
ngs-copy-ars.pl         'graphic design'                       artist-release_group           artist-release
ngs-copy-ars.pl         'photography'                          artist-release_group           artist-release
ngs-noop-ars.pl         'travel'
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
ngs-noop-ars.pl         'review'
                        'get the music'
ngs-copy-ars.pl         'purchase for mail-order'              release_group-url      release-url
ngs-copy-ars.pl         'purchase for download'                release_group-url      release-url
ngs-copy-ars.pl         'download for free'                    release_group-url      release-url
                        'other databases'
                        'wikipedia'
                        'discogs'
                        'musicmoz'
ngs-noop-ars.pl         'IMDb'
                        'Affiliate links'
<custom>                'amazon asin'                          release_group-url      release-url
ngs-copy-ars.pl         'creative commons licensed download'   release_group-url      release-url
ngs-copy-ars.pl         'cover art link'                       release_group-url      release-url
ngs-noop-ars.pl         'ibdb'
ngs-noop-ars.pl         'iobdb'
