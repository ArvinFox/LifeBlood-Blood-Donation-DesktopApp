import 'package:blood_donation_app/models/medical_report_model.dart';
import 'package:blood_donation_app/services/medical_report_service.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReportViewerScreen extends StatefulWidget {
  final MedicalReport report;
  final Uint8List fileBytes;

  const ReportViewerScreen({
    super.key, 
    required this.report, 
    required this.fileBytes,
  });

  @override
  State<ReportViewerScreen> createState() => _ReportViewerScreenState();
}

class _ReportViewerScreenState extends State<ReportViewerScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final MedicalReportService _reportService = MedicalReportService();

  int _totalPages = 0;

  bool _isApproved = false;
  bool _isRejected = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      _isApproved = widget.report.status == 'Approved';
      _isRejected = widget.report.status == 'Rejected';
    });
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String fileName = widget.report.filePath.split('/').last;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report ID: ${widget.report.reportId}', 
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Donor: ${widget.report.donorName}', 
              style: const TextStyle(
                fontSize: 14, 
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                side: BorderSide(color: Colors.white)
              ),
              icon: const Icon(Icons.download,color: Colors.white),
              label: const Text('Download', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final rawFileName = fileName.split('.').first;
                final fileExtension = fileName.split('.').last;

                final path = await FileSaver.instance.saveFile(
                  name: rawFileName,
                  bytes: widget.fileBytes,
                  ext: fileExtension,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Downloaded to: $path")),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_in),
                    onPressed: () {
                      _pdfController.zoomLevel += 0.25;
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_out),
                    onPressed: () {
                      _pdfController.zoomLevel = (_pdfController.zoomLevel - 0.25).clamp(1.0, 5.0);
                    },
                  ),
                  const SizedBox(width: 16),
                  Text('${_pdfController.pageNumber} / $_totalPages'),
                ],
              ),
            ),
          ),

          // PDF Viewer
          Expanded(
            child: SfPdfViewer.memory(
              widget.fileBytes,
              controller: _pdfController,
              onDocumentLoaded: (details) {
                setState(() {
                  _totalPages = details.document.pages.count;
                });
              },
              onPageChanged: (details) {
                setState(() {});  // to update the page number
              },
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _isApproved
                    ? null
                    : () {
                      _reportService.updateReportStatus(
                        widget.report.reportId, 'Approved'
                      );

                      setState(() {
                        _isApproved = true;
                        _isRejected = false;
                      });
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isRejected
                    ? null
                    : () {
                      _reportService.updateReportStatus(
                        widget.report.reportId, 'Rejected'
                      );

                      setState(() {
                        _isApproved = false;
                        _isRejected = true;
                      });
                    },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}