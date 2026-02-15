# Feature: OCR Support for Image-Based PDFs

**Date:** 24 December 2025
**Commit:** 58e7a1e
**Status:** Implemented

## Overview

ChaSen AI now supports automatic OCR (Optical Character Recognition) for image-based or scanned PDF documents. Previously, these documents would return minimal or no text, making analysis impossible. Now, Tesseract.js is used to extract text from PDF page images.

## Problem Statement

Users uploading scanned PDFs or image-based PDFs (e.g., meeting agendas, invoices, contracts) received the error message:

> "This PDF appears to be image-based or scanned. Text extraction was limited."

ChaSen could not analyse these documents because standard PDF parsing only extracts embedded text, not text rendered as images.

## Solution

Implemented a two-stage PDF processing pipeline:

### Stage 1: Standard Extraction

- Use `pdf-parse` to extract embedded text
- Calculate words per page ratio
- If ratio < 10 words/page, classify as "image-based"

### Stage 2: OCR Fallback (for image-based PDFs)

- Convert PDF pages to PNG images using `pdf-to-img`
- Run Tesseract.js OCR on each page image
- Combine extracted text from all pages
- Mark document with `ocrApplied: true`

## Technical Implementation

### Dependencies Added

```json
{
  "tesseract.js": "^7.0.0",
  "pdf-to-img": "^5.0.0"
}
```

### Files Modified

1. **`src/lib/document-parser.ts`**
   - Added `performOCROnPDF()` function
   - Updated `parsePDFFile()` to use OCR fallback
   - Added `ocrApplied` field to `ParsedDocument` interface

2. **`src/app/api/chasen/upload/route.ts`**
   - Added `ocrApplied` to API response
   - Updated success message to mention OCR when applied

3. **`src/app/(dashboard)/ai/page.tsx`**
   - Updated `uploadedDocuments` state type to include `ocrApplied`
   - Added amber "OCR" badge to file chips for OCR-processed documents
   - Updated toast message to show "(OCR applied)" suffix

## Performance Considerations

- OCR is limited to first 10 pages to prevent timeout
- Images rendered at 2x scale for better OCR accuracy
- Progress logging shows per-page completion percentage
- Graceful fallback if OCR fails (shows partial text if available)

## User Experience

### Before

- Image-based PDF uploaded
- Error message shown
- ChaSen unable to analyse

### After

- Image-based PDF uploaded
- Toast shows "Uploaded: document.pdf (OCR applied)"
- File chip displays amber "OCR" badge
- ChaSen can fully analyse the document content

## Limitations

1. **Processing Time**: OCR takes 5-30 seconds depending on page count and complexity
2. **Accuracy**: OCR accuracy depends on scan quality; poor scans may have errors
3. **Complex Layouts**: Tables, multi-column layouts may not preserve structure
4. **Handwriting**: Limited support for handwritten text (printed text works best)
5. **Languages**: Currently configured for English only (`eng` language model)

## Future Enhancements

1. Add multi-language OCR support
2. Implement table detection and structure preservation
3. Add progress indicator in UI during OCR processing
4. Consider cloud OCR (Google Vision/AWS Textract) for higher accuracy option
5. Cache OCR results to avoid re-processing same documents

## Testing

To test OCR functionality:

1. Upload a scanned PDF document
2. Verify toast shows "(OCR applied)"
3. Verify amber "OCR" badge appears on file chip
4. Ask ChaSen to analyse the document
5. Verify extracted text is accurate and usable
