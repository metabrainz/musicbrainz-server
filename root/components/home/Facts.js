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
import {faMusic, faHeadphones, faCompactDisc, faUsers}
  from '@fortawesome/free-solid-svg-icons';

const Facts = (): React.Element<'section'> => (
  <section className="p-4">
    <div className="container">
      <div className="row">
        <div className="col-lg-3 col-md-6">
          <div className="count-box p-4">
            <FontAwesomeIcon
              className="icon me-4"
              icon={faMusic}
              size="4x"
            />
            <div>
              {exp.l(`<span class="fs-1 fw-bold">${1.95} M</span> Artists`)}
            </div>
          </div>
        </div>

        <div className="col-lg-3 col-md-6">
          <div className="count-box p-4">
            <FontAwesomeIcon
              className="icon me-4"
              icon={faCompactDisc}
              size="4x"
            />
            <div>
              {exp.l(`<span class="fs-1 fw-bold">${3.17} M</span> Releases`)}
            </div>
          </div>
        </div>

        <div className="col-lg-3 col-md-6">
          <div className="count-box p-4">
            <FontAwesomeIcon
              className="icon me-4"
              icon={faHeadphones}
              size="4x"
            />
            <div>
              {exp.l(`<span class="fs-1 fw-bold">${36.77} M</span> Tracks`)}
            </div>
          </div>
        </div>

        <div className="col-lg-3 col-md-6">
          <div className="count-box p-4">
            <FontAwesomeIcon
              className="icon me-4"
              icon={faUsers}
              size="4x"
            />
            <div>
              {exp.l(`<span class="fs-1 fw-bold">${2.20} M</span> Editors`)}
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
);

export default Facts;
