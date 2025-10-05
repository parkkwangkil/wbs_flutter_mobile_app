import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId: '실제_Google_Cloud_Console에서_복사한_Client_ID를_여기에_붙여넣으세요', // Google Cloud Console에서 발급받은 Client ID
  );

  // Google 로그인
  static Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('사용자가 로그인을 취소했습니다.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      return {
        'id': 'google_${DateTime.now().millisecondsSinceEpoch}',
        'name': googleUser.displayName ?? 'Google User',
        'email': googleUser.email,
        'avatar': googleUser.photoUrl,
        'provider': 'google',
        'username': googleUser.email,
        'firstName': googleUser.displayName?.split(' ').first ?? 'Google',
        'lastName': googleUser.displayName?.split(' ').skip(1).join(' ') ?? 'User',
        'department': 'Social',
        'password': 'google_login',
      };
    } catch (e) {
      throw Exception('Google 로그인 실패: $e');
    }
  }

  // Google 로그아웃
  static Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
  }

  static Future<Map<String, dynamic>?> loginWithNaver() async {
    // Naver 로그인 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    return {
      'id': 'naver_${DateTime.now().millisecondsSinceEpoch}',
      'name': 'Naver User',
      'email': 'user@naver.com',
      'avatar': 'https://via.placeholder.com/100',
      'provider': 'naver',
    };
  }

  static Future<Map<String, dynamic>?> loginWithKakao() async {
    // Kakao 로그인 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    return {
      'id': 'kakao_${DateTime.now().millisecondsSinceEpoch}',
      'name': 'Kakao User',
      'email': 'user@kakao.com',
      'avatar': 'https://via.placeholder.com/100',
      'provider': 'kakao',
    };
  }

  // 프로젝트 공유 기능
  static Future<bool> shareProject(Map<String, dynamic> project) async {
    // 프로젝트 공유 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // 이벤트 공유 기능
  static Future<bool> shareEvent(Map<String, dynamic> event) async {
    // 이벤트 공유 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // 팀 초대 기능
  static Future<bool> inviteTeamMember(String email, String projectId) async {
    // 팀원 초대 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // 협업 기능
  static Future<bool> collaborateOnProject(String projectId, String userId) async {
    // 프로젝트 협업 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
