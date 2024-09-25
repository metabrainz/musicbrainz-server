/*
 * @flow strict
 * Copyright (C) 2017 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

component FormRow(
  children: React.Node,
  className as passedClassname?: string,
  hasNoLabel: boolean = false,
  hasNoMargin: boolean = false,
  rowRef?: {-current: HTMLDivElement | null},
) {
  return (
    <div
      className={
        'row' +
        (hasNoLabel ? ' no-label' : '') +
        (hasNoMargin ? ' no-margin' : '') +
        (nonEmpty(passedClassname) ? ' ' + passedClassname : '')
      }
      ref={rowRef}
    >
      {children}
    </div>
  );
}

export default FormRow;
