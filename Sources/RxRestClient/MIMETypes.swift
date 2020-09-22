//
//  MIMETypes.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/30/18.
//

import Foundation
#if !os(macOS)
import MobileCoreServices
#endif

public enum MIMETypes: String {
    case `default`
    case css
    case wbmp
    case xls
    case wml
    case tk
    case jad
    case pl
    case mpeg
    case xspf
    case m4a
    case woff
    case img
    case mp4
    case crt
    case m3u8
    case rar
    case tcl
    case ts
    case eot
    case rtf
    case gpp = "3gpp"
    case shtml
    case mng
    case kmz
    case iso
    case jpg
    case bmp
    case wmv
    case txt
    case sit
    case mp3
    case aac
    case wav
    case msi
    case ps
    case xlsx
    case sea
    case png
    case wmlc
    case json
    case zip
    case bin
    case jng
    case pdb
    case war
    case rpm
    case eps
    case dll
    case ai
    case atom
    case xml
    case kar
    case mml
    case asx
    case webp
    case m4v
    case md
    case ppt
    case ico
    case pem
    case mpg
    case webm
    case prc
    case hqx
    case kml
    case gp = "3gp"
    case deb
    case jardiff
    case htc
    case dmg
    case jpeg
    case pptx
    case htm
    case swf
    case msp
    case der
    case doc
    case tiff
    case gif
    case ogg
    case svg
    case pm
    case sevenZ = "7z"
    case tif
    case mov
    case xpi
    case midi
    case exe
    case pdf
    case js
    case svgz
    case run
    case docx
    case rss
    case flv
    case ra
    case msm
    case mid
    case jnlp
    case html
    case avi
    case xhtml
    case asf
    case jar
    case cco
    case ear

    public var mimeType: String {
        return MIMETypes.mimeType(for: self.rawValue)
    }

    public static func mimeType(for ext: String) -> String {

        if let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext as NSString, nil)?.takeRetainedValue() {
            if let mimetype = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType)?.takeRetainedValue() {
                return mimetype as String
            }
        }
        return "application/octet-stream"
    }

}

public extension URL {

    func mimeType() -> MIMETypes {
        return MIMETypes(rawValue: pathExtension) ?? .default
    }

}

public extension NSString {
    func mimeType() -> MIMETypes {
        return MIMETypes(rawValue: pathExtension) ?? .default
    }
}

public extension String {
    func mimeType() -> MIMETypes {
        return (self as NSString).mimeType()
    }
}
