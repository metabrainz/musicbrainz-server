/*
 * @flow strict
 * Copyright (C) 2018 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

component FormSubmit(
  className?: string,
  inputClassName?: string,
  label: React.Node,
  name?: string,
  value?: string,
) {
  return (
    <span
      className={'buttons' + (nonEmpty(className) ? ' ' + className : '')}
    >
      <button
        className={inputClassName}
        name={name}
        type="submit"
        value={value}
      >
        {label}
      </button>
    </span>
  );
}

export default FormSubmit;
