/*
 * @flow strict
 * Copyright (C) 2023 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import type {
  Observable as KnockoutObservable,
} from 'knockout';

export type ReleaseEditorTrackT = {
  +artistCredit: KnockoutObservable<ArtistCreditT>,
  +entityType: 'track',
  +gid?: string,
  +id?: number,
  +name: KnockoutObservable<string>,
  +next: () => ReleaseEditorTrackT | null,
  +previous: () => ReleaseEditorTrackT | null,
  ...
};
