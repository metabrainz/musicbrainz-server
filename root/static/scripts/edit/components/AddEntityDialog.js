/*
 * @flow strict
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import Modal from '../../common/components/Modal.js';

export const TITLES: {+[entityType: string]: () => string} = {
  area: N_l('Add a new area'),
  artist: N_l('Add a new artist'),
  event: N_l('Add a new event'),
  instrument: N_l('Add a new instrument'),
  label: N_l('Add a new label'),
  place: N_l('Add a new place'),
  recording: N_l('Add a new recording'),
  release_group: N_l('Add a new release group'),
  series: N_l('Add a new series'),
  work: N_l('Add a new work'),
};

type PropsT = {
  +callback: (CoreEntityT) => void,
  +close: () => void,
  +entityType: string,
  +name?: string,
};

const AddEntityDialog = ({
  callback,
  close,
  entityType,
  name,
}: PropsT): React.Element<typeof Modal> => {
  const dialogRef = React.useRef<HTMLDivElement | null>(null);
  const iframeRef = React.useRef<HTMLIFrameElement | null>(null);
  const instanceRef = React.useRef(null);
  const [isLoading, setLoading] = React.useState(true);

  /*
   * Make sure click events within the dialog don't bubble and cause
   * side-effects.
   */
  const handleModalClick = React.useCallback((event) => {
    event.stopPropagation();
  }, []);

  const handlePageLoad = (event: SyntheticEvent<HTMLIFrameElement>) => {
    const contentWindow = event.currentTarget.contentWindow;

    if (contentWindow.dialogResult) {
      callback(contentWindow.dialogResult);
      return;
    }

    contentWindow.containingDialog = instanceRef;
    adjustDialogSize(contentWindow);
    setLoading(false);

    if (nonEmpty(name)) {
      const nameFieldId =
        'id-edit-' + entityType.replace('_', '-') + '.name';

      // Must use contentWindow's jQuery handle or this won't work.
      const $ = contentWindow.$;
      $(function () {
        contentWindow.setTimeout(function () {
          $(contentWindow.document.getElementById(nameFieldId))
            .val(name)
            .change()
            .focus();
        }, 1);
      });
    }
  };

  const adjustDialogSize = React.useCallback((contentWindow) => {
    const iframe = iframeRef.current;
    if (iframe) {
      iframe.style.height = String(contentWindow.outerHeight) + 'px';
    }
  }, [iframeRef]);

  instanceRef.current = {
    adjustDialogSize,
    close,
  };

  return (
    <Modal
      className="iframe-dialog"
      dialogRef={dialogRef}
      id={'add-' + entityType + '-dialog'}
      onClick={handleModalClick}
      onEscape={close}
      title={isLoading ? l('Loading...') : TITLES[entityType]()}
    >
      {isLoading ? (
        <div className="content-loading" />
      ) : false}
      <iframe
        onLoad={handlePageLoad}
        ref={iframeRef}
        src={'/dialog?path=' +
          encodeURIComponent('/' + entityType + '/create')}
      />
    </Modal>
  );
};

export default AddEntityDialog;
