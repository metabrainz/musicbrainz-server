/*
 * @flow
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export const ACCESS_SCOPE_PROFILE: 1 = 1;
export const ACCESS_SCOPE_EMAIL: 2 = 2;
export const ACCESS_SCOPE_TAG: 4 = 4;
export const ACCESS_SCOPE_RATING: 8 = 8;
export const ACCESS_SCOPE_COLLECTION: 16 = 16;
export const ACCESS_SCOPE_SUBMIT_ISRC: 64 = 64;
export const ACCESS_SCOPE_SUBMIT_BARCODE: 128 = 128;

export const ACCESS_SCOPE_PERMISSIONS = {
  [ACCESS_SCOPE_COLLECTION]: N_l('View and modify your private collections'),
  [ACCESS_SCOPE_EMAIL]: N_l('View your email address'),
  [ACCESS_SCOPE_PROFILE]: N_l('View your public account information'),
  [ACCESS_SCOPE_RATING]: N_l('View and modify your private ratings'),
  [ACCESS_SCOPE_SUBMIT_BARCODE]: N_l('Submit new barcodes to the database'),
  [ACCESS_SCOPE_SUBMIT_ISRC]: N_l('Submit new ISRCs to the database'),
  [ACCESS_SCOPE_TAG]: N_l('View and modify your private tags'),
};

export const CONTACT_URL = 'https://metabrainz.org/contact';

export const DONATE_URL = 'https://metabrainz.org/donate';

export const EDIT_EXPIRE_ACCEPT = 1;
export const EDIT_EXPIRE_REJECT = 2;

export const EDIT_STATUS_OPEN = 1;
export const EDIT_STATUS_APPLIED = 2;
export const EDIT_STATUS_FAILEDVOTE = 3;
export const EDIT_STATUS_FAILEDDEP = 4;
export const EDIT_STATUS_ERROR = 5;
export const EDIT_STATUS_FAILEDPREREQ = 6;
export const EDIT_STATUS_NOVOTES = 7;
export const EDIT_STATUS_TOBEDELETED = 8;
export const EDIT_STATUS_DELETED = 9;

export const EDIT_VOTE_NONE = -2;
export const EDIT_VOTE_ABSTAIN = -1;
export const EDIT_VOTE_NO = 0;
export const EDIT_VOTE_YES = 1;
export const EDIT_VOTE_APPROVE = 2;

export const QUALITY_UNKNOWN = -1;
export const QUALITY_UNKNOWN_MAPPED = 1;
export const QUALITY_LOW = 0;
export const QUALITY_NORMAL = 1;
export const QUALITY_HIGH = 2;
