/*
 * @flow strict
 * Copyright (C) 2019 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

/* eslint-disable-next-line import/prefer-default-export */
export const ANNOTATION_REPORT_TEXT: (() => string) = N_l_reports(
  `If you see something in these annotations that can be represented with a 
   relationship instead, please add a relationship and remove that part of
   the annotation. If something is marked as “sub-optimal”, consider checking 
   if a better way to store that data has been added in the meantime.`,
);
