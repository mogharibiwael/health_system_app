import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constant/theme/colors.dart';
import '../../../core/shared/widgets/app_bar.dart';
import '../controller/base_servings_controller.dart';

/// Base Servings step: doctor sets servings and manual macros (carbs, protein, fat) per group.
/// Shows per-group contribution, total, remaining requirements; navigates to Portion Categories.
class BaseServingsPage extends GetView<BaseServingsController> {
  const BaseServingsPage({super.key});

  static double _parseDouble(String s) => double.tryParse(s) ?? 0.0;

  @override
  Widget build(BuildContext context) {
    final isAr = Get.locale?.languageCode == 'ar';
    final textDir = isAr ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDir,
      child: GetBuilder<BaseServingsController>(
        builder: (c) => SafeArea(
          child: Scaffold(
            backgroundColor: Colors.grey.shade100,
            appBar: CustomAppBar(
              title: "baseServings".tr,
              subtitle: c.patientName.isNotEmpty ? c.patientName : null,
              showBackButton: true,
              showLogo: true,
            ),
            body: c.exchangePlan == null || c.targets == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (c.patientName.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              "Patient: ${c.patientName}",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        Text(
                          "baseServingsDesc".tr,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _GroupCard(
                          title: "fruit".tr,
                          servings: c.fruitServings,
                          onServingsDecrement: () =>
                              c.setFruit(c.fruitServings - 1),
                          onServingsIncrement: () =>
                              c.setFruit(c.fruitServings + 1),
                          carbsG: c.fruitCarbs,
                          proteinG: c.fruitProtein,
                          fatG: c.fruitFat,
                          onCarbsChanged: (v) => c.setFruitCarbs(v),
                          onProteinChanged: (v) => c.setFruitProtein(v),
                          onFatChanged: (v) => c.setFruitFat(v),
                          parseDouble: _parseDouble,
                        ),
                        const SizedBox(height: 12),
                        _GroupCard(
                          title: "vegetables".tr,
                          servings: c.vegetablesServings,
                          onServingsDecrement: () =>
                              c.setVegetables(c.vegetablesServings - 1),
                          onServingsIncrement: () =>
                              c.setVegetables(c.vegetablesServings + 1),
                          carbsG: c.vegetableCarbs,
                          proteinG: c.vegetableProtein,
                          fatG: c.vegetableFat,
                          onCarbsChanged: (v) => c.setVegetableCarbs(v),
                          onProteinChanged: (v) => c.setVegetableProtein(v),
                          onFatChanged: (v) => c.setVegetableFat(v),
                          parseDouble: _parseDouble,
                        ),
                        const SizedBox(height: 12),
                        _GroupCard(
                          title: "milk".tr,
                          servings: c.milkServings,
                          onServingsDecrement: () =>
                              c.setMilk(c.milkServings - 1),
                          onServingsIncrement: () =>
                              c.setMilk(c.milkServings + 1),
                          carbsG: c.milkCarbs,
                          proteinG: c.milkProtein,
                          fatG: c.milkFat,
                          onCarbsChanged: (v) => c.setMilkCarbs(v),
                          onProteinChanged: (v) => c.setMilkProtein(v),
                          onFatChanged: (v) => c.setMilkFat(v),
                          parseDouble: _parseDouble,
                        ),
                        const SizedBox(height: 20),
                        _buildGroupContributionSection(
                          title: "fruitsContribution".tr,
                          contribution: c.fruitContribution,
                        ),
                        const SizedBox(height: 12),
                        _buildGroupContributionSection(
                          title: "vegetablesContribution".tr,
                          contribution: c.vegetablesContribution,
                        ),
                        const SizedBox(height: 12),
                        _buildGroupContributionSection(
                          title: "milkContribution".tr,
                          contribution: c.milkContribution,
                        ),
                        const SizedBox(height: 20),
                        _buildSummarySection(
                          title: "totalContribution".tr,
                          carbs: c.contribution.carbsG,
                          protein: c.contribution.proteinG,
                          fat: c.contribution.fatG,
                          calories: c.contribution.calories,
                        ),
                        const SizedBox(height: 20),
                        if (c.remainingMacros != null)
                          _buildSummarySection(
                            title: "remainingRequirements".tr,
                            carbs: c.remainingMacros!.carbsG,
                            protein: c.remainingMacros!.proteinG,
                            fat: c.remainingMacros!.fatG,
                            calories: c.remainingMacros!.calories,
                            isRemaining: true,
                          ),
                        if (c.hasExceedsTargetsWarning) ...[
                          const SizedBox(height: 16),
                          _buildWarningBanner(),
                        ],
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: c.goToPortionCategories,
                            icon: const Icon(Icons.arrow_forward, size: 22),
                            label: Text("nextStep".tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _buildGroupContributionSection({
    required String title,
    required BaseServingsContribution contribution,
  }) {
    return _buildSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
              "carbohydrates".tr, "${contribution.carbsG.toStringAsFixed(0)} g"),
          _SummaryRow("protein".tr, "${contribution.proteinG.toStringAsFixed(0)} g"),
          _SummaryRow("fats".tr, "${contribution.fatG.toStringAsFixed(0)} g"),
          _SummaryRow(
              "calories".tr, "${contribution.calories.toStringAsFixed(0)} kcal"),
        ],
      ),
    );
  }

  Widget _buildSummarySection({
    required String title,
    required double carbs,
    required double protein,
    required double fat,
    required double calories,
    bool isRemaining = false,
  }) {
    return _buildSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isRemaining
                  ? AppColor.primary
                  : Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow("carbohydrates".tr, "${carbs.toStringAsFixed(0)} g"),
          _SummaryRow("protein".tr, "${protein.toStringAsFixed(0)} g"),
          _SummaryRow("fats".tr, "${fat.toStringAsFixed(0)} g"),
          _SummaryRow("calories".tr, "${calories.toStringAsFixed(0)} kcal"),
        ],
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "baseServingsExceedsTargetWarning".tr,
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServingsRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _ServingsRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: value <= 0 ? null : onDecrement,
              icon: const Icon(Icons.remove_circle_outline, size: 28),
              color: AppColor.primary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                "$value",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline, size: 28),
              color: AppColor.primary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              style: IconButton.styleFrom(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Card for one base group: title, servings stepper, and manual carbs/protein/fat inputs.
class _GroupCard extends StatelessWidget {
  final String title;
  final int servings;
  final VoidCallback onServingsDecrement;
  final VoidCallback onServingsIncrement;
  final double carbsG;
  final double proteinG;
  final double fatG;
  final void Function(double) onCarbsChanged;
  final void Function(double) onProteinChanged;
  final void Function(double) onFatChanged;
  final double Function(String) parseDouble;

  const _GroupCard({
    required this.title,
    required this.servings,
    required this.onServingsDecrement,
    required this.onServingsIncrement,
    required this.carbsG,
    required this.proteinG,
    required this.fatG,
    required this.onCarbsChanged,
    required this.onProteinChanged,
    required this.onFatChanged,
    required this.parseDouble,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _ServingsRow(
            label: "servings".tr,
            value: servings,
            onDecrement: onServingsDecrement,
            onIncrement: onServingsIncrement,
          ),
          const SizedBox(height: 12),
          _MacroInputField(
            label: "carbohydrates".tr,
            value: carbsG,
            onChanged: onCarbsChanged,
            parseDouble: parseDouble,
          ),
          const SizedBox(height: 8),
          _MacroInputField(
            label: "protein".tr,
            value: proteinG,
            onChanged: onProteinChanged,
            parseDouble: parseDouble,
          ),
          const SizedBox(height: 8),
          _MacroInputField(
            label: "fats".tr,
            value: fatG,
            onChanged: onFatChanged,
            parseDouble: parseDouble,
          ),
        ],
      ),
    );
  }
}

/// Numeric text field for macro input; keeps controller in sync when not focused.
class _MacroInputField extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double Function(String) parseDouble;

  const _MacroInputField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.parseDouble,
  });

  @override
  State<_MacroInputField> createState() => _MacroInputFieldState();
}

class _MacroInputFieldState extends State<_MacroInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatValue(widget.value),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_MacroInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus &&
        widget.parseDouble(_controller.text) != widget.value) {
      _controller.text = _formatValue(widget.value);
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  String _formatValue(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              suffixText: 'g',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (s) => widget.onChanged(widget.parseDouble(s)),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
