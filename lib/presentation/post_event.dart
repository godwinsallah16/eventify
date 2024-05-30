import 'dart:io';

import 'package:eventify/core/app_export.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../models/events.dart';

class EventForm extends StatefulWidget {
  const EventForm({super.key});

  @override
  _EventFormState createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _eventFile;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _locationLinkController = TextEditingController();
  bool _showLocationLinkField = false;

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4'], // Allow video files
    );

    if (result != null) {
      setState(() {
        _eventFile = File(result.files.single.path!);
      });
    }
  }

  void _toggleLocationLinkField(bool? value) {
    if (value != null) {
      setState(() {
        _showLocationLinkField = value;
      });
    }
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId == null) {
          throw Exception('User ID not available');
        }

        EventModel event = EventModel(
          eventFiles: [_eventFile!],
          eventName: _eventNameController.text,
          eventDescription: _eventDescriptionController.text,
          eventDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
          eventTime: _selectedTime.format(context),
          eventLocation: _locationController.text,
          eventLocationUrl:
              _showLocationLinkField ? _locationLinkController.text : null,
        );

        await CloudStorageService().saveModelToDataBase(
          model: event,
          collectionPath: 'public/events/users',
          useTimestamp: true,
        );

        _formKey.currentState!.reset();
        setState(() {
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
          _eventFile = null;
          _showLocationLinkField = false;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event posted successfully!')),
          );
          NavigatorService.goBack();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _eventDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Event Description',
                ),
                maxLines: 3,
                minLines: 1,
              ),
              const SizedBox(height: 24),
              ButtonSecondary(
                onTap: _selectFile, // Changed from _selectImage to _selectFile
                buttonText: 'Select Event File (Image/Video)',
              ),
              if (_eventFile != null)
                Text('File selected: ${_eventFile!.path}'),
              const SizedBox(height: 32),
              ButtonSecondary(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 5),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                buttonText: 'Select Date',
              ),
              Text(
                  'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              const SizedBox(height: 32),
              ButtonSecondary(
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedTime = pickedTime;
                    });
                  }
                },
                buttonText: 'Select Time',
              ),
              Text('Selected Time: ${_selectedTime.format(context)}'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Event Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: const Text('Add Location Link (Optional)'),
                value: _showLocationLinkField,
                onChanged: _toggleLocationLinkField,
              ),
              if (_showLocationLinkField)
                TextFormField(
                  controller: _locationLinkController,
                  decoration: const InputDecoration(labelText: 'Location Link'),
                ),
              const SizedBox(height: 32),
              ButtonPrimary(
                onTap: _submitEvent,
                buttonText: 'Submit',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
