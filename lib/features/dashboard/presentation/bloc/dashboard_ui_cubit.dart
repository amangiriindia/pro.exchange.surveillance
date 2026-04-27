import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardUiState {
  final bool isMenuExpanded;
  final int selectedIndex;
  final bool showSettings;
  final bool showProfile;
  final bool showNotifications;
  final String? notificationInitialType;

  const DashboardUiState({
    this.isMenuExpanded = true,
    this.selectedIndex = 0,
    this.showSettings = false,
    this.showProfile = false,
    this.showNotifications = false,
    this.notificationInitialType,
  });

  DashboardUiState copyWith({
    bool? isMenuExpanded,
    int? selectedIndex,
    bool? showSettings,
    bool? showProfile,
    bool? showNotifications,
    String? notificationInitialType,
    bool clearNotificationInitialType = false,
  }) {
    return DashboardUiState(
      isMenuExpanded: isMenuExpanded ?? this.isMenuExpanded,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      showSettings: showSettings ?? this.showSettings,
      showProfile: showProfile ?? this.showProfile,
      showNotifications: showNotifications ?? this.showNotifications,
      notificationInitialType: clearNotificationInitialType
          ? null
          : (notificationInitialType ?? this.notificationInitialType),
    );
  }
}

class DashboardUiCubit extends Cubit<DashboardUiState> {
  DashboardUiCubit() : super(const DashboardUiState());

  void toggleMenu() {
    emit(state.copyWith(isMenuExpanded: !state.isMenuExpanded));
  }

  void selectMenu(int index) {
    emit(
      state.copyWith(
        selectedIndex: index,
        showSettings: false,
        showProfile: false,
        showNotifications: false,
        clearNotificationInitialType: true,
      ),
    );
  }

  void openProfile() {
    emit(
      state.copyWith(
        showProfile: true,
        showSettings: false,
        showNotifications: false,
      ),
    );
  }

  void openSettings() {
    emit(state.copyWith(showSettings: true, showProfile: false));
  }

  void openNotifications({String? initialAlertType}) {
    emit(
      state.copyWith(
        showNotifications: true,
        showSettings: false,
        showProfile: false,
        notificationInitialType: initialAlertType,
        clearNotificationInitialType: initialAlertType == null,
      ),
    );
  }
}
