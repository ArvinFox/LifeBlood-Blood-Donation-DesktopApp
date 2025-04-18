import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

enum FormType {rewards, events}

class AddData extends StatefulWidget {
  final FormType formType;
  final void Function(Map<String, dynamic>) onSubmit;

  const AddData({super.key, required this.formType, required this.onSubmit});

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'title': TextEditingController(),
    'description': TextEditingController(),
    'startDate': TextEditingController(),
    'endDate': TextEditingController(),
    'eventDate': TextEditingController(),
    'eventTime': TextEditingController(),
  };

  DateTime? _selectedDate;
  DateTime? _selectedEventDate;
  String? _uploadedFileName;

  @override
  Widget build(BuildContext context) {
    final isReward = widget.formType == FormType.rewards;
    final title = isReward ? 'Add New Reward' : 'Add New Event';

    return AlertDialog(
      title: Center(child: Text(title)),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 450,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isReward ? 'Reward Name' : 'Event Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _controllers['title'],
                  decoration: InputDecoration(
                    hintText: isReward ? 'Reward Name' : 'Event Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? '* Required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 20),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _controllers['description'],
                  decoration: InputDecoration(
                    hintText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 10,
                  minLines: 1,
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? '* Required' : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 25),
                Text(
                  isReward ? 'Reward Poster' : 'Event Poster',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 10),
                MedicalReportPicker(
                  onFileUploaded: (base64String) {
                    setState(() {
                      _uploadedFileName = base64String; 
                    });
                  },
                ),
                const SizedBox(height: 25),
                if (isReward) ...[
                  _buildDatePicker(
                    'Start Date', 
                    _controllers['startDate']!,
                    _selectedDate, 
                    (picked) {
                      setState(() {
                        _selectedDate = picked;
                        _controllers['startDate']!.text ='${picked.day}-${picked.month}-${picked.year}';
                      });
                    }, 
                    'dd-mm-yyyy'
                  ),
                  const SizedBox(height: 25),
                  _buildDatePicker(
                    'End Date', 
                     _controllers['endDate']!,
                    _selectedDate, 
                    (picked) {
                      setState(() {
                        _selectedDate = picked;
                        _controllers['endDate']!.text = '${picked.day}-${picked.month}-${picked.year}';
                      });
                    }, 
                    'dd-mm-yyyy'
                  ),
                ],
                if (!isReward) ...[
                  _buildDatePicker(
                    'Date',
                    _controllers['eventDate']!,
                    _selectedEventDate, (picked) {
                      setState(() {
                        _selectedEventDate = picked;
                        _controllers['eventDate']!.text = '${picked.day}-${picked.month}-${picked.year}';
                      });
                    }, 
                    'dd-mm-yyyy'
                  ),
                  const SizedBox(height: 25),
                  _buildTimePicker(
                    'Time',
                    _controllers['eventTime']!,
                    'hh:mm AM/PM',
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color(0xFF1E1E1E),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final formData = {
                'title': _controllers['title']!.text,
                'description': _controllers['description']!.text,
                'startDate': _controllers['startDate']!.text,
                'endDate': _controllers['endDate']!.text,
                'eventTime': _controllers['eventTime']!.text,
                'eventDate': _controllers['eventDate']!.text,
              };

              print("Form Data: $formData"); 

              widget.onSubmit(formData);
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFAE42),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text("Add"),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildDatePicker(String lable,TextEditingController controller,DateTime? selectedDate,Function(DateTime) onDateSelected,String? hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lable,
          style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700,color: Colors.black54),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: Icon(Icons.calendar_today),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          readOnly: true,
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialEntryMode: DatePickerEntryMode.calendarOnly,
            );
            if (pickedDate != null) {
              onDateSelected(pickedDate);
            }
          },
          validator: (value) =>
                value == null || value.isEmpty ? '* Required' : null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

  Widget _buildTimePicker(String label,TextEditingController controller,String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black54),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: Icon(Icons.access_time),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          readOnly: true,
          onTap: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              final formattedTime = pickedTime.format(context);
              controller.text = formattedTime;
            }
          },
          validator: (value) =>
              value == null || value.isEmpty ? '* Required' : null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
        ),
      ],
    );
  }

}

class MedicalReportPicker extends StatefulWidget {
  final Function(String)? onFileUploaded;

  const MedicalReportPicker({super.key, this.onFileUploaded});

  @override
  State<MedicalReportPicker> createState() => _MedicalReportPickerState();
}

class _MedicalReportPickerState extends State<MedicalReportPicker> {
  String text = 'Select Poster';
  Color btnColor = Colors.white;

  Future<void> uploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
      withData: true,
    );

    if (result != null) {
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;

      if (fileBytes != null) {
        try {
          String base64String = base64Encode(fileBytes);

          setState(() {
            text =
                fileName.length > 20
                    ? "${fileName.substring(0, 20)}...."
                    : fileName;
            btnColor = Colors.red;
          });

          widget.onFileUploaded?.call(base64String);
        } catch (e) {
          print('Error encoding the file: $e');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: uploadImage,
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.black38),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: btnColor == Colors.red ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
