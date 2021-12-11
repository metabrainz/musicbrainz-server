/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function Supporters(props) {
  return (
    <section className={'section-with-bg ' + props.theme} id="supporters">

      <div className="container" data-bs-aos="fade-up">
        <div className="section-header">
          <h2>Supporters</h2>
        </div>

        <div className="row no-gutters supporters-wrap clearfix" data-bs-aos="zoom-in" data-bs-aos-delay="100">

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/google.svg" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/bbc.svg" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/plex.svg" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/lastfm.svg" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/microsoft.png" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/pandora.png" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/hubbard.png" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/Amazon_logo.svg" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/ticketmaster.svg" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/umg.svg" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/siriusxm.jpg" />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img alt="" className="img-thumbnail" src="../../../../static/images/supporters/mc.svg" />
            </div>
          </div>

        </div>

      </div>

    </section>
  );
}
