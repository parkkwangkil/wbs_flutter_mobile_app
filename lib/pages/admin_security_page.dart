import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/local_database.dart';

class AdminSecurityPage extends StatefulWidget {
  const AdminSecurityPage({super.key});

  @override
  State<AdminSecurityPage> createState() => _AdminSecurityPageState();
}

class _AdminSecurityPageState extends State<AdminSecurityPage> {
  bool _ipRestriction = false;
  bool _timeRestriction = false;
  bool _deviceRestriction = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    try {
      final settings = await LocalDatabase.getSecuritySettings();
      setState(() {
        _ipRestriction = settings['ip_restriction'] ?? false;
        _timeRestriction = settings['time_restriction'] ?? false;
        _deviceRestriction = settings['device_restriction'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading security settings: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSecuritySettings() async {
    try {
      await LocalDatabase.saveSecuritySettings({
        'ip_restriction': _ipRestriction,
        'time_restriction': _timeRestriction,
        'device_restriction': _deviceRestriction,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('보안 설정이 저장되었습니다.')),
      );
    } catch (e) {
      print('Error saving security settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(lang.getText('관리자 보안 설정', 'Admin Security Settings')),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('관리자 보안 설정', 'Admin Security Settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            lang.getText('접근 제어', 'Access Control'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildSecuritySwitchTile(
            lang: lang,
            icon: Icons.public,
            iconColor: Colors.blue,
            title: lang.getText('IP 제한', 'IP Restriction'),
            subtitle: lang.getText('특정 IP에서만 접근 허용', 'Allow access only from specific IPs'),
            value: _ipRestriction,
            onChanged: (value) {
              setState(() => _ipRestriction = value);
              _saveSecuritySettings();
              _showStatusMessage(lang.getText('IP 제한', 'IP Restriction'), value);
            },
          ),
          
          // IP 규칙 관리 버튼
          if (_ipRestriction) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rule, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        lang.getText('IP 규칙 관리', 'IP Rules Management'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.getText('허용/차단할 IP 주소를 설정하세요', 'Configure IP addresses to allow or block'),
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showIpRulesDialog(context, lang),
                          icon: const Icon(Icons.list),
                          label: Text(lang.getText('규칙 목록', 'Rules List')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[100],
                            foregroundColor: Colors.blue[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddIpRuleDialog(context, lang),
                          icon: const Icon(Icons.add),
                          label: Text(lang.getText('규칙 추가', 'Add Rule')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[100],
                            foregroundColor: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          _buildSecuritySwitchTile(
            lang: lang,
            icon: Icons.access_time_filled,
            iconColor: Colors.orange,
            title: lang.getText('시간 제한', 'Time Restriction'),
            subtitle: lang.getText('특정 시간대에만 접근 허용', 'Allow access only during specific hours'),
            value: _timeRestriction,
            onChanged: (value) {
              setState(() => _timeRestriction = value);
              _saveSecuritySettings();
              _showStatusMessage(lang.getText('시간 제한', 'Time Restriction'), value);
            },
          ),
          
          // 시간 규칙 관리 버튼
          if (_timeRestriction) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Text(
                        lang.getText('시간 규칙 관리', 'Time Rules Management'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.getText('허용/차단할 시간대를 설정하세요', 'Configure time periods to allow or block'),
                    style: TextStyle(color: Colors.orange[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showTimeRulesDialog(context, lang),
                          icon: const Icon(Icons.list),
                          label: Text(lang.getText('규칙 목록', 'Rules List')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[100],
                            foregroundColor: Colors.orange[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddTimeRuleDialog(context, lang),
                          icon: const Icon(Icons.add),
                          label: Text(lang.getText('규칙 추가', 'Add Rule')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[100],
                            foregroundColor: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 12),

          _buildSecuritySwitchTile(
            lang: lang,
            icon: Icons.devices,
            iconColor: Colors.green,
            title: lang.getText('디바이스 제한', 'Device Restriction'),
            subtitle: lang.getText('등록된 디바이스에서만 접근', 'Allow access only from registered devices'),
            value: _deviceRestriction,
            onChanged: (value) {
              setState(() => _deviceRestriction = value);
              _saveSecuritySettings();
              _showStatusMessage(lang.getText('디바이스 제한', 'Device Restriction'), value);
            },
          ),
          
          // 디바이스 규칙 관리 버튼
          if (_deviceRestriction) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.devices, color: Colors.purple[700]),
                      const SizedBox(width: 8),
                      Text(
                        lang.getText('디바이스 규칙 관리', 'Device Rules Management'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    lang.getText('허용/차단할 디바이스를 설정하세요', 'Configure devices to allow or block'),
                    style: TextStyle(color: Colors.purple[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeviceRulesDialog(context, lang),
                          icon: const Icon(Icons.list),
                          label: Text(lang.getText('규칙 목록', 'Rules List')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[100],
                            foregroundColor: Colors.purple[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddDeviceRuleDialog(context, lang),
                          icon: const Icon(Icons.add),
                          label: Text(lang.getText('규칙 추가', 'Add Rule')),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[100],
                            foregroundColor: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          Text(
            lang.getText('보안 로그', 'Security Logs'),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildLogItem('IP 제한 활성화', '2024-10-04 17:30', Colors.green),
                  _buildLogItem('시간 제한 비활성화', '2024-10-04 17:25', Colors.orange),
                  _buildLogItem('디바이스 제한 활성화', '2024-10-04 17:20', Colors.blue),
                  _buildLogItem('시스템 로그인', '2024-10-04 17:15', Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySwitchTile({
    required LanguageProvider lang,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(icon, color: iconColor),
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLogItem(String action, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(action)),
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  void _showStatusMessage(String feature, bool isEnabled) {
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature${lang.getText("이(가)", " has been")} ${isEnabled ? lang.getText("활성화되었습니다", "enabled") : lang.getText("비활성화되었습니다", "disabled")}',
        ),
        backgroundColor: isEnabled ? Colors.green : Colors.redAccent,
      ),
    );
  }

  void _showIpRulesDialog(BuildContext context, LanguageProvider lang) async {
    final rules = await LocalDatabase.getIpRules();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('IP 규칙 목록', 'IP Rules List')),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: rules.isEmpty
              ? Center(
                  child: Text(
                    lang.getText('등록된 규칙이 없습니다', 'No rules registered'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          rule['type'] == 'allow' ? Icons.check_circle : Icons.block,
                          color: rule['type'] == 'allow' ? Colors.green : Colors.red,
                        ),
                        title: Text(rule['ip']),
                        subtitle: Text(
                          '${rule['type'] == 'allow' ? '허용' : '차단'} • ${rule['description'] ?? ''}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await LocalDatabase.deleteIpRule(rule['id']);
                            Navigator.pop(context);
                            _showIpRulesDialog(context, lang);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.getText('닫기', 'Close')),
          ),
        ],
      ),
    );
  }

  void _showAddIpRuleDialog(BuildContext context, LanguageProvider lang) {
    final ipController = TextEditingController();
    final descriptionController = TextEditingController();
    String ruleType = 'allow';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(lang.getText('IP 규칙 추가', 'Add IP Rule')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ipController,
                decoration: InputDecoration(
                  labelText: lang.getText('IP 주소', 'IP Address'),
                  hintText: '192.168.1.1 또는 192.168.1.0/24',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: lang.getText('설명', 'Description'),
                  hintText: lang.getText('규칙에 대한 설명', 'Description for this rule'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(lang.getText('규칙 유형:', 'Rule Type:')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      value: ruleType,
                      items: [
                        DropdownMenuItem(
                          value: 'allow',
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(lang.getText('허용', 'Allow')),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'block',
                          child: Row(
                            children: [
                              const Icon(Icons.block, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(lang.getText('차단', 'Block')),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          ruleType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (ipController.text.isNotEmpty) {
                  await LocalDatabase.addIpRule({
                    'ip': ipController.text,
                    'type': ruleType,
                    'description': descriptionController.text,
                    'is_active': true,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lang.getText('IP 규칙이 추가되었습니다', 'IP rule added'))),
                  );
                }
              },
              child: Text(lang.getText('추가', 'Add')),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimeRulesDialog(BuildContext context, LanguageProvider lang) async {
    final rules = await LocalDatabase.getTimeRules();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('시간 규칙 목록', 'Time Rules List')),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: rules.isEmpty
              ? Center(
                  child: Text(
                    lang.getText('등록된 규칙이 없습니다', 'No rules registered'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    final weekdays = List<int>.from(rule['weekdays'] ?? []);
                    final weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
                    final weekdayText = weekdays.map((d) => weekdayNames[d-1]).join(', ');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          rule['type'] == 'allow' ? Icons.check_circle : Icons.block,
                          color: rule['type'] == 'allow' ? Colors.green : Colors.red,
                        ),
                        title: Text('${rule['start_hour']}:${rule['start_minute'].toString().padLeft(2, '0')} - ${rule['end_hour']}:${rule['end_minute'].toString().padLeft(2, '0')}'),
                        subtitle: Text('$weekdayText • ${rule['description'] ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await LocalDatabase.deleteTimeRule(rule['id']);
                            Navigator.pop(context);
                            _showTimeRulesDialog(context, lang);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.getText('닫기', 'Close')),
          ),
        ],
      ),
    );
  }

  void _showAddTimeRuleDialog(BuildContext context, LanguageProvider lang) {
    final descriptionController = TextEditingController();
    String ruleType = 'allow';
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    List<int> selectedWeekdays = [1, 2, 3, 4, 5]; // 월-금 기본 선택
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(lang.getText('시간 규칙 추가', 'Add Time Rule')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: lang.getText('설명', 'Description'),
                    hintText: lang.getText('규칙에 대한 설명', 'Description for this rule'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(lang.getText('규칙 유형:', 'Rule Type:')),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<String>(
                        value: ruleType,
                        items: [
                          DropdownMenuItem(
                            value: 'allow',
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(lang.getText('허용', 'Allow')),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'block',
                            child: Row(
                              children: [
                                const Icon(Icons.block, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(lang.getText('차단', 'Block')),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            ruleType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(lang.getText('시작 시간', 'Start Time')),
                        subtitle: Text('${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}'),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (time != null) {
                            setState(() {
                              startTime = time;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(lang.getText('종료 시간', 'End Time')),
                        subtitle: Text('${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}'),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (time != null) {
                            setState(() {
                              endTime = time;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(lang.getText('적용 요일:', 'Apply to weekdays:')),
                const SizedBox(height: 8),
                Wrap(
                  children: List.generate(7, (index) {
                    final weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];
                    final isSelected = selectedWeekdays.contains(index + 1);
                    return FilterChip(
                      label: Text(weekdayNames[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedWeekdays.add(index + 1);
                          } else {
                            selectedWeekdays.remove(index + 1);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedWeekdays.isNotEmpty) {
                  await LocalDatabase.addTimeRule({
                    'type': ruleType,
                    'description': descriptionController.text,
                    'start_hour': startTime.hour,
                    'start_minute': startTime.minute,
                    'end_hour': endTime.hour,
                    'end_minute': endTime.minute,
                    'weekdays': selectedWeekdays,
                    'is_active': true,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(lang.getText('시간 규칙이 추가되었습니다', 'Time rule added'))),
                  );
                }
              },
              child: Text(lang.getText('추가', 'Add')),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeviceRulesDialog(BuildContext context, LanguageProvider lang) async {
    final rules = await LocalDatabase.getDeviceRules();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('디바이스 규칙 목록', 'Device Rules List')),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: rules.isEmpty
              ? Center(
                  child: Text(
                    lang.getText('등록된 규칙이 없습니다', 'No rules registered'),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              : ListView.builder(
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          rule['type'] == 'allow' ? Icons.check_circle : Icons.block,
                          color: rule['type'] == 'allow' ? Colors.green : Colors.red,
                        ),
                        title: Text(rule['device_id'] ?? rule['device_type']),
                        subtitle: Text('${rule['type'] == 'allow' ? '허용' : '차단'} • ${rule['description'] ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await LocalDatabase.deleteDeviceRule(rule['id']);
                            Navigator.pop(context);
                            _showDeviceRulesDialog(context, lang);
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.getText('닫기', 'Close')),
          ),
        ],
      ),
    );
  }

  void _showAddDeviceRuleDialog(BuildContext context, LanguageProvider lang) {
    final deviceIdController = TextEditingController();
    final descriptionController = TextEditingController();
    String ruleType = 'allow';
    String deviceType = 'mobile';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(lang.getText('디바이스 규칙 추가', 'Add Device Rule')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: deviceIdController,
                decoration: InputDecoration(
                  labelText: lang.getText('디바이스 ID', 'Device ID'),
                  hintText: lang.getText('특정 디바이스 ID (선택사항)', 'Specific device ID (optional)'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: lang.getText('설명', 'Description'),
                  hintText: lang.getText('규칙에 대한 설명', 'Description for this rule'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(lang.getText('디바이스 타입:', 'Device Type:')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      value: deviceType,
                      items: [
                        DropdownMenuItem(value: 'mobile', child: Text(lang.getText('모바일', 'Mobile'))),
                        DropdownMenuItem(value: 'desktop', child: Text(lang.getText('데스크톱', 'Desktop'))),
                        DropdownMenuItem(value: 'tablet', child: Text(lang.getText('태블릿', 'Tablet'))),
                      ],
                      onChanged: (value) {
                        setState(() {
                          deviceType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(lang.getText('규칙 유형:', 'Rule Type:')),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      value: ruleType,
                      items: [
                        DropdownMenuItem(
                          value: 'allow',
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Text(lang.getText('허용', 'Allow')),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'block',
                          child: Row(
                            children: [
                              const Icon(Icons.block, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(lang.getText('차단', 'Block')),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          ruleType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(lang.getText('취소', 'Cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                await LocalDatabase.addDeviceRule({
                  'device_id': deviceIdController.text.isNotEmpty ? deviceIdController.text : null,
                  'device_type': deviceType,
                  'type': ruleType,
                  'description': descriptionController.text,
                  'is_active': true,
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lang.getText('디바이스 규칙이 추가되었습니다', 'Device rule added'))),
                );
              },
              child: Text(lang.getText('추가', 'Add')),
            ),
          ],
        ),
      ),
    );
  }
}
