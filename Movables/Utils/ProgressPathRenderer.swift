//
//  ProgressPathRenderer.swift
//  Movables
//
//  MIT License
//
//  Copyright (c) 2018 Eddie Chen
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import MapKit

private func LineBetweenPointsIntersectsRect(_ p0: MKMapPoint, _ p1: MKMapPoint, _ r:MKMapRect) -> Bool {
    let minX = min(p0.x, p1.x)
    let minY = min(p0.y, p1.y)
    let maxX = max(p0.x, p1.x)
    let maxY = max(p0.y, p1.y)
    
    let r2 = MKMapRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    return r.intersects(r2)
}


private func pow2<T: Computable>(_ a: T) -> T {
    return a * a
}

@objc(ProgressPathRenderer)
class ProgressPathRenderer: MKOverlayRenderer {
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let progresss = self.overlay as! ProgressPath

        let lineWidth = MKRoadWidthAtZoomScale(zoomScale)
        
        // outset the map rect by the line width so that points just outside
        // of the currently drawn rect are included in the generated path.
        let clipRect = mapRect.insetBy(dx: Double(-lineWidth), dy: Double(-lineWidth))
        
        var path: CGPath?
        progresss.readPointsWithBlockAndWait {points in
            path = self.newPathForPoints(points,
                                         clipRect: clipRect,
                                         zoomScale: zoomScale)
        }
        
        if let path = path {
            context.addPath(path)
            context.setStrokeColor(Theme().keyTint.cgColor)
            context.setLineJoin(.round)
            context.setLineCap(.round)
            context.setLineWidth(lineWidth)
            context.strokePath()
            context.scaleBy(x: 1, y: -1)
//            context.translateBy(x: 0.0, y: -mapRect.size.height)
        }
    }
    
    
    //MARK: - Private Implementation
    
    private func newPathForPoints(_ points: [MKMapPoint],
                                  clipRect mapRect: MKMapRect,
                                  zoomScale: MKZoomScale) -> CGPath? {
        
        // The fastest way to draw a path in an MKOverlayView is to simplify the
        // geometry for the screen by eliding points that are too close together
        // and to omit any line segments that do not intersect the clipping rect.
        // While it is possible to just add all the points and let CoreGraphics
        // handle clipping and flatness, it is much faster to do it yourself:
        //
        guard points.count > 1 else {
            return nil
        }
        let path = CGMutablePath()
        
        var needsMove = true
        
        // Calculate the minimum distance between any two points by figuring out
        // how many map points correspond to MIN_POINT_DELTA of screen points
        // at the current zoomScale.
        let MIN_POINT_DELTA = 5.0
        let minPointDelta = MIN_POINT_DELTA / Double(zoomScale)
        let c2 = pow2(minPointDelta)
        
        var lastPoint = points[0]
        for i in 1..<points.count - 1 {
            let point = points[i]
            let a2b2 = pow2(point.x - lastPoint.x) + pow2(point.y - lastPoint.y)
            if a2b2 >= c2 {
                if LineBetweenPointsIntersectsRect(point, lastPoint, mapRect) {
                    if needsMove {
                        let lastCGPoint = self.point(for: lastPoint)
                        path.move(to: lastCGPoint)
                    }
                    let cgPoint = self.point(for: point)
                    path.addLine(to: cgPoint)
                    needsMove = false
                } else {
                    // discontinuity, lift the pen
                    needsMove = true
                }
                lastPoint = point
            }
        }
        
        // If the last line segment intersects the mapRect at all, add it unconditionally
        let point = points.last!
        if LineBetweenPointsIntersectsRect(point, lastPoint, mapRect) {
            if needsMove {
                let lastCGPoint = self.point(for: lastPoint)
                path.move(to: lastCGPoint)
            }
            let cgPoint = self.point(for: point)
            path.addLine(to: cgPoint)
        }
        return path
        
    }
    
}

