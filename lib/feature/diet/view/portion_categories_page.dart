import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/portion_categories_controller.dart';
import '../model/portion_categories_model.dart';

class PortionCategoriesPage extends GetView<PortionCategoriesController> {
  const PortionCategoriesPage({super.key});

  static String _categoryLabel(String key) {
    switch (key) {
      case 'milkSkim':
        return "milkSkim".tr;
      case 'milkLowFat':
        return "milkLowFat".tr;
      case 'milkWhole':
        return "milkWhole".tr;
      case 'vegetables':
        return "vegetables".tr;
      case 'fruit':
        return "fruit".tr;
      case 'starch':
        return "starch".tr;
      case 'otherCarbs':
        return "otherCarbs".tr;
      case 'meatVeryLean':
        return "meatVeryLean".tr;
      case 'meatLean':
        return "meatLean".tr;
      case 'meatMediumFat':
        return "meatMediumFat".tr;
      case 'meatHighFat':
        return "meatHighFat".tr;
      case 'fat':
        return "fat".tr;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortionCategoriesController>(
      builder: (c) => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: CustomAppBar(
            title: "dietPortionCategories".tr,
            subtitle: c.patientName.isNotEmpty ? c.patientName : null,
            showBackButton: true,
            showLogo: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.shadowColor.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        ...PortionCategoriesPlan.categoryKeys.map((key) =>
                            _buildRow(c, key)),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: c.goToCarbDistribution,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text("proceedToNextStep".tr),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "mainCategories".tr,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 92,
            child: Text(
              "numberOfPortions".tr,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _headerCell("carbohydrates".tr, 42),
          _headerCell("protein".tr, 38),
          _headerCell("fatsG".tr, 42),
          _headerCell("calories".tr, 44),
        ],
      ),
    );
  }

  Widget _headerCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildRow(PortionCategoriesController c, String key) {
    final portion = c.getPortion(key);
    final def = PortionCategoriesPlan.definition(key);
    final carbs = def?.carbsG ?? 0;
    final protein = def?.proteinG ?? 0;
    final fat = def?.fatG ?? 0;
    final cal = def?.calories ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _categoryLabel(key),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          SizedBox(
            width: 92,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: () => c.setPortion(key, (portion - 1).clamp(0, 99)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                Expanded(
                  child: Text(
                    "$portion",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => c.setPortion(key, (portion + 1).clamp(0, 99)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  style: IconButton.styleFrom(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          _macroCell(carbs.toString(), 42),
          _macroCell(protein.toString(), 38),
          _macroCell(fat.toString(), 42),
          _macroCell(cal.toString(), 44),
        ],
      ),
    );
  }

  Widget _macroCell(String value, double width) {
    return SizedBox(
      width: width,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
