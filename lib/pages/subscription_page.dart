import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/payment_service.dart'; // 이 파일은 services 폴더에 생성해야 합니다.
import '../providers/language_provider.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  String _selectedPlan = 'pro';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.getText('구독 관리', 'Subscription Management')),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 구독 상태
            _buildCurrentSubscription(lang),
            const SizedBox(height: 24),

            // 구독 플랜 선택
            Text(
              lang.getText('구독 플랜 선택', 'Choose a Subscription Plan'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ...PaymentService.subscriptionPlans
                .map((plan) => _buildPlanCard(plan, lang))
                .toList(),

            const SizedBox(height: 24),

            // 결제 버튼
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _processPayment(lang),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        lang.getText('구독하기', 'Subscribe'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // 결제 내역
            _buildPaymentHistory(lang),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentSubscription(LanguageProvider lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.getText('현재 구독', 'Current Subscription'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(lang.getText('프로 플랜', 'Pro Plan')),
              subtitle: Text(lang.getText('2024년 2월 15일까지', 'Until Feb 15, 2024')),
              trailing: const Text('₩19,900/월'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showCancelDialog(lang),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(lang.getText('구독 취소', 'Cancel Subscription')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRefundDialog(lang),
                    child: Text(lang.getText('환불 요청', 'Request Refund')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, LanguageProvider lang) {
    final isSelected = _selectedPlan == plan['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: () => setState(() => _selectedPlan = plan['id']),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      plan['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Radio<String>(
                    value: plan['id'],
                    groupValue: _selectedPlan,
                    onChanged: (value) => setState(() => _selectedPlan = value!),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₩${plan['price'].toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                )}/${lang.getText('월', 'mo')}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              ...(plan['features'] as List<String>)
                  .map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check, size: 16, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(feature),
                          ],
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentHistory(LanguageProvider lang) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.getText('결제 내역', 'Payment History'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: PaymentService.getPaymentHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Text(lang.getText('결제 내역을 불러올 수 없습니다.', 'Could not load payment history.'));
                }

                return Column(
                  children: snapshot.data!
                      .map((payment) => ListTile(
                            leading: const Icon(Icons.receipt),
                            title: Text(payment['plan']),
                            subtitle: Text(
                              '${payment['date'].toString().split(' ')[0]}',
                            ),
                            trailing: Text(
                              '₩${payment['amount'].toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (Match m) => '${m[1]},',
                              )}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(LanguageProvider lang) async {
    setState(() => _isLoading = true);

    try {
      final success = await PaymentService.processPayment(_selectedPlan, 'card');

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.getText('구독이 완료되었습니다!', 'Subscription completed!'))),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(lang.getText('결제에 실패했습니다. 다시 시도해주세요.', 'Payment failed. Please try again.'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${lang.getText('오류가 발생했습니다', 'An error occurred')}: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _showCancelDialog(LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('구독 취소', 'Cancel Subscription')),
        content: Text(lang.getText('정말로 구독을 취소하시겠습니까?', 'Are you sure you want to cancel your subscription?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.getText('아니오', 'No')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(lang.getText('구독이 취소되었습니다.', 'Subscription has been canceled.'))),
              );
            },
            child: Text(lang.getText('예', 'Yes')),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(LanguageProvider lang) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(lang.getText('환불 요청', 'Request Refund')),
        content: Text(lang.getText('환불을 요청하시겠습니까?', 'Would you like to request a refund?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(lang.getText('취소', 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(lang.getText('환불 요청이 접수되었습니다.', 'Your refund request has been submitted.'))),
              );
            },
            child: Text(lang.getText('요청', 'Request')),
          ),
        ],
      ),
    );
  }
}
