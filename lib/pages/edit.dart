import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/diary.dart';
import '../services/api.dart';
import '../constants/theme.dart' show AppColors, AppGradients;

class EditPage extends StatefulWidget {
  final Diary diary;

  const EditPage({super.key, required this.diary});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dateController;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.diary.date);
    _titleController = TextEditingController(text: widget.diary.title);
    _contentController = TextEditingController(text: widget.diary.content);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(widget.diary.date),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await ApiService.updateDiary(
      id: widget.diary.id,
      date: _dateController.text,
      title: _titleController.text,
      content: _contentController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal memperbarui diary')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 120,
            decoration: const BoxDecoration(
              gradient: AppGradients.mainGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Edit Diary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: _selectDate,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal',
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(
                            Icons.calendar_today,
                            color: AppColors.primaryPink,
                          ),
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Tanggal wajib diisi'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Judul'),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Judul wajib diisi'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Isi'),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Isi wajib diisi'
                                  : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
