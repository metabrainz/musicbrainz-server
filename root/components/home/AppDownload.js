/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import {faGooglePlay, faAndroid} from '@fortawesome/free-brands-svg-icons';

const AppDownload = (): React.Element<'section'> => {
  return (
    <section className="download-section center">
      <div className="container-fluid">
        <div className="row">
          <h2 className="col-md-6">
            {l('Download our app')}
          </h2>
          <div className="col-md-6">
            <a
              className="btn btn-dark btn-lg"
              href="https://play.google.com/store/apps/details?id=org.metabrainz.android"
              rel="noopener noreferrer"
              target="_blank"
            >
              <FontAwesomeIcon
                icon={faGooglePlay}
                size="lg"
              />
              {' '}
              {l('Google Play')}
            </a>
            <a
              className="btn btn-dark btn-lg"
              href="https://f-droid.org/en/packages/org.metabrainz.android/"
              rel="noopener noreferrer"
              target="_blank"
            >
              <FontAwesomeIcon
                icon={faAndroid}
                size="lg"
              />
              {' '}
              {l('F-Droid')}
            </a>
          </div>
        </div>
      </div>
    </section>
  );
};

export default AppDownload;
