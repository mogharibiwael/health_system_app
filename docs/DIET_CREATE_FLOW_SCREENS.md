# Diet Creation Flow – Every Screen Explained

This document describes **every screen** the doctor sees **after pressing "Create Diet"** (or "Create Diet Plan") on a patient’s details screen: what each screen does and why it was implemented that way.

---

## Flow Overview

After the doctor taps **Create Diet** on the patient details screen, the app opens a **wizard** of several steps. Data is passed forward via route arguments so the final API payload can be built from one place.

```
Patient Details  →  Diet Periods  →  Diet Targets  →  Portion Categories  →  Portion Carb  →  Portion Protein  →  Diet Distribution  →  Determine Meals  →  Create Diet for Patient  →  API + back to Patient Details
```

---

## 1. Diet Periods (Meal Times)

**Route:** `dietPeriods`  
**File:** `lib/feature/diet/view/diet_periods_page.dart`  
**Controller:** `DietPeriodsController`

### What it does

- Shows the **patient name** at the top (from the patient you selected).
- Lists **meals and snacks** with a **time** for each: Breakfast, Lunch, Dinner, First Snack, Second Snack, Third Snack.
- Each row has a **time picker**: tap the time to change it (e.g. Breakfast 08:00, Lunch 13:00).
- Doctor can **add extra snacks** ("Add Snack"); extra snacks can have a **custom name** and can be **removed**.
- **Next Step** sends: `patient_id`, `patient_name`, `doctor_id`, `patient`, and **periods** (each period = `meal_type`, `hour`, `minute`, optional `custom_name`) to the next screen.

### Why it’s there

- The plan is built **per meal period**. The backend and the patient’s view need to know **when** each meal/snack is (e.g. for reminders or ordering).
- Starting with periods ensures the rest of the wizard (targets, distribution, final create) always has a fixed list of meals (breakfast, lunch, dinner, snacks) to attach servings and optional meal items to.

---

## 2. Diet Targets (Calculated Goals)

**Route:** `dietTargets`  
**File:** `lib/feature/diet/view/diet_targets_page.dart`  
**Controller:** `DietTargetsController`

### What it does

- Shows **patient name** and a warning if profile is incomplete (e.g. missing height/weight).
- Uses the **patient’s profile** (weight, height, age, gender, physical activity) to compute and display:
  - **BMR** (Basal Metabolic Rate)
  - **TDEE** (Total Daily Energy Expenditure)
  - **Target calories**
  - **Macros**: carbs, protein, fat (grams)
- Lets the doctor choose:
  - **Goal:** Maintain / Weight loss / Weight gain (recalculates targets).
  - **Milk type:** Skim / Low-fat / Whole (affects exchange plan).
  - **Meat type:** Very lean / Lean / Medium-fat / High-fat (affects exchange plan).
- Shows **daily exchange servings** (starch, fruit, vegetables, milk, meat, fat) from the internal exchange calculator.
- **Next Step** goes to **Portion Categories** with: `patient_id`, `patient_name`, `doctor_id`, `patient`, `periods`, `targets` (BMR, TDEE, calories, macros), `exchange_plan`, `exchange_plan_json`.

### Why it’s there

- Targets must be **consistent with the patient’s data** (BMR/TDEE from height, weight, age, activity).
- Goal and milk/meat type drive **how many servings** of each exchange group the patient gets. Doing this here keeps the rest of the flow (portion categories, distribution, create) aligned with one calculated plan.

---

## 3. Portion Categories (Main Categories)

**Route:** `dietPortionCategories`  
**File:** `lib/feature/diet/view/portion_categories_page.dart`  
**Controller:** `PortionCategoriesController`

### What it does

- Shows a **table** of **main categories** and **number of portions** per day:
  - Milk: Skim, Low-fat, Whole  
  - Vegetables, Fruit, Starch, Other carbs  
  - Meat: Very lean, Lean, Medium-fat, High-fat  
  - Fat  
- Each row has **+ / −** to adjust the portion count; a third column shows **fat per serving** (for reference).
- Values are **pre-filled** from the exchange plan coming from Diet Targets.
- **Proceed to next step** sends the same context plus **portion_plan** (and derived `exchange_plan`) to **Portion Carb**.

### Why it’s there

- Diet Targets only output **totals** (e.g. total starch, total meat). Here the doctor can **refine** how those totals are split (e.g. more skim milk vs whole milk, or starch vs other carbs). That gives a single, detailed **portion plan** used later for distribution and for building the API payload.

---

## 4. Portion Carb (Starch vs Other Carbs)

**Route:** `dietPortionCarb`  
**File:** `lib/feature/diet/view/portion_carb_page.dart`  
**Controller:** `PortionCarbController`

### What it does

- Shows **total carb portions** (from the previous step).
- Doctor **splits** that total between:
  - **Starch portions** (bread, rice, grains)
  - **Other carb portions**
- Uses simple numeric inputs; total is constrained so the split is explicit.
- **Next** sends the same args plus updated **portion_plan** (starch + otherCarbs) and **exchange_plan** to **Portion Protein**.

### Why it’s there

- The exchange system separates **starch** from **other carbs** (e.g. sweets, other starches). This step makes that split explicit so the built plan and any future display (e.g. "2 starch, 1 fruit") are correct and consistent with the chosen total carbs.

---

## 5. Portion Protein (Meat Types)

**Route:** `dietPortionProtein`  
**File:** `lib/feature/diet/view/portion_protein_page.dart`  
**Controller:** `PortionProteinController`

### What it does

- Shows **total protein (meat) portions** from the plan.
- Doctor **splits** them among:
  - Very lean meat  
  - Lean meat  
  - Medium-fat meat  
  - High-fat meat  
- **Next** sends the same context plus the updated **portion_plan** and **exchange_plan** to **Diet Distribution**.

### Why it’s there

- Different meat types have different **fat and calorie** content per portion. Splitting here keeps the plan’s fat/calories accurate and allows the backend or patient view to show meat type (e.g. for shopping or preferences).

---

## 6. Diet Distribution (Servings per Meal)

**Route:** `dietDistribution`  
**File:** `lib/feature/diet/view/diet_distribution_page.dart`  
**Controller:** `DietDistributionController`

### What it does

- Shows a **table**:
  - **Rows:** Food groups (starch, fruit, vegetables, milk, meat, fat).
  - **Columns:** "Group", "Total daily", then **one column per meal/snack** (from the periods you set in step 1).
- Each cell is the **number of servings** of that group in that meal. **Total daily** per row equals the daily exchange plan.
- Distribution is **pre-calculated** using simple ratios (e.g. main meals get a larger share, snacks a smaller shared share), then **balanced** so row totals match the plan.
- **Proceed to last step** sends: same context plus **distribution** (mealKey → {starch, fruit, vegetables, milk, meat, fat}) to **Determine Meals**.

### Why it’s there

- The plan must specify **how many servings of each group go to each meal** (e.g. "breakfast: 2 starch, 1 fruit"). This screen turns the **daily** exchange plan into **per-meal** servings so the payload builder can generate one structure per meal. The default ratios give a reasonable split without making the doctor edit every cell.

---

## 7. Determine Meals (Optional Items + Notes)

**Route:** `dietDetermineMeals`  
**File:** `lib/feature/diet/view/determine_meals_page.dart`  
**Controller:** `DetermineMealsController`

### What it does

- For **each meal/snack** (from periods + distribution):
  - Shows the **meal name** and a **serving breakdown** (e.g. "Starch: 2, Fruit: 1, Vegetables: 1").
  - Optional: doctor can **add meal items** (e.g. "Oatmeal", "Apple") via a text field; items are shown as chips and can be removed.
- One **notes** field (e.g. "Avoid dairy at dinner") that is sent as **doctor_notes**.
- **Create Diet** navigates to **Create Diet for Patient** with: all previous args plus **meal_items** (mealKey → list of item strings) and **doctor_notes**.

### Why it’s there

- The distribution only has **numbers** (e.g. 2 starch at breakfast). This step lets the doctor attach **concrete food names** per meal so the patient sees "Oatmeal, Banana" instead of only "2 starch, 1 fruit". Notes give extra instructions. Both are optional but improve usability.

---

## 8. Create Diet for Patient (Review & Save)

**Route:** `createDietForPatient`  
**File:** `lib/feature/diet/view/create_diet_for_patient_page.dart`  
**Controller:** `DietController` (shared with patient “My Diet” flow)

### What it does

- Shows **read-only**:
  - **Patient name** (no patient ID field).
  - If coming from the wizard: **saved meal times**, **target calories**, **macros** (carbs, protein, fat in grams).
- Editable:
  - **Plan title** (default e.g. "Diet plan for [Patient Name]" or localized equivalent).
  - **Daily calories**, **Duration (days)**, **Start date**, **End date** (pre-filled from wizard when possible).
- **Create**:
  - Validates required fields.
  - Uses **DietPayloadBuilder** to build **meals** and **meal_periods** from: distribution, periods, exchange plan, and optional meal items.
  - Calls **diet data** `createDietPlan(...)` (API). On success, navigates back to **Patient Details** (`Get.until` to patient details).

### Why it’s there

- Single place to **review** patient, targets, and dates before sending to the backend.
- Hiding patient ID and showing only patient name reduces clutter and mistakes.
- All wizard data is already in arguments; this screen only edits title/dates/duration and triggers the one API call that creates the plan. RTL and Arabic are supported so the screen works in the app’s Arabic locale.

---

## End-to-End Data Flow (Why Each Step Exists)

| Step | Output / Purpose |
|------|-------------------|
| **Diet Periods** | List of meal/snack times (and names). Needed so every later step and the API know *which* meals exist. |
| **Diet Targets** | BMR, TDEE, target calories, macros, goal, milk/meat type → daily exchange plan. Ensures the plan is based on the patient’s profile. |
| **Portion Categories** | Fine-tune daily portions per sub-category (milk types, meat types, starch vs other carbs, etc.). |
| **Portion Carb** | Split total carb portions into starch vs other carbs. |
| **Portion Protein** | Split total meat portions into very lean / lean / medium / high fat. |
| **Diet Distribution** | Turn daily portions into per-meal servings (table). Feeds the payload builder. |
| **Determine Meals** | Optional meal items and doctor notes. Improves what the patient sees and any notes stored with the plan. |
| **Create Diet for Patient** | Review, set title/dates, and send one API request to create the diet plan; then return to Patient Details. |

---

## Technical Reference

| Screen | View file | Controller |
|--------|-----------|------------|
| Diet Periods | `diet_periods_page.dart` | `DietPeriodsController` |
| Diet Targets | `diet_targets_page.dart` | `DietTargetsController` |
| Portion Categories | `portion_categories_page.dart` | `PortionCategoriesController` |
| Portion Carb | `portion_carb_page.dart` | `PortionCarbController` |
| Portion Protein | `portion_protein_page.dart` | `PortionProteinController` |
| Diet Distribution | `diet_distribution_page.dart` | `DietDistributionController` |
| Determine Meals | `determine_meals_page.dart` | `DetermineMealsController` |
| Create Diet for Patient | `create_diet_for_patient_page.dart` | `DietController` |

Payload building: `diet_payload_builder.dart`.  
API call: `diet_data.dart` → `createDietPlan` / `createDiet`.

---

*Last updated: February 2026*
