/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function uriWith<T: {...}>(
  uriString: string,
  params: T,
): string {
  const urlObject = new URL(uriString);
  const searchParams = new URLSearchParams(urlObject.search);

  for (const key of Object.keys(params)) {
    searchParams.set(key, params[key]);
  }

  urlObject.search = searchParams.toString();

  return urlObject.href;
}
