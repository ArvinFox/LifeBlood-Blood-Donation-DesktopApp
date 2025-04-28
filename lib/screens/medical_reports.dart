import 'package:blood_donation_app/components/search_and_filter.dart';
import 'package:blood_donation_app/models/medical_report_model.dart';
import 'package:blood_donation_app/services/medical_report_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_saver/file_saver.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:ui'; 
import 'package:flutter/services.dart';

class MedicalReportsPage extends StatefulWidget {
  const MedicalReportsPage({super.key});

  @override
  State<MedicalReportsPage> createState() => _MedicalReportsPageState();
}

class _MedicalReportsPageState extends State<MedicalReportsPage> {
  final TextEditingController reportIdController = TextEditingController();
  final TextEditingController donorNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final MedicalReportService _reportService = MedicalReportService();

  final List<String> statuses = ['Pending', 'Approved', 'Rejected'];
  String? selectedStatus;
  String filterReportId = '';
  String filterDonorName = '';
  String? filterStatus;
  String filterDate = '';

  @override
  void dispose() {
    reportIdController.dispose();
    donorNameController.dispose();
    dateController.dispose();
    super.dispose();
  }

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
    if (reportIdController.text.isEmpty && 
      donorNameController.text.isEmpty && 
      selectedStatus == null && 
      dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one filter criteria')),
      );
      return;
    }

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

      final String fullFilePath = '${report.reportId}/${report.filePath}';
      final fileBytes = await _reportService.downloadFile(fullFilePath);
      final fileName = report.filePath.split('/').last;

      final path = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: fileBytes,
        ext: fileName.split('.').last,
      );

      await OpenFilex.open(path);

      scaffoldMessenger.hideCurrentSnackBar();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to process request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                'Medical Reports',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildSearchAndFilter(),
              const SizedBox(height: 20),

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
                          (report.reportId).toLowerCase().contains(filterReportId.toLowerCase());
                      bool matchesName = filterDonorName.isEmpty ||
                          report.donorName.toLowerCase().contains(filterDonorName.toLowerCase());
                      bool matchesStatus = filterStatus == null || report.status == filterStatus;
                      bool matchesDate = filterDate.isEmpty || 
                          DateFormat('yyyy-MM-dd').format(report.date) == filterDate;

                      return matchesId && matchesName && matchesStatus && matchesDate;
                    }).toList();

                    if (filteredReports.isEmpty) {
                      return Center(
                        child: Text(
                          'No medical reports found',
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: filteredReports.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        final isApproved = report.status == 'Approved';
                        final isRejected = report.status == 'Rejected';

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color: const Color.fromARGB(255, 254, 249, 239),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.description, size: 30, color: Colors.blueGrey),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Report ID: ${report.reportId}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Date: ${DateFormat('yyyy-MM-dd').format(report.date)}",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(report.status).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        report.status,
                                        style: TextStyle(
                                          color: _getStatusColor(report.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInfoRow("Donor Name", report.donorName),
                                _buildInfoRow("Report Type", report.reportType),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _viewReport(report),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFAE42),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        icon: const Icon(Icons.visibility),
                                        label: const Text("View Report"),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: isApproved
                                            ? null
                                            : () => _reportService.updateReportStatus(
                                                report.reportId, 'Approved'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isApproved
                                              ? Colors.green.withOpacity(0.5)
                                              : Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        icon: const Icon(Icons.check),
                                        label: const Text("Approve"),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: isRejected
                                            ? null
                                            : () => _reportService.updateReportStatus(
                                                report.reportId, 'Rejected'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isRejected
                                              ? Colors.red.withOpacity(0.5)
                                              : Colors.red,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                        ),
                                        icon: const Icon(Icons.close),
                                        label: const Text("Reject"),
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

  Widget _buildSearchAndFilter() {
    return SearchAndFilter(
      title: "Search & Filter",
      searchFields: [
        buildRoundedTextField(
          controller: reportIdController,
          label: "Report ID",
          icon: Icons.assignment,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))],
        ),
        buildRoundedTextField(
          controller: donorNameController,
          label: "Donor Name",
          icon: Icons.person,
          keyboardType: TextInputType.text,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'))],
        ),
        SizedBox(
          width: 350,
          child: DropdownButtonFormField<String>(
            value: selectedStatus,
            decoration: InputDecoration(
              labelText: "Status",
              prefixIcon: Icon(Icons.flag),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              labelStyle: TextStyle(fontSize: 16),
            ),
            items: statuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status, style: const TextStyle(fontSize: 16)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
              });
            },
          ),
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: buildRoundedTextField(
              controller: dateController,
              label: "Date (YYYY-MM-DD)",
              icon: Icons.calendar_today,
              readOnly: true,
            ),
          ),
        ),
      ],
      onSearch: searchReports,
      onReset: resetFilters,
    );
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
}
