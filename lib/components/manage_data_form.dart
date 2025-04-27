import 'dart:convert';
import 'package:blood_donation_app/services/event_service.dart';
import 'package:blood_donation_app/services/reward_service.dart';
import 'package:blood_donation_app/utils/helpers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum FormType { rewards, events }

class ManageDataForm extends StatefulWidget {
  final FormType formType;
  final bool? isEditMode;
  final String? id;
  final void Function(Map<String, dynamic>, bool) onSubmit;

  const ManageDataForm({
    super.key, 
    required this.formType, 
    this.isEditMode,
    this.id,
    required this.onSubmit,
  });

  @override
  State<ManageDataForm> createState() => _ManageDataFormState();
}

class _ManageDataFormState extends State<ManageDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _rewardService = RewardService();
  final _eventService = EventService();

  bool _isLoading = false;

  final Map<String, TextEditingController> _controllers = {
    'title': TextEditingController(),
    'description': TextEditingController(),
    'startDate': TextEditingController(),
    'endDate': TextEditingController(),
    'eventDate': TextEditingController(),
    'eventTime': TextEditingController(),
    'location': TextEditingController(),
  };

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  DateTime? _selectedEventDate;
  String? _uploadedImageName;

  // Load initial data is editing
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.id != null) {

        setState(() {
          _isLoading = true;
        });

        if (widget.formType == FormType.rewards) {
          final reward = await _rewardService.getRewardById(widget.id!);

          if (reward != null) {
            _controllers['title']!.text = reward.rewardName;
            _controllers['description']!.text = reward.description;
            _controllers['startDate']!.text = DateFormat('dd-MM-yyyy').format(reward.startDate);
            _controllers['endDate']!.text = DateFormat('dd-MM-yyyy').format(reward.endDate);

            // fetch poster ------------------------------

            setState(() {
              _selectedEndDate = reward.startDate;
              _selectedEndDate = reward.endDate;
            });
          }

        } else {
          final event = await _eventService.getEventById(widget.id!);

          if (event != null) {
            _controllers['title']!.text = event.eventName;
            _controllers['description']!.text = event.description;
            _controllers['location']!.text = event.location;
            _controllers['eventDate']!.text = DateFormat('dd-MM-yyyy').format(event.dateAndTime);
            _controllers['eventTime']!.text = DateFormat('h:mm a').format(event.dateAndTime);

            // fetch poster ------------------------------

            setState(() {
              _selectedEventDate = event.dateAndTime;
            });
          }
        }

        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReward = widget.formType == FormType.rewards;
    final isEdit = widget.isEditMode ?? false;
    final title = isReward
        ? (isEdit ? 'Edit Reward' : 'Add New Reward')
        : (isEdit ? 'Edit Event' : 'Add New Event');

    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 255, 247, 247),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 16,
      titlePadding: const EdgeInsets.only(top: 20),
      title: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.all(20),
      content: _isLoading 
        ? CircularProgressIndicator(color: const Color.fromARGB(255, 255, 164, 164)) 
        : Form(
            key: _formKey,
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(color: Colors.redAccent, width: 1),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(isReward ? 'Reward Name' : 'Event Name'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      _controllers['title']!,
                      isReward ? 'Reward Name' : 'Event Name',
                      TextInputType.text,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Description'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      _controllers['description']!,
                      'Description',
                      TextInputType.text,
                      maxLines: 6,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel(isReward ? 'Reward Poster' : 'Event Poster'),
                    const SizedBox(height: 8),

                    // Display current poster -------------------------------------

                    PosterPicker(
                      initialFileName: isEdit ? 'Selected Poster' : null,
                      initialBase64: _uploadedImageName,
                      onImageUploaded: (base64String) {
                        setState(() {
                          _uploadedImageName = base64String;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    if (!isReward) ...[
                      _buildLabel('Location'),
                      const SizedBox(height: 8),
                      _buildTextField(_controllers['location']!, 'Location', TextInputType.text),
                      const SizedBox(height: 20),
                    ],

                    if (isReward) ...[
                      _buildDatePickerField(
                        context,
                        'Start Date',
                        _controllers['startDate']!,
                        _selectedStartDate,
                        (picked) {
                          setState(() {
                            _selectedStartDate = picked;
                            _controllers['startDate']!.text = '${picked.day}-${picked.month}-${picked.year}';

                            if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
                              _selectedEndDate = null;
                              _controllers['endDate']!.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildDatePickerField(
                        context,
                        'End Date',
                        _controllers['endDate']!,
                        _selectedEndDate,
                        (picked) {
                          if (_selectedStartDate != null && picked.isBefore(_selectedStartDate!)) {
                            Helpers.showError(context, 'End date cannot be before start date');
                            return;
                          }
                          setState(() {
                            _selectedEndDate = picked;
                            _controllers['endDate']!.text = '${picked.day}-${picked.month}-${picked.year}';
                          });
                        },
                      ),
                    ],

                    if (!isReward) ...[
                      _buildDatePickerField(
                        context,
                        'Date',
                        _controllers['eventDate']!,
                        _selectedEventDate,
                        (picked) {
                          setState(() {
                            _selectedEventDate = picked;
                            _controllers['eventDate']!.text = '${picked.day}-${picked.month}-${picked.year}';
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildTimePickerField(
                        context,
                        'Time',
                        _controllers['eventTime']!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 12),
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
                    'location': _controllers['location']!.text,
                    'poster': _uploadedImageName,
                  };
                  widget.onSubmit(formData, isEdit);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5E5E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
              child: Text(isEdit ? "Update" : "Add"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType type, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      validator: (value) => value == null || value.isEmpty ? '* Required' : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      // inputFormatters: [
      //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
      // ],
    );
  }

  Widget _buildDatePickerField(BuildContext context, String label, TextEditingController controller, DateTime? selectedDate, Function(DateTime) onDatePicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null) onDatePicked(picked);
          },
          child: AbsorbPointer(
            child: _buildTextField(controller, 'dd-mm-yyyy', TextInputType.datetime),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerField(BuildContext context, String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              controller.text = picked.format(context);
            }
          },
          child: AbsorbPointer(
            child: _buildTextField(controller, 'hh:mm AM/PM', TextInputType.datetime),
          ),
        ),
      ],
    );
  }
}

class PosterPicker extends StatefulWidget {
  final Function(String)? onImageUploaded;
  final String? initialFileName;
  final String? initialBase64;

  const PosterPicker({
    super.key,
    this.onImageUploaded,
    this.initialFileName,
    this.initialBase64,
  });

  @override
  State<PosterPicker> createState() => _PosterPickerState();
}

class _PosterPickerState extends State<PosterPicker> {
  String text = 'Select Poster';
  Color btnColor = Colors.white;

  @override
  void initState() {
    super.initState();
    if (widget.initialFileName != null) {
      text = widget.initialFileName!.length > 20
          ? "${widget.initialFileName!.substring(0, 20)}...."
          : widget.initialFileName!;
      btnColor = Colors.red;
    }
  }

  Future<void> uploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
      withData: true,
    );

    if (result != null) {
      final imageBytes = result.files.single.bytes;
      final imageName = result.files.single.name;

      if (imageBytes != null) {
        try {
          String base64String = base64Encode(imageBytes);

          setState(() {
            text = imageName.length > 20
              ? "${imageName.substring(0, 20)}...."
              : imageName;
            btnColor = Colors.red;
          });

          widget.onImageUploaded?.call(base64String);
        } catch (e) {
          Helpers.debugPrintWithBorder('Error encoding the image: $e');
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
            side: const BorderSide(color: Colors.black38),
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
