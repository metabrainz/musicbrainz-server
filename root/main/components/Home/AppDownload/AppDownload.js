export default function AppDownload(props) {
    return(
        <section className={"section cta-section "+props.theme}>
            <div className="container">
                <div className="row align-items-center">
                    <div className="col-md-6 me-auto text-center text-md-start mb-5 mb-md-0">
                        <h2>Download and Use our App and Software</h2>
                    </div>
                    <div className="col-md-5 text-center text-md-end">
                        <a href="https://play.google.com/store/apps/details?id=org.metabrainz.android" target="_blank" rel="noopener noreferrer" className="btn d-inline-flex align-items-center">
                            <i className="fab fa-google-play"/><span>Google play</span>
                        </a>
                        <a href="https://f-droid.org/en/packages/org.metabrainz.android/" target="_blank" rel="noopener noreferrer" className="btn d-inline-flex align-items-center">
                            <i className="fab fa-android"/><span>F-Droid</span>
                        </a>
                        <a href="https://picard.musicbrainz.org" target="_blank" rel="noopener noreferrer" className="btn d-inline-flex align-items-center">
                            <i className="fa fa-laptop"/><span>PC & Mac</span>
                        </a>
                    </div>
                </div>
            </div>
        </section>
    )
}