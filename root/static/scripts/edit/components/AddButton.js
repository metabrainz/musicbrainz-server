/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

component AddButton(
  id: string,
  onClick: (event: SyntheticEvent<HTMLButtonElement>) => void,
  label?: string,
) {
  return (
    <button
      className={'add-item' + (nonEmpty(label) ? ' with-label' : '')}
      id={id}
      onClick={onClick}
      type="button"
    >
      {nonEmpty(label) ? label : null}
    </button>
  );
}

export default AddButton;
