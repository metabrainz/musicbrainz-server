/*
 * @flow strict
 * Copyright (C) 2015 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type PropsT = {
  dataIndex?: number,
  onClick: (event: SyntheticEvent<HTMLInputElement>) => void,
  title: string,
};

const RemoveButton = ({
  dataIndex,
  onClick,
  title,
}: PropsT): React$Element<'button'> => (
  <button
    className="nobutton icon remove-item"
    data-index={dataIndex}
    onClick={onClick}
    title={title}
    type="button"
  />
);

export default RemoveButton;
