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
// eslint-disable-next-line import/no-unresolved
import {faCheckCircle} from '@fortawesome/free-solid-svg-icons';

const About = (): React.Element<'section'> => (
  <section className="p-4">
    <div className="container">
      <div className="row">
        <div className="col-lg-6 fs-4">
          <h3 className="fs-1 fw-bolder">
            {
            // eslint-disable-next-line max-len
              exp.l('About <span class="color-purple">Music</span><span class="color-orange">Brainz</span>')
            }
          </h3>
          <p>
            {l(
              `MusicBrainz is an open music encyclopedia that collects
               music metadata and makes it available to the public.`,
            )}
          </p>
          <p>
            {l('MusicBrainz aims to be:')}
          </p>
          <ul className="p-0">
            <li className="pb-4">
              <FontAwesomeIcon
                icon={faCheckCircle}
                size="lg"
              />
              {' '}
              {exp.l(
                `<strong>The ultimate source of music information</strong>
                 by allowing anyone to contribute and releasing the {doc|data}
                 under {doc2|open licenses}.`,
                {
                  doc: '/doc/MusicBrainz_Database',
                  doc2: '/doc/About/Data_License',
                },
              )}
            </li>
            <li className="pb-4">
              <FontAwesomeIcon
                icon={faCheckCircle}
                size="lg"
              />
              {' '}
              {exp.l(
                `<strong>The universal lingua franca for music</strong>
                 by providing a reliable and unambiguous form of
                 {doc|music identification}, enabling both people and machines
                 to have meaningful conversations about music.`,
                {
                  doc: '/doc/MusicBrainz_Identifier',
                },
              )}
            </li>
            <li>
              <FontAwesomeIcon
                icon={faCheckCircle}
                size="lg"
              />
              {' '}
              {exp.l(
                `Like Wikipedia, MusicBrainz is maintained by a global
                 community of users and we want everyone &#x2014;
                 including you &#x2014; to {doc|participate and contribute}.`,
                {
                  doc: '/doc/How_to_Contribute',
                },
              )}
            </li>
          </ul>
        </div>
        <iframe
          allow="autoplay; encrypted-media"
          allowFullScreen
          className="col-lg-6"
          src="https://www.youtube.com/embed/-CVNe9gmG6c"
          title="video"
        />
      </div>
    </div>
  </section>
);

export default About;
