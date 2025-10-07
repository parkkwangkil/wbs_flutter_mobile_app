import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/local_database.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  State<CreateProjectPage> createState() => _CreateProjectPageState();
}

class _CreateProjectPageState extends State<CreateProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _projectType = 'personal'; // 기본값: 개인 프로젝트

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 프로젝트 데이터 생성
      final newProject = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': _nameController.text,
        'description': _descriptionController.text,
        'type': _projectType,
        'status': 'in_progress', // 진행중으로 설정
        'start_date': _startDate?.toIso8601String().split('T')[0] ?? DateTime.now().toIso8601String().split('T')[0],
        'end_date': _endDate?.toIso8601String().split('T')[0] ?? DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
        'created_at': DateTime.now().toIso8601String().split('T')[0],
      };
      
      try {
        // LocalDatabase에 프로젝트 저장
        await LocalDatabase.addProject(newProject);
        
        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로젝트 "${_nameController.text}"가 생성되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop(newProject); // 생성된 프로젝트 데이터를 이전 페이지에 전달
      } catch (e) {
        // 에러 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로젝트 생성 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('새 프로젝트 생성', 'Create New Project')),
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
                    const SizedBox(height: 16),
                    Text(
                      lang.getText('프로젝트 타입', 'Project Type'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Row(
                              children: [
                                const Icon(Icons.person, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(lang.getText('개인', 'Personal')),
                              ],
                            ),
                            value: 'personal',
                            groupValue: _projectType,
                            onChanged: (value) {
                              setState(() {
                                _projectType = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Row(
                              children: [
                                const Icon(Icons.group, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(lang.getText('팀', 'Team')),
                              ],
                            ),
                            value: 'team',
                            groupValue: _projectType,
                            onChanged: (value) {
                              setState(() {
                                _projectType = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 날짜 선택
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.getText('프로젝트 기간', 'Project Duration'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildDateSelector(
                      context: context,
                      lang: lang,
                      label: lang.getText('시작일', 'Start Date'),
                      date: _startDate,
                      onPressed: () => _selectDate(context, true),
                    ),
                    const SizedBox(height: 16),
                    _buildDateSelector(
                      context: context,
                      lang: lang,
                      label: lang.getText('종료일', 'End Date'),
                      date: _endDate,
                      onPressed: () => _selectDate(context, false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: Text(
                  lang.getText('프로젝트 생성', 'Create Project'),
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