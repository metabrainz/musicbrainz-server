/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

component RemoveButton(
  onClick: (event: SyntheticMouseEvent<HTMLButtonElement>) => void,
  title: string,
) {
  return (
    <button
      className="nobutton icon remove-item"
      onClick={onClick}
      title={title}
      type="button"
    />
  );
}

export default RemoveButton;
