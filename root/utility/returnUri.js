/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function returnUri(
  $c: CatalystContextT,
  path: string,
  redirect: string = '',
): string {
  return path + '?returnto=' + encodeURIComponent(
    $c.req.query_params.returnto || redirect || $c.relative_uri,
  );
}

export function returnToCurrentPage(
  $c: CatalystContextT | SanitizedCatalystContextT,
): string {
  return 'returnto=' + encodeURIComponent($c.relative_uri);
}
