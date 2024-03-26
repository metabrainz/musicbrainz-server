/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

type PropsT = {
  +label?: string,
};

const InlineSubmitButton = ({
  label,
}: PropsT): React.MixedElement => (
  <>
    {' '}
    <span className="buttons inline">
      <button type="submit">
        {nonEmpty(label) ? label : l('Submit')}
      </button>
    </span>
  </>
);

export default InlineSubmitButton;
