import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/class/status_request.dart';
import '../../../core/constant/theme/colors.dart';
import '../controller/diet_controller.dart';
import '../model/diet_model.dart';

class DietMealsPage extends GetView<DietController> {
  const DietMealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DietController>(
      builder: (c) {
        // Load meals if not already loaded
        if (c.meals.isEmpty && c.mealsStatusRequest != StatusRequest.loading) {
          c.loadMeals();
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("dietMeals".tr),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: c.loadMeals,
              ),
            ],
          ),
          body: _buildBody(c),
        );
      },
    );
  }

  Widget _buildBody(DietController c) {
    if (c.mealsStatusRequest == StatusRequest.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (c.mealsStatusRequest == StatusRequest.offlineFailure) {
      return _EmptyState(
        icon: Icons.wifi_off_rounded,
        title: "noInternet".tr,
        buttonText: "retry".tr,
        onRetry: c.loadMeals,
      );
    }

    if (c.mealsStatusRequest == StatusRequest.serverFailure ||
        c.mealsStatusRequest == StatusRequest.failure) {
      return _EmptyState(
        icon: Icons.error_outline_rounded,
        title: "serverError".tr,
        buttonText: "retry".tr,
        onRetry: c.loadMeals,
      );
    }

    if (c.meals.isEmpty) {
      return _EmptyState(
        icon: Icons.restaurant_menu_outlined,
        title: "noMeals".tr,
        buttonText: "refresh".tr,
        onRetry: c.loadMeals,
      );
    }

    // Group meals by day
    final Map<int, List<DietMealModel>> mealsByDay = {};
    for (final meal in c.meals) {
      mealsByDay.putIfAbsent(meal.dayNumber, () => []).add(meal);
    }

    return RefreshIndicator(
      onRefresh: c.loadMeals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mealsByDay.length,
        itemBuilder: (context, index) {
          final day = mealsByDay.keys.elementAt(index);
          final dayMeals = mealsByDay[day]!;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Day $day",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...dayMeals.map((meal) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal.mealTypeDisplay,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      meal.mealName,
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColor.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${meal.calories} kcal",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
