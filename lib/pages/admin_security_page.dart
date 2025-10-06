import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

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
    final lang = Provider.of<LanguageProvider>(context);

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
              _showStatusMessage(lang.getText('IP 제한', 'IP Restriction'), value);
            },
          ),
          
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
              _showStatusMessage(lang.getText('시간 제한', 'Time Restriction'), value);
            },
          ),
          
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
              _showStatusMessage(lang.getText('디바이스 제한', 'Device Restriction'), value);
            },
          ),
          
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
}
