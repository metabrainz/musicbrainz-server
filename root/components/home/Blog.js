/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import he from 'he';
import * as React from 'react';
import {faTwitter} from '@fortawesome/free-brands-svg-icons';
import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import {faBlog} from '@fortawesome/free-solid-svg-icons';

const Blog = ({
  blogEntries,
}: Props): React.Element<'div'> => {
  return (
    <div className="card">
      <div className="card-body">
        <h5 className="card-title text-center fs-3">
          {l('News & Updates')}
        </h5>
      </div>
      <ul>
        {blogEntries.slice(0, 6).map(item => (
          <li
            className="list-group-item"
            key={item.url}
          >
            <a
              className="card-link fs-4"
              href={item.url}
              rel="noopener noreferrer"
              target="_blank"
            >
              {he.decode(item.title)}
            </a>
          </li>
        ))}
      </ul>
      <div
        className="card-body align-items-center d-flex justify-content-center"
      >
        <a
          className="card-link"
          href="https://twitter.com/MusicBrainz"
          rel="noopener noreferrer"
          target="_blank"
        >
          <FontAwesomeIcon
            className="me-2"
            icon={faTwitter}
            size="lg"
          />
          {l('Twitter')}
        </a>
        <a
          className="card-link"
          href="https://blog.metabrainz.org"
          rel="noopener noreferrer"
          target="_blank"
        >
          <FontAwesomeIcon
            className="me-2"
            icon={faBlog}
            size="lg"
          />
          {l('Blog')}
        </a>
        <a
          className="card-link fs-5"
          href="https://community.metabrainz.org"
          rel="noopener noreferrer"
          target="_blank"
        >
          {l('Community Forum')}
        </a>
      </div>
    </div>
  );
};

export default Blog;
