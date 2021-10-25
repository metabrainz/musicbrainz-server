import React from 'react'
import { BrowserMultiFormatReader, Result } from '@zxing/library'
import Webcam from 'react-webcam'

const BarcodeScanner = ({width, height, onUpdate}: {
    width: number;
    height: number;
    onUpdate: (arg0: unknown, arg1?: Result) => void;
}): React.ReactElement => {
    const webcamRef = React.useRef<Webcam>(null)
    const codeReader = new BrowserMultiFormatReader()

    const capture = React.useCallback(
        () => {
            const imageSrc = webcamRef?.current?.getScreenshot()
            if (imageSrc) {
                codeReader.decodeFromImage(undefined, imageSrc).then(result => {
                    onUpdate(null, result)
                }).catch((err) => {
                    onUpdate(err)
                })
            }
        },
        [codeReader, onUpdate]
    )

    React.useEffect(() => {
        setInterval(capture, 100)
    }, [capture]);

    return (
        <Webcam
            width={width}
            height={height}
            ref={webcamRef}
            screenshotFormat="image/png"
            videoConstraints={{
                facingMode: 'environment'
            }}
        />
    )
}

export default BarcodeScanner