import 'package:flutter/foundation.dart';

class AppStateService extends ChangeNotifier {
  static final AppStateService _instance = AppStateService._internal();
  factory AppStateService() => _instance;
  AppStateService._internal();

  // 프로젝트 목록
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> get projects => _projects;

  // 이벤트 목록
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> get events => _events;

  // 팀 멤버 목록
  List<Map<String, dynamic>> _teamMembers = [];
  List<Map<String, dynamic>> get teamMembers => _teamMembers;

  // 프로젝트 추가
  void addProject(Map<String, dynamic> project) {
    _projects.add(project);
    notifyListeners();
  }

  // 이벤트 추가
  void addEvent(Map<String, dynamic> event) {
    _events.add(event);
    notifyListeners();
  }

  // 이벤트 새로고침 알림
  void refreshEvents() {
    notifyListeners();
  }

  // 팀 멤버 추가
  void addTeamMember(Map<String, dynamic> member) {
    _teamMembers.add(member);
    notifyListeners();
  }

  // 프로젝트 업데이트
  void updateProject(String id, Map<String, dynamic> updatedProject) {
    final index = _projects.indexWhere((project) => project['id'] == id);
    if (index != -1) {
      _projects[index] = updatedProject;
      notifyListeners();
    }
  }

  // 이벤트 업데이트
  void updateEvent(String id, Map<String, dynamic> updatedEvent) {
    final index = _events.indexWhere((event) => event['id'] == id);
    if (index != -1) {
      _events[index] = updatedEvent;
      notifyListeners();
    }
  }

  // 프로젝트 삭제
  void removeProject(String id) {
    _projects.removeWhere((project) => project['id'] == id);
    notifyListeners();
  }

  // 이벤트 삭제
  void removeEvent(String id) {
    _events.removeWhere((event) => event['id'] == id);
    notifyListeners();
  }

  // 팀 멤버 삭제
  void removeTeamMember(String id) {
    _teamMembers.removeWhere((member) => member['id'] == id);
    notifyListeners();
  }

  // 모든 데이터 초기화
  void clearAllData() {
    _projects.clear();
    _events.clear();
    _teamMembers.clear();
    notifyListeners();
  }

  // 특정 프로젝트의 이벤트 가져오기
  List<Map<String, dynamic>> getEventsForProject(String projectId) {
    return _events.where((event) => event['project_id'] == projectId).toList();
  }

  // 특정 프로젝트의 팀 멤버 가져오기
  List<Map<String, dynamic>> getTeamMembersForProject(String projectId) {
    return _teamMembers.where((member) => member['project_id'] == projectId).toList();
  }
}
