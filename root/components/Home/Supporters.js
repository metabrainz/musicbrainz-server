export default function Supporters(props) {
  return (
    <section
      className={'section-with-bg ' + props.theme}
      id="supporters"
    >
      <div className="container" data-bs-aos="fade-up">
        <div className="section-header">
          <h2>{l(`Supporters`)}</h2>
        </div>
        <div
          className="row no-gutters supporters-wrap clearfix"
          data-bs-aos="zoom-in"
          data-bs-aos-delay="100"
        >
          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="Google"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/google.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="BBC"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/bbc.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="Plex"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/plex.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="LastFM"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/lastfm.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="Microsoft"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/microsoft.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="Pandora"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/pandora.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="Hubbard"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/acoustid.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="Amazon"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/amazon.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="Ticket Master"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/ticketmaster.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="Umg"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/umg.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="SiriusXM"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/siriusxm.svg"
                width="141"
              />
            </div>
          </div>

          <div className="col-lg-3 col-md-4 col-xs-6">
            <div className="supporter-logo">
              <img
                alt="MC"
                className="img-thumbnail"
                height="50"
                src="/assets/img/supporters/mc.svg"
                width="141"
              />
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
