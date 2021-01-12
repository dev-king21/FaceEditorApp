import UIKit

public extension UIImage {

    var pixelWidth: Int {
        return cgImage?.width ?? 0
    }

    var pixelHeight: Int {
        return cgImage?.height ?? 0
    }

    /// Resizes an image to the specified size.
    ///
    /// - Parameters:
    ///     - size: the size we desire to resize the image to.
    ///
    /// - Returns: the resized image.
    ///
    func imageWithSize(size: CGSize) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale);
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height);
        draw(in: rect)

        let resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return resultingImage
    }

    /// Resizes an image to the specified size and adds an extra transparent margin at all sides of
    /// the image.
    ///
    /// - Parameters:
    ///     - size: the size we desire to resize the image to.
    ///     - extraMargin: the extra transparent margin to add to all sides of the image.
    ///
    /// - Returns: the resized image.  The extra margin is added to the input image size.  So that
    ///         the final image's size will be equal to:
    ///         `CGSize(width: size.width + extraMargin * 2, height: size.height + extraMargin * 2)`
    ///
    func imageWithSize(size: CGSize, extraMargin: CGFloat) -> UIImage? {

        let imageSize = CGSize(width: size.width + extraMargin * 2, height: size.height + extraMargin * 2)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale);
        let drawingRect = CGRect(x: extraMargin, y: extraMargin, width: size.width, height: size.height)
        draw(in: drawingRect)

        let resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return resultingImage
    }

    /// Resizes an image to the specified size.
    ///
    /// - Parameters:
    ///     - size: the size we desire to resize the image to.
    ///     - roundedRadius: corner radius
    ///
    /// - Returns: the resized image with rounded corners.
    ///
    func imageWithSize(size: CGSize, roundedRadius radius: CGFloat) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        if let currentContext = UIGraphicsGetCurrentContext() {
            let rect = CGRect(origin: .zero, size: size)
            currentContext.addPath(UIBezierPath(roundedRect: rect,
                                                byRoundingCorners: .allCorners,
                                                cornerRadii: CGSize(width: radius, height: radius)).cgPath)
            currentContext.clip()

            //Don't use CGContextDrawImage, coordinate system origin in UIKit and Core Graphics are vertical oppsite.
            draw(in: rect)
            currentContext.drawPath(using: .fillStroke)
            let roundedCornerImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return roundedCornerImage
        }
        return nil
    }

    func rotate(angle: CGFloat) -> UIImage {
        let radians = angle * 3.14/180
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }

//////////////////////////////////////////////////////////

        func pixelColor(x: Int, y: Int) -> UIColor {
            assert(
                0..<pixelWidth ~= x && 0..<pixelHeight ~= y,
                "Pixel coordinates are out of bounds")

            guard
                let cgImage = cgImage,
                let data = cgImage.dataProvider?.data,
                let dataPtr = CFDataGetBytePtr(data),
                let colorSpaceModel = cgImage.colorSpace?.model,
                let componentLayout = cgImage.bitmapInfo.componentLayout
            else {
                assertionFailure("Could not get a pixel of an image")
                return .clear
            }

            assert(
                colorSpaceModel == .rgb,
                "The only supported color space model is RGB")
            assert(
                cgImage.bitsPerPixel == 32 || cgImage.bitsPerPixel == 24,
                "A pixel is expected to be either 4 or 3 bytes in size")

            let bytesPerRow = cgImage.bytesPerRow
            let bytesPerPixel = cgImage.bitsPerPixel/8
            let pixelOffset = y*bytesPerRow + x*bytesPerPixel

            if componentLayout.count == 4 {
                let components = (
                    dataPtr[pixelOffset + 0],
                    dataPtr[pixelOffset + 1],
                    dataPtr[pixelOffset + 2],
                    dataPtr[pixelOffset + 3]
                )

                var alpha: UInt8 = 0
                var red: UInt8 = 0
                var green: UInt8 = 0
                var blue: UInt8 = 0

                switch componentLayout {
                case .bgra:
                    alpha = components.3
                    red = components.2
                    green = components.1
                    blue = components.0
                case .abgr:
                    alpha = components.0
                    red = components.3
                    green = components.2
                    blue = components.1
                case .argb:
                    alpha = components.0
                    red = components.1
                    green = components.2
                    blue = components.3
                case .rgba:
                    alpha = components.3
                    red = components.0
                    green = components.1
                    blue = components.2
                default:
                    return .clear
                }

                // If chroma components are premultiplied by alpha and the alpha is `0`,
                // keep the chroma components to their current values.
                if cgImage.bitmapInfo.chromaIsPremultipliedByAlpha && alpha != 0 {
                    let invUnitAlpha = 255/CGFloat(alpha)
                    red = UInt8((CGFloat(red)*invUnitAlpha).rounded())
                    green = UInt8((CGFloat(green)*invUnitAlpha).rounded())
                    blue = UInt8((CGFloat(blue)*invUnitAlpha).rounded())
                }

                return .init(red: red, green: green, blue: blue, alpha: alpha)

            } else if componentLayout.count == 3 {
                let components = (
                    dataPtr[pixelOffset + 0],
                    dataPtr[pixelOffset + 1],
                    dataPtr[pixelOffset + 2]
                )

                var red: UInt8 = 0
                var green: UInt8 = 0
                var blue: UInt8 = 0

                switch componentLayout {
                case .bgr:
                    red = components.2
                    green = components.1
                    blue = components.0
                case .rgb:
                    red = components.0
                    green = components.1
                    blue = components.2
                default:
                    return .clear
                }

                return .init(red: red, green: green, blue: blue, alpha: UInt8(255))

            } else {
                assertionFailure("Unsupported number of pixel components")
                return .clear
            }
        }

    }

    public extension UIColor {

        convenience init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
            self.init(
                red: CGFloat(red)/255,
                green: CGFloat(green)/255,
                blue: CGFloat(blue)/255,
                alpha: CGFloat(alpha)/255)
        }

    }

    public extension CGBitmapInfo {

        enum ComponentLayout {

            case bgra
            case abgr
            case argb
            case rgba
            case bgr
            case rgb

            var count: Int {
                switch self {
                case .bgr, .rgb: return 3
                default: return 4
                }
            }

        }

        var componentLayout: ComponentLayout? {
            guard let alphaInfo = CGImageAlphaInfo(rawValue: rawValue & Self.alphaInfoMask.rawValue) else { return nil }
            let isLittleEndian = contains(.byteOrder32Little)

            if alphaInfo == .none {
                return isLittleEndian ? .bgr : .rgb
            }
            let alphaIsFirst = alphaInfo == .premultipliedFirst || alphaInfo == .first || alphaInfo == .noneSkipFirst

            if isLittleEndian {
                return alphaIsFirst ? .bgra : .abgr
            } else {
                return alphaIsFirst ? .argb : .rgba
            }
        }

        var chromaIsPremultipliedByAlpha: Bool {
            let alphaInfo = CGImageAlphaInfo(rawValue: rawValue & Self.alphaInfoMask.rawValue)
            return alphaInfo == .premultipliedFirst || alphaInfo == .premultipliedLast
        }




}
