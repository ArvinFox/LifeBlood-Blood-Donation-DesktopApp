import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_filex/open_filex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';
import 'dart:ui'; 

class MedicalReport {
  final String? id;
  final String donorName;
  final String reportType;
  final String status;
  final DateTime date;
  final String filePath;

  MedicalReport({
    this.id,
    required this.donorName,
    required this.reportType,
    required this.status,
    required this.date,
    required this.filePath,
  });

  factory MedicalReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicalReport(
      id: doc.id,
      donorName: data['donorName'] ?? '',
      reportType: data['reportType'] ?? '',
      status: data['status'] ?? 'Pending',
      date: (data['date'] as Timestamp).toDate(),
      filePath: data['filePath'] ?? '',
    );
  }
}

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Uint8List> downloadFile(String filePath) async {
    try {
      return await _supabase.storage
          .from('medical-reports')
          .download(filePath);
    } on StorageException catch (e) {
      throw Exception('Download error: ${e.message}');
    }
  }
}

class MedicalReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MedicalReport>> getReports() {
    return _firestore
        .collection('medical_reports')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalReport.fromFirestore(doc))
            .toList());
  }

  Future<void> updateReportStatus(String reportId, String newStatus) async {
    await _firestore
        .collection('medical_reports')
        .doc(reportId)
        .update({'status': newStatus});
  }
}

class MedicalReportsPage extends StatefulWidget {
  const MedicalReportsPage({super.key});

  @override
  State<MedicalReportsPage> createState() => _MedicalReportsPageState();
}

class _MedicalReportsPageState extends State<MedicalReportsPage> {
  final TextEditingController reportIdController = TextEditingController();
  final TextEditingController donorNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? selectedStatus;

  String filterReportId = '';
  String filterDonorName = '';
  String? filterStatus;
  String filterDate = '';

  final List<String> statuses = ['Pending', 'Approved', 'Rejected'];
  final MedicalReportService _reportService = MedicalReportService();
  final SupabaseService _supabaseService = SupabaseService();

  Future<void> _selectDate(BuildContext context) async {
    DateTime? initialDate = DateTime.now();
    if (dateController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('yyyy-MM-dd').parse(dateController.text);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      barrierColor: Colors.transparent,
      builder: (context, child) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            child!,
          ],
        );
      },
    );


    if (picked != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void resetFilters() {
    reportIdController.clear();
    donorNameController.clear();
    dateController.clear();
    setState(() {
      selectedStatus = null;
      filterReportId = '';
      filterDonorName = '';
      filterStatus = null;
      filterDate = '';
    });
  }

  void searchReports() {
    String dateStr = dateController.text;
    String formattedDate = '';
    if (dateStr.isNotEmpty) {
      try {
        final parsedDate = DateFormat('yyyy-MM-dd').parse(dateStr);
        formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid date format. Use YYYY-MM-DD.')),
        );
        return;
      }
    }

    setState(() {
      filterReportId = reportIdController.text;
      filterDonorName = donorNameController.text;
      filterStatus = selectedStatus;
      filterDate = formattedDate;
    });
  }

  Future<void> _viewReport(MedicalReport report) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Downloading report...')),
      );

      final String fullFilePath = '${report.id}/${report.filePath}';
      final fileBytes = await _supabaseService.downloadFile(fullFilePath);
      final fileName = report.filePath.split('/').last;

      final path = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: fileBytes,
        ext: fileName.split('.').last,
      );

      if (path != null) {
        await OpenFilex.open(path);
      }

      scaffoldMessenger.hideCurrentSnackBar();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Medical Reports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text(
                  'Filter Options',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: reportIdController,
                          decoration: const InputDecoration(
                            labelText: "Report ID",
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: donorNameController,
                          decoration: const InputDecoration(
                            labelText: "Donor Name",
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: "Status",
                          ),
                          items: statuses.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value;
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: dateController,
                              decoration: const InputDecoration(
                                labelText: "Date (YYYY-MM-DD)",
                                suffixIcon: Icon(Icons.calendar_today),
                              ),
                              readOnly: true,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: resetFilters,
                                child: const Text("Reset Filters"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: searchReports,
                                child: const Text("Search"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<List<MedicalReport>>(
                  stream: _reportService.getReports(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    
                    final allReports = snapshot.data ?? [];
                    final filteredReports = allReports.where((report) {
                      bool matchesId = filterReportId.isEmpty ||
                          (report.id ?? '').toLowerCase().contains(filterReportId.toLowerCase());
                      bool matchesName = filterDonorName.isEmpty ||
                          report.donorName.toLowerCase().contains(filterDonorName.toLowerCase());
                      bool matchesStatus = filterStatus == null || report.status == filterStatus;
                      bool matchesDate = filterDate.isEmpty || 
                          DateFormat('yyyy-MM-dd').format(report.date) == filterDate;

                      return matchesId && matchesName && matchesStatus && matchesDate;
                    }).toList();

                    return ListView.separated(
                      itemCount: filteredReports.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        final isApproved = report.status == 'Approved';
                        final isRejected = report.status == 'Rejected';

                        return Card(
                          elevation: 3,
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Report ID: ${report.id}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(report.status)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        report.status,
                                        style: TextStyle(
                                          color: _getStatusColor(report.status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow("Donor Name", report.donorName),
                                _buildInfoRow("Report Type", report.reportType),
                                _buildInfoRow("Date", 
                                    DateFormat('yyyy-MM-dd').format(report.date)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _viewReport(report),
                                        child: const Text("View Report"),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isApproved
                                              ? Colors.green.withOpacity(0.5)
                                              : Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: isApproved
                                            ? null
                                            : () => _reportService.updateReportStatus(
                                                report.id!, 'Approved'),
                                        child: const Text("Approve"),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isRejected
                                              ? Colors.red.withOpacity(0.5)
                                              : Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: isRejected
                                            ? null
                                            : () => _reportService.updateReportStatus(
                                                report.id!, 'Rejected'),
                                        child: const Text("Reject"),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
