/*
 * @flow strict-local
 * Copyright (C) 2022 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

export default function Facts(props) {
  return (
    <section className={'counts ' + props.theme} id="counts">
      <div className="container" data-bs-aos="fade-up">

        <div className="row gy-4">

          <div className="col-lg-3 col-md-6">
            <div className="count-box">
              <i className="bi bi-music-note-list" />
              <div>
                <span>1.88 M</span>
                <p>Artists</p>
              </div>
            </div>
          </div>

          <div className="col-lg-3 col-md-6">
            <div className="count-box">
              <i className="bi bi-journal-richtext" />
              <div>
                <span>3.00 M</span>
                <p>Releases</p>
              </div>
            </div>
          </div>

          <div className="col-lg-3 col-md-6">
            <div className="count-box">
              <i className="bi bi-headset" />
              <div>
                <span>35.20 M</span>
                <p>Tracks</p>
              </div>
            </div>
          </div>

          <div className="col-lg-3 col-md-6">
            <div className="count-box">
              <i className="bi bi-people" />
              <div>
                <span>2.18 M</span>
                <p>Editors</p>
              </div>
            </div>
          </div>

        </div>

      </div>
    </section>
  );
}
