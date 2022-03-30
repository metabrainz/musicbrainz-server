/*
 * @flow strict
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

const Explore = (): React.Element<'section'> => (
  <section className="bs" id="explore">
    <div className="container-fluid pt-4 pb-4">
      <div className="text-center pt-4">
        <h2 className="mb-2 pb-2 text-uppercase fs-1 fw-bold">
          {l('Explore MusicBrainz')}
        </h2>
      </div>
      <div className="row">
        <div className="col-md-6">
          <div className="card p-4 m-4 shadow">
            <div className="card-body">
              <h5 className="text-center mb-4 fs-3 fw-bold">
                <a
                  href="https://community.metabrainz.org"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Community')}
                </a>
              </h5>
              <p className="card-text fs-4">
                {l(`
                  The forums are where our global community of users 
                  meet for discussions about the project. 
                  We invite you to join if you have any questions or comments!
                `)}
              </p>
            </div>
          </div>
        </div>
        <div className="col-md-6 d-flex">
          <div className="card p-4 m-4 shadow">
            <div className="card-body">
              <h5 className="text-center mb-4 fs-3 fw-bold">
                <a
                  href="/doc/Development"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Development')}
                </a>
              </h5>
              <p className="card-text fs-4">
                {l(`
                  Our developer resources will help you make
                  use of our data or contribute code. 
                  If you want to run a mirror server,
                  our live data feed will keep
                  your local database in sync.
                `)}
              </p>
            </div>
          </div>
        </div>
        <div className="col-md-6 d-flex">
          <div className="card p-4 m-4 shadow">
            <div className="card-body">
              <h5 className="text-center mb-4 fs-3 fw-bold">
                <a
                  href="/doc/About/History"
                  rel="noopener noreferrer"
                  target="_blank"
                >

                  {l('History')}
                </a>
              </h5>
              <p className="card-text fs-4">
                {l(`
                  MusicBrainz was founded in 2000 as a 
                  free open music database. The project has 
                  since grown from a basic database for 
                  CDs to a large, encyclopedic source 
                  of music information maintained by an 
                  international community of enthusiasts 
                  that appreciate both music and music metadata.
                `)}
              </p>
            </div>
          </div>
        </div>

        <div className="col-md-6 d-flex">
          <div className="card p-4 m-4 shadow">
            <div className="card-body">
              <h5 className="text-center mb-4 fs-3 fw-bold">
                <a
                  href="/doc/MusicBrainz_Database"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('The Database')}
                </a>
              </h5>
              <p className="card-text fs-4">
                {exp.l(`
                  The MusicBrainz Database stores all of the
                  various pieces of information we collect
                  about music, from artists and their
                  releases to works and their composers,
                  and much more.
                  If you are interested in using this 
                  data in your organization, 
                  please {meb_signup|get in touch}. 
                  Our data is available for commercial licensing.
                `,
                       {
                         meb_signup: 'https://metabrainz.org/supporters/account-type',
                       })}
              </p>
            </div>
          </div>
        </div>
        <div className="col-md-6 d-flex">
          <div className="card p-4 m-4 shadow">
            <div className="card-body">
              <h5 className="text-center mb-4 fs-3 fw-bold">
                <a
                  href="/doc/Editing_FAQ"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Breadth')}
                </a>
              </h5>
              <p className="card-text fs-4">
                {l(`
                  MusicBrainz exists to collect as much
                  information about music as we can. We do not
                  discriminate or prefer one type of
                  music over another. Whether it is published or
                  unpublished, popular or fringe, Western or non-Western,
                  human or non-human — we want it all in MusicBrainz.
                `)}
              </p>
            </div>
          </div>
        </div>
        <div className="col-md-6 d-flex">
          <div className="card p-4 m-4 shadow">
            <div className="card-body">
              <h5 className="text-center mb-4 fs-3 fw-bold">
                <a
                  href="/doc/How_Editing_Works"
                  rel="noopener noreferrer"
                  target="_blank"
                >
                  {l('Editing Philosophy')}
                </a>
              </h5>
              <p className="card-text fs-4">
                {l(`
                  Maintaining a comprehensive database of all types
                  of music is a large task, and MusicBrainz depends 
                  on its users not just to add the data, 
                  but also to spot mistakes and correct them.
                  Our editing and voting systems give users 
                  the ability to both update the data 
                  and review each others’ changes.
                `)}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
);

export default Explore;
