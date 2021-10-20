import React from "react";

function Facts(props) {
    let theme;
    if (props.isDarkThemeActive) {
        theme = "counts theme-dark";
    } else {
        theme = "counts theme-light";
    }

    return(
        <section id="counts" className={theme}>
            <div className="container" data-aos="fade-up">

                <div className="row gy-4">

                    <div className="col-lg-3 col-md-6">
                        <div className="count-box">
                            <i className="bi bi-music-note-list"/>
                            <div>
                                <span>1.88 M</span>
                                <p>Artists</p>
                            </div>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-6">
                        <div className="count-box">
                            <i className="bi bi-journal-richtext"/>
                            <div>
                                <span>3.00 M</span>
                                <p>Releases</p>
                            </div>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-6">
                        <div className="count-box">
                            <i className="bi bi-headset"/>
                            <div>
                                <span>35.20 M</span>
                                <p>Tracks</p>
                            </div>
                        </div>
                    </div>

                    <div className="col-lg-3 col-md-6">
                        <div className="count-box">
                            <i className="bi bi-people"/>
                            <div>
                                <span>2.18 M</span>
                                <p>Editors</p>
                            </div>
                        </div>
                    </div>

                </div>

            </div>
        </section>
    )
}
export default Facts;