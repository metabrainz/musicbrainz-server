/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/*
 * See http://search.cpan.org/~lbrocard/Data-Page-2.02/lib/Data/Page.pm
 * Serialized in MusicBrainz::Server::TO_JSON.
 */
declare type PagerT = {
  +current_page: number,
  +first_page: 1,
  +last_page: number,
  +next_page: number | null,
  +previous_page: number | null,
  +total_entries: number,
};

declare type StrOrNum = string | number;
