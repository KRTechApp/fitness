import 'dart:math';

import 'package:flutter/material.dart';

/// ************************************ Firebase Storage ************************************************/
const folderWorkoutCategory = 'workout_category';
const folderWorkout = 'workout_profile';
const folderMemberProfile = 'member_profile';
const folderTrainerProfile = 'trainer_profile';
const folderTrainerAttachment = 'trainer_attachment';
const folderMembership = 'membership';
const folderMembershipAttachment = 'membership_attachment';
const folderExerciseImage = 'exercise_image';
const folderExerciseVideo = 'exercise_video';

/// ************************************ Firebase Table ************************************************/
const tableUser = 'users';
const tableSpecialization = 'specializations';
const tableMembership = 'memberships';
const tableWorkoutCategory = 'workout_category';
const tableClass = 'class_schedule';
const tableWorkout = 'workouts';
const tableExercise = 'exercises';
const tableGeneralSetting = 'admin_setting';
const tablePaymentHistory = 'payment_history';
const tableMeasurementHistory = 'measurement_history';
const tableWorkoutHistory = 'workout_history';
const tablePaymentData = 'payment_data';
const tableNutrition = 'nutrition';

/// ************************************ Firebase Keys ************************************************/

const keyEmail = 'email';
const keyPassword = 'password';
const keyNewPassword = 'new_password';
const keyConfirmPassword = 'confirm_password';
const keyRemember = 'remember';
const keyGender = 'gender';
const keyAge = 'age';
const keyHeight = 'height';
const keyWeight = 'weight';
const keyGoal = 'goal';
const keyChest = 'chest';
const keyWaist = 'waist';
const keyThigh = 'thigh';
const keyArms = 'arms';
const keyName = 'full_name';
const keyCountryCode = 'country_Code';
const keyWpCountryCode = 'wp_country_Code';
const keyPhone = 'phone';
const keyWpPhone = 'wp_phone';
const keyDateOfBirth = 'date_of_birth';
const keyAddress = 'address';
const keyCity = 'city';
const keyState = 'state';
const keyZipCode = 'zip_code';
const keyCountry = 'country';
const keyAccountStatus = 'account_status';
const keyUserRole = 'user_role';
const keySpecialization = 'specialization';
const keyAssignedMembers = 'assigned_members';
const keyMembershipName = 'membership_name';
const keyWorkoutCategoryTitle = 'title';
const keyWorkoutType = 'workout_type';
const keyGymName = 'gym_name';
const keyAmount = 'amount';
const keyPeriod = 'period';
const keyClassLimit = 'class_limit';
const keyMemberLimit = 'member_limit';
const keyRecurringPackage = 'recurring_package';
const keyDescription = 'description';
const keyProfile = 'profile';
const keyAttachment = 'attachment';
const keyClassName = 'class_name';
const keyStartDate = 'start_date';
const keyEndDate = 'end_date';
const keyStartTime = 'start_time';
const keyEndTime = 'end_time';
const keyClassType = 'class_type';
const keyVirtualClassLink = 'virtual_class_link';
const keySelectedDays = 'selected_days';
const keySelectedMember = 'selected_member';
const keyTotalWorkoutTime = 'total_workout_time';
const keyCurrentDate = 'current_date';
const keyCreatedAt = 'created_at';
const keyCreatedBy = 'created_by';
const keyTrainerId = 'trainer_id';
const keyMemberCount = 'member_count';
const keyExerciseTitle = 'exercise_title';
const keyYoutubeLink = 'youtube_link';
const keyExerciseDetailImage = 'exercise_detail_image';
const keyNotes = 'notes';
const keyWorkoutData = 'workout_data';
const keyExerciseCount = 'exercise_count';
const keyCategoryId = 'category_id';
const keySet = 'set';
const keyReps = 'reps';
const keyExerciseTime = 'exercise_time';
const keyTimerStatus = 'timer_status';
const keySec = 'sec';
const keyRest = 'rest';
const keySwitchRole = 'switch_role';
const keyNotification = 'notification';
const keyEmailNotification = 'email_notification';
const keyWorkoutId = 'workout_id';
const keyWorkoutTitle = 'workout_title';
const keyDuration = 'duration';
const keyWorkoutFor = 'workout_for';
const keyStartingYear = 'starting_year';
const keyDateFormat = "date_format";
const keyEnableMail = "enable_mail";
const keyAdminIsTrainer = "admin_is_trainer";
const keyExpirationMail = "expiration_mail";
const keyMembershipRunsOut = "membership_runs_out";
const keySelectedLanguage = "selected_Language";
const keySelectedCurrency = "selected_currency";
const keySelectedTimeZone = "selected_timezone";
const keyCurrentMembership = "current_membership";
const keyMembershipTimestamp = "membership_timestamp";
const keyMembershipId = "membership_id";
const keyUserId = "user_id";
const keyExerciseId = "exercise_id";
const keyPaymentStatus = "payment_status";
const keyPaymentId = "payment_id";
const keyPaymentType = "payment_type";
const keyFirebaseToken = "firebase_token";
const keyDeletedBy = "deleted_by";
const keyClassScheduleId = "class_schedule_id";
const keyExtendDate = "extend_date";
const keyInvoiceNo = "invoice_no";
const keyMemberId = "member_id";
const keyMemberPrefix = "member_prefix";
const keyIsWhatsappNumber = "is_whatsapp_number";
const keyVirtualClass = "virtual_class";
const keySecretKey = "secret_key";
const keyPublishable = "publishable_key";
const keyPaymentAmount = "payment_amount";
const keyPaymentRecivedAmount = "payment_recived_amount";
const keyPaymentCountry = "payment_country";
const keyPaymentCourrency = "payment_courrency";
const keyPaymentBrand = "payment_brand";
const keyPaymentCardCountry = "payment_card_country";
const keyCardLast4 = "card_last_4_digits";
const keyPaymentEmail = "payment_email";
const keyPaymentRecept = "payment_recept";
const keyClientSecretId = "client_secretId";
const keyPaypalClientId = "client_id";
const keyPaypalSecretKey = "paypal_secret_key";
const keyPayerId = "payer_id";
const keyClientEmail = "client_email";
const keyEnventoPurchaseKey = "envento_purchase_key";
const keyEmailFrom = "email_from";
const keyDomain = "domain";
const keyEmailName = "email_name";
const keySMTPServer = "SMTP_server";
const keySMTPServerPort = "SMTP_server_port";
const keyLoginEmail = "login_email";
const keySMTPPassword = "SMTP_password";
const keyCountrySortName = "country_sort_name";
const keyCountryCodeName = "country_code_name";
const keySendinBlueApi = "sendinblue_api_key";
const keyExerciseProgress = "exercise_progress";
const keyMemberTrainerId = "member_trainer_id";
const keyNutritionName = "nutrition_name";
const keyNutritionDetail = "nutrition_detail";
const keyBreakFast = "breakfast";
const keyMidMorningSnacks = "mid_morning_snacks";
const keyLunch = "lunch";
const keyAfternoonSnacks = "afternoon_snacks";
const keyDinner = "dinner";


/// ************************************ Firebase Value ************************************************/

const accountAllowed = 'allowed';
const accountRequested = 'requested';
const userRoleAdmin = 'admin';
const userRoleTrainer = 'trainer';
const userRoleMember = 'member';
const paymentCash = 'cash';
const paymentPaid = 'paid';
const paymentUnPaid = 'unpaid';
const paymentTypeStripe = 'stripe';
const paymentTypePayPal = 'paypal';
const paymentTypeCash = 'cash';

const daySunday = 'sunday';
const dayMonday = 'monday';
const dayTuesday = 'tuesday';
const dayWednesday = 'wednesday';
const dayThursday = 'thursday';
const dayFriday = 'friday';
const daySaturday = 'saturday';

const workoutTypeFree = 'free';
const workoutTypePremium = 'premium';

/// ************************************ Notification key ************************************************/

const notificationTrainerPackageAssign = 'trainerPackageAssi0gn';
const notificationMemberMembershipAssign = 'memberMembershipAssign';
const notificationWorkoutAssign = 'workoutAssign';
const notificationWorkoutUnAssign = 'workoutUnAssign';
const notificationClassAssign = 'classAssign';
const notificationExpiredMembership = 'expiredMembership';

/// ************************************ Shared-preference Keys ************************************************/

const prefIsLogin = "isLogin";
const prefFirebaseToken = "firebaseToken";
const prefEmail = 'email';
const prefPassword = 'password';
const prefGender = 'gender';
const prefAge = 'age';
const prefHeight = 'height';
const prefWeight = 'weight';
const prefEmailNotification = 'emailNotification';
const prefName = 'full_name';
const prefCountryCode = 'countryCode';
const prefPhone = 'phone';
const prefDateOfBirth = 'date_of_birth';
const prefAddress = 'address';
const prefProfile = 'profile';
const prefAccountStatus = 'account_status';
const prefUserId = 'user_id';
const prefUserRole = 'user_role';
const prefCreatedBy = 'created_by';
const prefCurrentDate = 'current_date';
const prefLanguage = "language";
const String english = 'en';

List languageList = [
  english,
];

/// ************************************ Status Code ************************************************/

const onSuccess = 200;
const onFailed = 417;
const onNotFound = 404;

const iosBundleId = "crossfit.personaltrainer.gymtrainer.fitness";


String getOTPNumber({required int digit}) {
  Random random = Random();
  String number = '';
  for (int i = 0; i < digit; i++) {
    number = number + random.nextInt(9).toString();
  }
  debugPrint(number);
  return number;
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890!@#%^&*()_+=-/';

String getRandomString({required int length}) {
  Random random = Random();
  var finalString =
      String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(random.nextInt(_chars.length))));
  return finalString;
}
