//
//  PDF.swift
//  Browser
//
//  Created by Leonardo LarraNaga on 2/4/25.
//

import CoreGraphics
import PDFKit

extension PDFDocument {
    /// Split a long page into multiple pages
    /// - Parameters:
    ///  - pdfData: PDF data to split
    ///  - pageHeight: Height of the new pages, defaults to A4 page height
    static func splitLongDocument(pdfData: Data, pageHeight: CGFloat = 841.89) throws -> Data {
        guard let provider = CGDataProvider(data: pdfData as CFData),
              let originalPDF = CGPDFDocument(provider),
              let firstPage = originalPDF.page(at: 1)
        else { throw "Invalid PDF data" }
        
        let mediaBox = firstPage.getBoxRect(.mediaBox)
        let pageWidth = mediaBox.width
        
        var contextMediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let pageCount = Int(ceil(mediaBox.height / pageHeight))
        
        let newPDFData = NSMutableData()
        guard let consumer = CGDataConsumer(data: newPDFData),
              let context = CGContext(consumer: consumer, mediaBox: &contextMediaBox, nil)
        else { throw "Couldn't get PDF data" }
        
        for i in 0..<pageCount {
            context.beginPDFPage(nil)
            
            let yOffset = mediaBox.height - (CGFloat(i + 1) * pageHeight)
            context.saveGState()
            
            context.translateBy(x: 0, y: -yOffset)
            
            context.drawPDFPage(firstPage)
            
            context.restoreGState()
            context.endPDFPage()
        }
        
        context.closePDF()
        
        return newPDFData as Data
    }
}
