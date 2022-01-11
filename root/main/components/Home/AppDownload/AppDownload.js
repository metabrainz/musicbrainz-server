/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import {minimalEntity} from '../../../../utility/hydrate';

function AppDownload(props) {
  return (
    <section className={
      'section cta-section ' + props.theme
    }
    >
      <div className="container">
        <div className="row align-items-center">
          <div
            className="col-md-6 me-auto text-center
             text-md-start mb-5 mb-md-0"
          >
            <h2>
              {l(`Download and Use our App and Software`)}
            </h2>
          </div>
          <div className="col-md-5 text-center text-md-end">
            <a
              className="btn d-inline-flex align-items-center"
              href="https://play.google.com/store/apps/details?id=org.metabrainz.android"
              rel="noopener noreferrer"
              target="_blank"
            >
              <i className="fab fa-google-play" />
              <span>{l(`Google play`)}</span>
            </a>
            <a
              className="btn d-inline-flex align-items-center"
              href="https://f-droid.org/en/packages/org.metabrainz.android/"
              rel="noopener noreferrer"
              target="_blank"
            >
              <i className="fab fa-android" />
              <span>{l(`F-Droid`)}</span>
            </a>
            <a
              className="btn d-inline-flex align-items-center"
              href="https://picard.musicbrainz.org"
              rel="noopener noreferrer"
              target="_blank"
            >
              <i className="fa fa-laptop" />
              <span>{l(`PC & Mac`)}</span>
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
export default (hydrate<Props>(
  'div.app-download',
  AppDownload,
  minimalEntity,
));
