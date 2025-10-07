import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class EditProjectPage extends StatefulWidget {
  final Map<String, dynamic> project;
  
  const EditProjectPage({super.key, required this.project});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.project['description'] ?? '');
    _selectedStatus = widget.project['status'] ?? 'in_progress';
    
    // 날짜 파싱
    if (widget.project['start_date'] != null) {
      try {
        _startDate = DateTime.parse(widget.project['start_date']);
      } catch (e) {
        _startDate = DateTime.now();
      }
    }
    if (widget.project['end_date'] != null) {
      try {
        _endDate = DateTime.parse(widget.project['end_date']);
      } catch (e) {
        _endDate = DateTime.now().add(const Duration(days: 30));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 수정된 프로젝트 데이터 생성
      final updatedProject = {
        'id': widget.project['id'],
        'name': _nameController.text,
        'description': _descriptionController.text,
        'status': _selectedStatus,
        'start_date': _startDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
        'created_at': widget.project['created_at'],
        'updated_at': DateTime.now().toIso8601String().split('T')[0],
      };
      
      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로젝트 "${_nameController.text}"가 수정되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.of(context).pop(updatedProject); // 수정된 프로젝트 데이터를 이전 페이지에 전달
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('프로젝트 편집', 'Edit Project')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 프로젝트 이름
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('프로젝트 정보', 'Project Information'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: lang.getText('프로젝트 이름 *', 'Project Name *'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return lang.getText('프로젝트 이름을 입력해주세요.', 'Please enter project name.');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: lang.getText('프로젝트 설명', 'Project Description'),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 프로젝트 상태
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('프로젝트 상태', 'Project Status'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: lang.getText('상태 선택', 'Select Status'),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text(lang.getText('진행중', 'In Progress')),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text(lang.getText('완료', 'Completed')),
                        ),
                        DropdownMenuItem(
                          value: 'on_hold',
                          child: Text(lang.getText('보류', 'On Hold')),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 시작일
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('프로젝트 일정', 'Project Schedule'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildDateSelector(
                      context: context,
                      lang: lang,
                      label: lang.getText('시작일', 'Start Date'),
                      date: _startDate,
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDateSelector(
                      context: context,
                      lang: lang,
                      label: lang.getText('종료일', 'End Date'),
                      date: _endDate,
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? _startDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: Text(
                  lang.getText('프로젝트 수정', 'Update Project'),
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required LanguageProvider lang,
    required String label,
    DateTime? date,
    required VoidCallback onPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
        Text(
          date != null
              ? '${date.year}-${date.month}-${date.day}'
              : lang.getText('날짜를 선택하세요', 'Select Date'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: onPressed,
        ),
      ],
    );
  }
}