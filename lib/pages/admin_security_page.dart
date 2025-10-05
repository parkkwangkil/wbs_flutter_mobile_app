import 'package:flutter/material.dart';

class AdminSecurityPage extends StatefulWidget {
  const AdminSecurityPage({super.key});

  @override
  State<AdminSecurityPage> createState() => _AdminSecurityPageState();
}

class _AdminSecurityPageState extends State<AdminSecurityPage> {
  bool _ipRestriction = false;
  bool _timeRestriction = false;
  bool _deviceRestriction = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 보안 설정'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '접근 제어',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // IP 제한
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.blue),
                title: const Text('IP 제한'),
                subtitle: const Text('특정 IP에서만 접근 허용'),
                trailing: Switch(
                  value: _ipRestriction,
                  onChanged: (value) {
                    setState(() {
                      _ipRestriction = value;
                    });
                    _showStatusMessage('IP 제한', value);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 시간 제한
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time, color: Colors.orange),
                title: const Text('시간 제한'),
                subtitle: const Text('특정 시간대에만 접근 허용'),
                trailing: Switch(
                  value: _timeRestriction,
                  onChanged: (value) {
                    setState(() {
                      _timeRestriction = value;
                    });
                    _showStatusMessage('시간 제한', value);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 디바이스 제한
            Card(
              child: ListTile(
                leading: const Icon(Icons.devices, color: Colors.green),
                title: const Text('디바이스 제한'),
                subtitle: const Text('등록된 디바이스에서만 접근'),
                trailing: Switch(
                  value: _deviceRestriction,
                  onChanged: (value) {
                    setState(() {
                      _deviceRestriction = value;
                    });
                    _showStatusMessage('디바이스 제한', value);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 보안 로그 섹션
            const Text(
              '보안 로그',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: Card(
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
            ),
          ],
        ),
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusMessage(String feature, bool isEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature이 ${isEnabled ? "활성화" : "비활성화"}되었습니다',
        ),
        backgroundColor: isEnabled ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
