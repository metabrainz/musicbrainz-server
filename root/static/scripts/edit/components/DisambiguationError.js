/*
 * @flow strict
 * Copyright (C) 2025 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

component DisambiguationError(
  duplicateViolation: boolean = false,
  needsDisambiguation: boolean = false,
) {
  const errorText = needsDisambiguation
    ? l('You must enter a disambiguation comment for this entity.')
    : duplicateViolation
      ? l(`An entity with that name and disambiguation already exists.
           You must enter a unique disambiguation comment.`)
      : '';

  if (nonEmpty(errorText)) {
    return (
      <div className="row no-label error">
        {errorText}
      </div>
    );
  }

  return null;
}

export default DisambiguationError;
