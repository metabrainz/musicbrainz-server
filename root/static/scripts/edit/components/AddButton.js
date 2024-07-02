/*
 * @flow strict
 * Copyright (C) 2024 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

component AddButton(
  onClick: (event: SyntheticEvent<HTMLInputElement>) => void,
  label?: string,
) {
  if (label == null) {
    return <button className="add-item" onClick={onClick} type="button" />;
  }

  return (
    <button className="with-label add-item" onClick={onClick} type="button">
      {l(label)}
    </button>
  );
}

export default AddButton;
