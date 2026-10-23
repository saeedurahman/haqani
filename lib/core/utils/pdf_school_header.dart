import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// True if the bytes start like a PNG or a JPG picture.
bool looksLikePicture(List<int> bytes) {
  final png = bytes.length > 4 && bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47;
  final jpg = bytes.length > 3 && bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
  return png || jpg;
}

/// Reads the school logo for a PDF. Returns null when there is no usable logo,
/// so a missing or damaged logo never stops a print.
Future<pw.ImageProvider?> loadPdfLogo(String? path) async {
  if (path == null) return null;
  try {
    final file = File(path);
    if (!await file.exists()) return null;
    final bytes = await file.readAsBytes();
    return looksLikePicture(bytes) ? pw.MemoryImage(bytes) : null;
  } catch (_) {
    return null;
  }
}

/// School name, address and phone in the middle of the page, with the logo on
/// the left when there is one. Used on the top of receipts, certificates and cards.
pw.Widget pdfCenteredSchoolHeader({
  required String name,
  String address = '',
  String phone = '',
  pw.ImageProvider? logo,
  double nameSize = 24,
  PdfColor nameColor = PdfColors.black,
  PdfColor detailColor = PdfColors.grey700,
  double logoSize = 54,
}) {
  final details = [if (address.isNotEmpty) address, if (phone.isNotEmpty) 'Phone: $phone'].join('   |   ');
  final text = pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Text(
        name,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: nameSize, fontWeight: pw.FontWeight.bold, color: nameColor),
      ),
      if (details.isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 3),
          child: pw.Text(
            details,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: nameSize * 0.43, color: detailColor),
          ),
        ),
    ],
  );
  if (logo == null) return pw.Center(child: text);
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.center,
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.SizedBox(width: logoSize, height: logoSize, child: pw.Image(logo, fit: pw.BoxFit.contain)),
      pw.SizedBox(width: 14),
      pw.Flexible(child: text),
    ],
  );
}
