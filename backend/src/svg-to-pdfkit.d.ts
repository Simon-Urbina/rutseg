declare module 'svg-to-pdfkit' {
  import type PDFDocument from 'pdfkit'

  interface SVGtoPDFOptions {
    width?: number
    height?: number
    preserveAspectRatio?: string
    assumePt?: boolean
    precision?: number
  }

  export default function SVGtoPDF(
    doc: PDFDocument,
    svg: string,
    x: number,
    y: number,
    options?: SVGtoPDFOptions,
  ): PDFDocument
}
