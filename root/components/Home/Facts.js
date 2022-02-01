/*
 * @flow strict-local
 * Copyright (C) 2021 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

function Facts(props) {
  return (
    <section className={'counts ' + props.theme} id="counts">
      <div className="container" data-bs-aos="fade-up">

        <div className="row gy-4">

          <div className="col-lg-3 col-md-6">
            <div className="count-box">
              <i className="bi bi-music-note-list" />
              <div>
                <span>
                  {l(`1.88 M`)}
                </span>
                <p>
                  {l(`Artists`)}
                </p>
              </div>
            </div>
          </div>

          <div className="col-lg-3 col-md-6">
            <div className="count-box">
              <i className="bi bi-journal-richtext" />
              <div>
                <span>
                  {l(`3.00 M`)}
                </span>
                <p>
                  {l(`Releases`)}
                </p>
              </div>
            </div>
          </div>

          <div className="col-lg-3 col-md-6">
            <div className="count-box">
              <i className="bi bi-headset" />
              <div>
                <span>
                  {l(`35.20 M`)}
                </span>
                <p>
                  {l(`Tracks`)}
                </p>
              </div>
            </div>
          </div>

          <div className="col-lg-3 col-md-6">
            <div className="count-box">
              <i className="bi bi-people" />
              <div>
                <span>
                  {l(`2.18 M`)}
                </span>
                <p>
                  {l(`Editors`)}
                </p>
              </div>
            </div>
          </div>

        </div>

      </div>
    </section>
  );
}
export default (hydrate(
  'div.facts',
  Facts,
): React.AbstractComponent<{}, void>);
