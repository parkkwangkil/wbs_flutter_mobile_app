import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String _selectedPlan = 'basic';

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('구독 관리', 'Subscription Management')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 구독 상태
            _buildCurrentSubscriptionCard(lang),
            const SizedBox(height: 24),

            // 구독 플랜 선택
            _buildPlanSelectionCard(lang),
            const SizedBox(height: 24),

            // 구독 혜택
            _buildBenefitsCard(lang),
            const SizedBox(height: 24),

            // 결제 정보
            _buildPaymentInfoCard(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscriptionCard(LanguageProvider lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600]),
                const SizedBox(width: 8),
                Text(
                  lang.getText('현재 구독', 'Current Subscription'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lang.getText('기본 플랜', 'Basic Plan'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lang.getText('월 9,900원', '₩9,900/month'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                lang.getText('활성', 'Active'),
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSelectionCard(LanguageProvider lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.getText('구독 플랜 선택', 'Choose Subscription Plan'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPlanOption(lang, 'basic', lang.getText('기본 플랜', 'Basic Plan'), '₩9,900', [
              lang.getText('프로젝트 3개까지', 'Up to 3 projects'),
              lang.getText('팀원 5명까지', 'Up to 5 team members'),
              lang.getText('기본 지원', 'Basic support'),
            ]),
            const SizedBox(height: 12),
            _buildPlanOption(lang, 'pro', lang.getText('프로 플랜', 'Pro Plan'), '₩19,900', [
              lang.getText('프로젝트 무제한', 'Unlimited projects'),
              lang.getText('팀원 20명까지', 'Up to 20 team members'),
              lang.getText('고급 분석', 'Advanced analytics'),
              lang.getText('우선 지원', 'Priority support'),
            ]),
            const SizedBox(height: 12),
            _buildPlanOption(lang, 'enterprise', lang.getText('엔터프라이즈', 'Enterprise'), '₩49,900', [
              lang.getText('모든 기능', 'All features'),
              lang.getText('팀원 무제한', 'Unlimited team members'),
              lang.getText('전용 지원', 'Dedicated support'),
              lang.getText('커스텀 통합', 'Custom integrations'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption(LanguageProvider lang, String planId, String title, String price, List<String> features) {
    final isSelected = _selectedPlan == planId;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = planId;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.blue[50] : Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue[700] : Colors.black,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.blue[700] : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.check,
                    size: 16,
                    color: isSelected ? Colors.blue[600] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.blue[600] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard(LanguageProvider lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.getText('구독 혜택', 'Subscription Benefits'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildBenefitItem(lang, Icons.cloud_sync, lang.getText('클라우드 동기화', 'Cloud Sync'), lang.getText('모든 기기에서 데이터 동기화', 'Sync data across all devices')),
            _buildBenefitItem(lang, Icons.security, lang.getText('고급 보안', 'Advanced Security'), lang.getText('엔터프라이즈급 보안 기능', 'Enterprise-grade security features')),
            _buildBenefitItem(lang, Icons.analytics, lang.getText('상세 분석', 'Detailed Analytics'), lang.getText('프로젝트 성과 분석 및 리포트', 'Project performance analytics and reports')),
            _buildBenefitItem(lang, Icons.support_agent, lang.getText('전용 지원', 'Dedicated Support'), lang.getText('24/7 고객 지원 서비스', '24/7 customer support service')),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(LanguageProvider lang, IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[700], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(LanguageProvider lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.getText('결제 정보', 'Payment Information'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: Text(lang.getText('결제 수단', 'Payment Method')),
              subtitle: Text(lang.getText('**** **** **** 1234', '**** **** **** 1234')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lang.getText('결제 수단 변경 기능', 'Change payment method feature'))),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: Text(lang.getText('결제 내역', 'Payment History')),
              subtitle: Text(lang.getText('최근 결제 내역 보기', 'View recent payment history')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(lang.getText('결제 내역 기능', 'Payment history feature'))),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showUpgradeDialog(lang);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  lang.getText('플랜 업그레이드', 'Upgrade Plan'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeDialog(LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('플랜 업그레이드', 'Upgrade Plan')),
        content: Text(lang.getText('선택한 플랜으로 업그레이드하시겠습니까?', 'Do you want to upgrade to the selected plan?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.getText('취소', 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(lang.getText('업그레이드 요청이 완료되었습니다', 'Upgrade request completed'))),
              );
            },
            child: Text(lang.getText('업그레이드', 'Upgrade')),
          ),
        ],
      ),
    );
  }
}
