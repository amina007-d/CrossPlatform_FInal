import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/budget_settings.dart';
import '../../domain/repositories/repositories.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  @override
  Future<BudgetSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return BudgetSettings(
      monthlyLimit: prefs.getDouble(AppConstants.keyBudgetLimit) ?? 1000.0,
      currency: prefs.getString(AppConstants.keyDefaultCurrency) ?? 'USD',
      isDarkMode: prefs.getBool(AppConstants.keyThemeMode) ?? false,
      householdId: prefs.getString(AppConstants.keyHouseholdId) ?? '',
      userName: prefs.getString(AppConstants.keyUserName) ?? '',
    );
  }

  @override
  Future<void> saveSettings(BudgetSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.keyBudgetLimit, settings.monthlyLimit);
    await prefs.setString(AppConstants.keyDefaultCurrency, settings.currency);
    await prefs.setBool(AppConstants.keyThemeMode, settings.isDarkMode);
    await prefs.setString(AppConstants.keyHouseholdId, settings.householdId);
    await prefs.setString(AppConstants.keyUserName, settings.userName);
  }
}
