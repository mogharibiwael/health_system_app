 class ApiLinks {
   // static const String baseUrl =
   //     "https://health-system-backend-c9pb.onrender.com/api";
   static const String baseUrl =
          "https://health-system-backend-l7m5.onrender.com/api";

   /// Base URL for static assets (images) - strip /api from baseUrl
   static String get storageBase =>
       baseUrl.replaceFirst(RegExp(r'/api$'), '').replaceFirst(RegExp(r'/$'), '');
  // static const String baseUrl =
  //      "http://10.0.2.2:8000/api";
   
   // auth url
   static const String register = "$baseUrl/register";
   static const String login = "$baseUrl/login";
   static const String forgotPassword = "$baseUrl/forgot-password";
   static const String verifyEmail = "$baseUrl/verify-email";
   static const String resendVerificationCode = "$baseUrl/resend-verification-code";
   static const String subscriptions = "$baseUrl/subscriptions";
   static const String chatMessages = "$baseUrl/chat/messages";
   static const String chatHistory = "$baseUrl/chat/history"; // + /{doctorId}
   static const String doctorPatients = "$baseUrl/doctor/patients";
   static String doctorPatientMacros(int patientId) => "$baseUrl/doctor/patients/$patientId/macros"; // GET + PUT
   static const String patientProfile = "$baseUrl/patients/profile";

   // forums (per API doc: GET /forums, POST /forums/{id}/join, GET /forums/{id}/posts, POST /forums/{id}/posts)
   static const String forumsBase   = "$baseUrl/forums";               // GET list, POST /{id}/join, GET /{id}/posts, POST /{id}/posts
   static const String postsBase   = "$baseUrl/posts";                 // POST /{id}/like, POST /{id}/unlike

   // consultations (sessions)
   static const String consultations = "$baseUrl/consultations";        // POST to request, GET to list

   // diet
   static const String myDiet = "$baseUrl/my-diet";                    // GET current diet
   static const String myDietMeals = "$baseUrl/my-diet/meals";        // GET diet meals
   static const String dietPlans = "$baseUrl/diet-plans";             // POST create/assign diet plan (for doctors)

   // public (no auth - no token required)
   static const String publicAds = "$baseUrl/public/ads";
   static const String publicDoctors = "$baseUrl/public/doctors";     // GET list of doctors (no auth)
   static const String publicAthkar = "$baseUrl/public/athkar";

   // developer_api_guide: calculations, references, meals
   static const String calculationsNutrition = "$baseUrl/calculations/nutrition"; // POST - BMI, BMR, TEF, TDEE, macros
   static const String referencesNutritionManuals = "$baseUrl/references/nutrition-manuals"; // GET - for doctors
   static const String mealsApi = "$baseUrl/meals"; // POST - meal with serving, carbo, protin, fat

 }
