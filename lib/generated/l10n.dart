// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Welcome to`
  String get welcome_to {
    return Intl.message(
      'Welcome to',
      name: 'welcome_to',
      desc: '',
      args: [],
    );
  }

  /// `GYM-Trainer`
  String get gym_trainer {
    return Intl.message(
      'GYM-Trainer',
      name: 'gym_trainer',
      desc: '',
      args: [],
    );
  }

  /// `The best fitness in this century to accompany \n your sports.`
  String get the_best_fitness_in_this_century_to_accompany_your_sports {
    return Intl.message(
      'The best fitness in this century to accompany \n your sports.',
      name: 'the_best_fitness_in_this_century_to_accompany_your_sports',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Let’s you in`
  String get lets_you_in {
    return Intl.message(
      'Let’s you in',
      name: 'lets_you_in',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Facebook`
  String get continue_with_facebook {
    return Intl.message(
      'Continue with Facebook',
      name: 'continue_with_facebook',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Google`
  String get continue_with_google {
    return Intl.message(
      'Continue with Google',
      name: 'continue_with_google',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Apple`
  String get continue_with_apple {
    return Intl.message(
      'Continue with Apple',
      name: 'continue_with_apple',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get or {
    return Intl.message(
      'Or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `sign in with password`
  String get sign_in_with_password {
    return Intl.message(
      'sign in with password',
      name: 'sign_in_with_password',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have an account?`
  String get do_not_have_an_account {
    return Intl.message(
      'Don’t have an account?',
      name: 'do_not_have_an_account',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get all_ready_have_an_account {
    return Intl.message(
      'Already have an account?',
      name: 'all_ready_have_an_account',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sign_up {
    return Intl.message(
      'Sign Up',
      name: 'sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get sign_in {
    return Intl.message(
      'Sign In',
      name: 'sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Edit Workout`
  String get edit_workout {
    return Intl.message(
      'Edit Workout',
      name: 'edit_workout',
      desc: '',
      args: [],
    );
  }

  /// `Login to your Account`
  String get login_to_your_account {
    return Intl.message(
      'Login to your Account',
      name: 'login_to_your_account',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get new_password {
    return Intl.message(
      'New Password',
      name: 'new_password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirm_password {
    return Intl.message(
      'Confirm Password',
      name: 'confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Remember me`
  String get remember_me {
    return Intl.message(
      'Remember me',
      name: 'remember_me',
      desc: '',
      args: [],
    );
  }

  /// `Register Successfully`
  String get register_successfully {
    return Intl.message(
      'Register Successfully',
      name: 'register_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgot_password {
    return Intl.message(
      'Forgot password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Or continue with`
  String get or_continue_with {
    return Intl.message(
      'Or continue with',
      name: 'or_continue_with',
      desc: '',
      args: [],
    );
  }

  /// `Create your Account`
  String get create_your_account {
    return Intl.message(
      'Create your Account',
      name: 'create_your_account',
      desc: '',
      args: [],
    );
  }

  /// `Something want to wrong`
  String get something_want_to_wrong {
    return Intl.message(
      'Something want to wrong',
      name: 'something_want_to_wrong',
      desc: '',
      args: [],
    );
  }

  /// `Login Successfully`
  String get login_successfully {
    return Intl.message(
      'Login Successfully',
      name: 'login_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email id`
  String get please_enter_a_valid_email_id {
    return Intl.message(
      'Please enter a valid email id',
      name: 'please_enter_a_valid_email_id',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Password of at least Six character`
  String get please_enter_password_of_at_least_six_character {
    return Intl.message(
      'Please enter Password of at least Six character',
      name: 'please_enter_password_of_at_least_six_character',
      desc: '',
      args: [],
    );
  }

  /// `View Class`
  String get view_class {
    return Intl.message(
      'View Class',
      name: 'view_class',
      desc: '',
      args: [],
    );
  }

  /// `Edit Class`
  String get edit_class {
    return Intl.message(
      'Edit Class',
      name: 'edit_class',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `Create Class`
  String get create_class {
    return Intl.message(
      'Create Class',
      name: 'create_class',
      desc: '',
      args: [],
    );
  }

  /// `Add Class`
  String get add_class {
    return Intl.message(
      'Add Class',
      name: 'add_class',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Class Name`
  String get please_enter_class_name {
    return Intl.message(
      'Please Enter Class Name',
      name: 'please_enter_class_name',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Start Date`
  String get please_enter_start_date {
    return Intl.message(
      'Please Enter Start Date',
      name: 'please_enter_start_date',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Start Date`
  String get please_select_start_date {
    return Intl.message(
      'Please Select Start Date',
      name: 'please_select_start_date',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter End Date`
  String get please_enter_end_date {
    return Intl.message(
      'Please Enter End Date',
      name: 'please_enter_end_date',
      desc: '',
      args: [],
    );
  }

  /// `Class Name`
  String get class_name {
    return Intl.message(
      'Class Name',
      name: 'class_name',
      desc: '',
      args: [],
    );
  }

  /// `Member`
  String get member {
    return Intl.message(
      'Member',
      name: 'member',
      desc: '',
      args: [],
    );
  }

  /// `Select Member`
  String get select_member {
    return Intl.message(
      'Select Member',
      name: 'select_member',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get start_date {
    return Intl.message(
      'Start Date',
      name: 'start_date',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get end_date {
    return Intl.message(
      'End Date',
      name: 'end_date',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Start Time`
  String get please_enter_start_time {
    return Intl.message(
      'Please Enter Start Time',
      name: 'please_enter_start_time',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Start Time`
  String get please_select_start_time {
    return Intl.message(
      'Please Select Start Time',
      name: 'please_select_start_time',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter End Time`
  String get please_enter_end_time {
    return Intl.message(
      'Please Enter End Time',
      name: 'please_enter_end_time',
      desc: '',
      args: [],
    );
  }

  /// `Start Time`
  String get start_time {
    return Intl.message(
      'Start Time',
      name: 'start_time',
      desc: '',
      args: [],
    );
  }

  /// `End Time`
  String get end_time {
    return Intl.message(
      'End Time',
      name: 'end_time',
      desc: '',
      args: [],
    );
  }

  /// `Class Type`
  String get class_type {
    return Intl.message(
      'Class Type',
      name: 'class_type',
      desc: '',
      args: [],
    );
  }

  /// `Virtual class`
  String get virtual_class {
    return Intl.message(
      'Virtual class',
      name: 'virtual_class',
      desc: '',
      args: [],
    );
  }

  /// `In person`
  String get in_person {
    return Intl.message(
      'In person',
      name: 'in_person',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid link`
  String get please_enter_valid_link {
    return Intl.message(
      'Please enter valid link',
      name: 'please_enter_valid_link',
      desc: '',
      args: [],
    );
  }

  /// `Virtual Class Link`
  String get virtual_class_link {
    return Intl.message(
      'Virtual Class Link',
      name: 'virtual_class_link',
      desc: '',
      args: [],
    );
  }

  /// `Select Days`
  String get select_days {
    return Intl.message(
      'Select Days',
      name: 'select_days',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Member`
  String get please_select_member {
    return Intl.message(
      'Please Select Member',
      name: 'please_select_member',
      desc: '',
      args: [],
    );
  }

  /// `Go Back`
  String get go_back {
    return Intl.message(
      'Go Back',
      name: 'go_back',
      desc: '',
      args: [],
    );
  }

  /// `Add Member`
  String get add_member {
    return Intl.message(
      'Add Member',
      name: 'add_member',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get upload_image {
    return Intl.message(
      'Upload Image',
      name: 'upload_image',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Name`
  String get please_enter_your_name {
    return Intl.message(
      'Please Enter Your Name',
      name: 'please_enter_your_name',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your valid Email`
  String get please_enter_your_email {
    return Intl.message(
      'Please enter your valid Email',
      name: 'please_enter_your_email',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Password`
  String get please_enter_your_password {
    return Intl.message(
      'Please Enter Your Password',
      name: 'please_enter_your_password',
      desc: '',
      args: [],
    );
  }

  /// `Old Password`
  String get old_password {
    return Intl.message(
      'Old Password',
      name: 'old_password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your valid Phone`
  String get please_enter_your_phone {
    return Intl.message(
      'Please enter your valid Phone',
      name: 'please_enter_your_phone',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Address`
  String get please_enter_your_address {
    return Intl.message(
      'Please Enter Your Address',
      name: 'please_enter_your_address',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Valid Mobile Number`
  String get please_enter_your_mobile_number {
    return Intl.message(
      'Please Enter Valid Mobile Number',
      name: 'please_enter_your_mobile_number',
      desc: '',
      args: [],
    );
  }

  /// `Mobile Number`
  String get mobile_number {
    return Intl.message(
      'Mobile Number',
      name: 'mobile_number',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Gender`
  String get gender {
    return Intl.message(
      'Gender',
      name: 'gender',
      desc: '',
      args: [],
    );
  }

  /// `Male`
  String get male {
    return Intl.message(
      'Male',
      name: 'male',
      desc: '',
      args: [],
    );
  }

  /// `Female`
  String get female {
    return Intl.message(
      'Female',
      name: 'female',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Date Of Birth`
  String get please_enter_date_of_birth {
    return Intl.message(
      'Please Enter Date Of Birth',
      name: 'please_enter_date_of_birth',
      desc: '',
      args: [],
    );
  }

  /// `Date of Birth`
  String get date_of_birth {
    return Intl.message(
      'Date of Birth',
      name: 'date_of_birth',
      desc: '',
      args: [],
    );
  }

  /// `Age`
  String get age {
    return Intl.message(
      'Age',
      name: 'age',
      desc: '',
      args: [],
    );
  }

  /// `Height`
  String get height {
    return Intl.message(
      'Height',
      name: 'height',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get weight {
    return Intl.message(
      'Weight',
      name: 'weight',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Goal`
  String get goal {
    return Intl.message(
      'Goal',
      name: 'goal',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any Trainer`
  String get you_do_not_have_any_trainer {
    return Intl.message(
      'You don\'t have any Trainer',
      name: 'you_do_not_have_any_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Assign to Member`
  String get assign_to_member {
    return Intl.message(
      'Assign to Member',
      name: 'assign_to_member',
      desc: '',
      args: [],
    );
  }

  /// `Search Member`
  String get search_member {
    return Intl.message(
      'Search Member',
      name: 'search_member',
      desc: '',
      args: [],
    );
  }

  /// `Search Exercise`
  String get search_exercise {
    return Intl.message(
      'Search Exercise',
      name: 'search_exercise',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any Member`
  String get you_do_not_have_any_member {
    return Intl.message(
      'You don\'t have any Member',
      name: 'you_do_not_have_any_member',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any Exercise`
  String get you_do_not_have_any_exercise {
    return Intl.message(
      'You don\'t have any Exercise',
      name: 'you_do_not_have_any_exercise',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Trainer`
  String get trainer {
    return Intl.message(
      'Trainer',
      name: 'trainer',
      desc: '',
      args: [],
    );
  }

  /// `Let’s shape Yourself`
  String get let_s_shape_yourself {
    return Intl.message(
      'Let’s shape Yourself',
      name: 'let_s_shape_yourself',
      desc: '',
      args: [],
    );
  }

  /// `Workout`
  String get workout {
    return Intl.message(
      'Workout',
      name: 'workout',
      desc: '',
      args: [],
    );
  }

  /// `See all`
  String get see_all {
    return Intl.message(
      'See all',
      name: 'see_all',
      desc: '',
      args: [],
    );
  }

  /// `No Data Available`
  String get no_data_available {
    return Intl.message(
      'No Data Available',
      name: 'no_data_available',
      desc: '',
      args: [],
    );
  }

  /// `Workout Categories`
  String get workout_categories {
    return Intl.message(
      'Workout Categories',
      name: 'workout_categories',
      desc: '',
      args: [],
    );
  }

  /// `My Membership`
  String get my_membership {
    return Intl.message(
      'My Membership',
      name: 'my_membership',
      desc: '',
      args: [],
    );
  }

  /// `GYM Trainer App`
  String get gym_trainer_app {
    return Intl.message(
      'GYM Trainer App',
      name: 'gym_trainer_app',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit from GYM Trainer App?`
  String get are_you_sure_you_want_to_exit_from_gym_trainer_app {
    return Intl.message(
      'Are you sure you want to exit from GYM Trainer App?',
      name: 'are_you_sure_you_want_to_exit_from_gym_trainer_app',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Switch to`
  String get switch_to {
    return Intl.message(
      'Switch to',
      name: 'switch_to',
      desc: '',
      args: [],
    );
  }

  /// `Admin`
  String get admin {
    return Intl.message(
      'Admin',
      name: 'admin',
      desc: '',
      args: [],
    );
  }

  /// `Enable Dark Mode`
  String get enable_dark_mode {
    return Intl.message(
      'Enable Dark Mode',
      name: 'enable_dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Exercises`
  String get exercises {
    return Intl.message(
      'Exercises',
      name: 'exercises',
      desc: '',
      args: [],
    );
  }

  /// `Tap To Add`
  String get tap_to_add {
    return Intl.message(
      'Tap To Add',
      name: 'tap_to_add',
      desc: '',
      args: [],
    );
  }

  /// `Workout Category`
  String get workout_category {
    return Intl.message(
      'Workout Category',
      name: 'workout_category',
      desc: '',
      args: [],
    );
  }

  /// `Membership Plan`
  String get membership_plan {
    return Intl.message(
      'Membership Plan',
      name: 'membership_plan',
      desc: '',
      args: [],
    );
  }

  /// `Class Schedule`
  String get class_schedule {
    return Intl.message(
      'Class Schedule',
      name: 'class_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get account {
    return Intl.message(
      'Account',
      name: 'account',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get log_out {
    return Intl.message(
      'Log out',
      name: 'log_out',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to Logout?`
  String get are_you_sure_want_to_logout {
    return Intl.message(
      'Are you sure want to Logout?',
      name: 'are_you_sure_want_to_logout',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Trainer Plan`
  String get trainer_plan {
    return Intl.message(
      'Trainer Plan',
      name: 'trainer_plan',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to Delete`
  String get are_you_sure_want_to_delete {
    return Intl.message(
      'Are you sure want to Delete',
      name: 'are_you_sure_want_to_delete',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Current Package`
  String get current_package {
    return Intl.message(
      'Current Package',
      name: 'current_package',
      desc: '',
      args: [],
    );
  }

  /// `Select Specialization`
  String get select_specialization {
    return Intl.message(
      'Select Specialization',
      name: 'select_specialization',
      desc: '',
      args: [],
    );
  }

  /// `Password not match.`
  String get password_not_match {
    return Intl.message(
      'Password not match.',
      name: 'password_not_match',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get edit_profile {
    return Intl.message(
      'Edit Profile',
      name: 'edit_profile',
      desc: '',
      args: [],
    );
  }

  /// `Password updated successfully`
  String get password_updated_successfully {
    return Intl.message(
      'Password updated successfully',
      name: 'password_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `View Packages`
  String get view_packages {
    return Intl.message(
      'View Packages',
      name: 'view_packages',
      desc: '',
      args: [],
    );
  }

  /// `View Membership`
  String get view_membership {
    return Intl.message(
      'View Membership',
      name: 'view_membership',
      desc: '',
      args: [],
    );
  }

  /// `Edit Packages`
  String get edit_packages {
    return Intl.message(
      'Edit Packages',
      name: 'edit_packages',
      desc: '',
      args: [],
    );
  }

  /// `Edit Membership`
  String get edit_membership {
    return Intl.message(
      'Edit Membership',
      name: 'edit_membership',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Membership Name`
  String get please_enter_membership_name {
    return Intl.message(
      'Please Enter Membership Name',
      name: 'please_enter_membership_name',
      desc: '',
      args: [],
    );
  }

  /// `Packages Name`
  String get package_name {
    return Intl.message(
      'Packages Name',
      name: 'package_name',
      desc: '',
      args: [],
    );
  }

  /// `Membership Name`
  String get membership_name {
    return Intl.message(
      'Membership Name',
      name: 'membership_name',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Amount`
  String get please_enter_amount {
    return Intl.message(
      'Please Enter Amount',
      name: 'please_enter_amount',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get amount {
    return Intl.message(
      'Amount',
      name: 'amount',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Period`
  String get please_enter_period {
    return Intl.message(
      'Please Enter Period',
      name: 'please_enter_period',
      desc: '',
      args: [],
    );
  }

  /// `Period(Days)`
  String get period_days {
    return Intl.message(
      'Period(Days)',
      name: 'period_days',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Class Limit`
  String get please_enter_class_limit {
    return Intl.message(
      'Please Enter Class Limit',
      name: 'please_enter_class_limit',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Member Limit`
  String get please_enter_member_limit {
    return Intl.message(
      'Please Enter Member Limit',
      name: 'please_enter_member_limit',
      desc: '',
      args: [],
    );
  }

  /// `Member Limit`
  String get member_limit {
    return Intl.message(
      'Member Limit',
      name: 'member_limit',
      desc: '',
      args: [],
    );
  }

  /// `Class Limit`
  String get class_limit {
    return Intl.message(
      'Class Limit',
      name: 'class_limit',
      desc: '',
      args: [],
    );
  }

  /// `Recurring Package`
  String get recurring_package {
    return Intl.message(
      'Recurring Package',
      name: 'recurring_package',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: '',
      args: [],
    );
  }

  /// `Attach Documents`
  String get attach_document {
    return Intl.message(
      'Attach Documents',
      name: 'attach_document',
      desc: '',
      args: [],
    );
  }

  /// `Attachment`
  String get attachment {
    return Intl.message(
      'Attachment',
      name: 'attachment',
      desc: '',
      args: [],
    );
  }

  /// `Save Packages`
  String get save_packages {
    return Intl.message(
      'Save Packages',
      name: 'save_packages',
      desc: '',
      args: [],
    );
  }

  /// `Add Packages`
  String get add_packages {
    return Intl.message(
      'Add Packages',
      name: 'add_packages',
      desc: '',
      args: [],
    );
  }

  /// `ADD MEMBERSHIP`
  String get add_membership {
    return Intl.message(
      'ADD MEMBERSHIP',
      name: 'add_membership',
      desc: '',
      args: [],
    );
  }

  /// `SAVE MEMBERSHIP`
  String get save_membership {
    return Intl.message(
      'SAVE MEMBERSHIP',
      name: 'save_membership',
      desc: '',
      args: [],
    );
  }

  /// `Please give a storage Read & Write permission`
  String get please_give_a_storage_read_write_and_permission {
    return Intl.message(
      'Please give a storage Read & Write permission',
      name: 'please_give_a_storage_read_write_and_permission',
      desc: '',
      args: [],
    );
  }

  /// `Please select valid File`
  String get please_select_valid_file {
    return Intl.message(
      'Please select valid File',
      name: 'please_select_valid_file',
      desc: '',
      args: [],
    );
  }

  /// `Attachment file size allow only 2 MB`
  String get attachment_file_size_allow_only_mb {
    return Intl.message(
      'Attachment file size allow only 2 MB',
      name: 'attachment_file_size_allow_only_mb',
      desc: '',
      args: [],
    );
  }

  /// `Edit Trainer`
  String get edit_trainer {
    return Intl.message(
      'Edit Trainer',
      name: 'edit_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Add Trainer`
  String get add_trainer {
    return Intl.message(
      'Add Trainer',
      name: 'add_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Full Name`
  String get please_enter_full_name {
    return Intl.message(
      'Please Enter Full Name',
      name: 'please_enter_full_name',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get full_name {
    return Intl.message(
      'Full Name',
      name: 'full_name',
      desc: '',
      args: [],
    );
  }

  /// `Select Membership`
  String get select_membership {
    return Intl.message(
      'Select Membership',
      name: 'select_membership',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Valid Email`
  String get please_enter_valid_email {
    return Intl.message(
      'Please Enter Valid Email',
      name: 'please_enter_valid_email',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Password`
  String get please_enter_password {
    return Intl.message(
      'Please Enter Password',
      name: 'please_enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Valid Mobile Number`
  String get please_enter_valid_mobile_number {
    return Intl.message(
      'Please Enter Valid Mobile Number',
      name: 'please_enter_valid_mobile_number',
      desc: '',
      args: [],
    );
  }

  /// `This is WhatsApp number`
  String get this_is_whatsapp_number {
    return Intl.message(
      'This is WhatsApp number',
      name: 'this_is_whatsapp_number',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Valid WhatsApp Number`
  String get please_enter_valid_whatsapp_number {
    return Intl.message(
      'Please Enter Valid WhatsApp Number',
      name: 'please_enter_valid_whatsapp_number',
      desc: '',
      args: [],
    );
  }

  /// `WhatsApp Number`
  String get whatsapp_number {
    return Intl.message(
      'WhatsApp Number',
      name: 'whatsapp_number',
      desc: '',
      args: [],
    );
  }

  /// `Profile Photo`
  String get profile_photo {
    return Intl.message(
      'Profile Photo',
      name: 'profile_photo',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Membership`
  String get please_select_membership {
    return Intl.message(
      'Please Select Membership',
      name: 'please_select_membership',
      desc: '',
      args: [],
    );
  }

  /// `SAVE TRAINER`
  String get save_trainer {
    return Intl.message(
      'SAVE TRAINER',
      name: 'save_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Add Specialization`
  String get add_specialization {
    return Intl.message(
      'Add Specialization',
      name: 'add_specialization',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Specialization`
  String get please_enter_specialization {
    return Intl.message(
      'Please Enter Specialization',
      name: 'please_enter_specialization',
      desc: '',
      args: [],
    );
  }

  /// `Enter Specialization`
  String get enter_specialization {
    return Intl.message(
      'Enter Specialization',
      name: 'enter_specialization',
      desc: '',
      args: [],
    );
  }

  /// `Specialization Added Successfully`
  String get specialization_added_successfully {
    return Intl.message(
      'Specialization Added Successfully',
      name: 'specialization_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `How Old Are You?`
  String get how_old_are_you {
    return Intl.message(
      'How Old Are You?',
      name: 'how_old_are_you',
      desc: '',
      args: [],
    );
  }

  /// `Age in Years. This will help you to personalize`
  String get age_in_years_this_will_help_you_to_personalize {
    return Intl.message(
      'Age in Years. This will help you to personalize',
      name: 'age_in_years_this_will_help_you_to_personalize',
      desc: '',
      args: [],
    );
  }

  /// `An exercise program plan that suits you.`
  String get an_exercise_program_plan_that_suits_you {
    return Intl.message(
      'An exercise program plan that suits you.',
      name: 'an_exercise_program_plan_that_suits_you',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continues {
    return Intl.message(
      'Continue',
      name: 'continues',
      desc: '',
      args: [],
    );
  }

  /// `Today’s Class`
  String get today_s_class {
    return Intl.message(
      'Today’s Class',
      name: 'today_s_class',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any Class Schedule`
  String get you_do_not_have_any_class_schedule {
    return Intl.message(
      'You don\'t have any Class Schedule',
      name: 'you_do_not_have_any_class_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Since`
  String get member_since {
    return Intl.message(
      'Since',
      name: 'member_since',
      desc: '',
      args: [],
    );
  }

  /// `My Exercises`
  String get my_exercises {
    return Intl.message(
      'My Exercises',
      name: 'my_exercises',
      desc: '',
      args: [],
    );
  }

  /// `My Workout`
  String get my_workout {
    return Intl.message(
      'My Workout',
      name: 'my_workout',
      desc: '',
      args: [],
    );
  }

  /// `My Membership Plan`
  String get my_membership_plan {
    return Intl.message(
      'My Membership Plan',
      name: 'my_membership_plan',
      desc: '',
      args: [],
    );
  }

  /// `Tell Us About Your Self`
  String get tell_us_about_your_self {
    return Intl.message(
      'Tell Us About Your Self',
      name: 'tell_us_about_your_self',
      desc: '',
      args: [],
    );
  }

  /// `To give better experience and result to`
  String get to_give_better_experience_and_result_to {
    return Intl.message(
      'To give better experience and result to',
      name: 'to_give_better_experience_and_result_to',
      desc: '',
      args: [],
    );
  }

  /// `your members, we need to know your gender.`
  String get your_members_we_need_to_know_your_gender {
    return Intl.message(
      'your members, we need to know your gender.',
      name: 'your_members_we_need_to_know_your_gender',
      desc: '',
      args: [],
    );
  }

  /// `What is Your Height?`
  String get what_is_your_height {
    return Intl.message(
      'What is Your Height?',
      name: 'what_is_your_height',
      desc: '',
      args: [],
    );
  }

  /// `Height in CM. Don’t worry, you can always`
  String get height_in_cm_do_not_worry_you_can_always {
    return Intl.message(
      'Height in CM. Don’t worry, you can always',
      name: 'height_in_cm_do_not_worry_you_can_always',
      desc: '',
      args: [],
    );
  }

  /// `change it letter.`
  String get change_it_letter {
    return Intl.message(
      'change it letter.',
      name: 'change_it_letter',
      desc: '',
      args: [],
    );
  }

  /// `Membership`
  String get membership {
    return Intl.message(
      'Membership',
      name: 'membership',
      desc: '',
      args: [],
    );
  }

  /// `Total Member`
  String get total_member {
    return Intl.message(
      'Total Member',
      name: 'total_member',
      desc: '',
      args: [],
    );
  }

  /// `Join Virtual Class`
  String get join_virtual_class {
    return Intl.message(
      'Join Virtual Class',
      name: 'join_virtual_class',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get expired {
    return Intl.message(
      'Expired',
      name: 'expired',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Goal`
  String get please_enter_your_goal {
    return Intl.message(
      'Please Enter Your Goal',
      name: 'please_enter_your_goal',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Age`
  String get please_enter_your_age {
    return Intl.message(
      'Please Enter Your Age',
      name: 'please_enter_your_age',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Weight`
  String get please_enter_your_weight {
    return Intl.message(
      'Please Enter Your Weight',
      name: 'please_enter_your_weight',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Height`
  String get please_enter_your_height {
    return Intl.message(
      'Please Enter Your Height',
      name: 'please_enter_your_height',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any Workout`
  String get you_do_not_have_any_workout {
    return Intl.message(
      'You don\'t have any Workout',
      name: 'you_do_not_have_any_workout',
      desc: '',
      args: [],
    );
  }

  /// `Fill Your Profile`
  String get fill_your_profile {
    return Intl.message(
      'Fill Your Profile',
      name: 'fill_your_profile',
      desc: '',
      args: [],
    );
  }

  /// `Don’t worry you can always change it letter, or`
  String get do_not_worry_you_can_always_change_it_letter_or {
    return Intl.message(
      'Don’t worry you can always change it letter, or',
      name: 'do_not_worry_you_can_always_change_it_letter_or',
      desc: '',
      args: [],
    );
  }

  /// `you can skip it for now.`
  String get you_can_skip_it_for_now {
    return Intl.message(
      'you can skip it for now.',
      name: 'you_can_skip_it_for_now',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `DOB`
  String get dob {
    return Intl.message(
      'DOB',
      name: 'dob',
      desc: '',
      args: [],
    );
  }

  /// `Role`
  String get role {
    return Intl.message(
      'Role',
      name: 'role',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `State`
  String get state {
    return Intl.message(
      'State',
      name: 'state',
      desc: '',
      args: [],
    );
  }

  /// `Zip Code`
  String get zip_code {
    return Intl.message(
      'Zip Code',
      name: 'zip_code',
      desc: '',
      args: [],
    );
  }

  /// `Country`
  String get country {
    return Intl.message(
      'Country',
      name: 'country',
      desc: '',
      args: [],
    );
  }

  /// `Specialization`
  String get specialization {
    return Intl.message(
      'Specialization',
      name: 'specialization',
      desc: '',
      args: [],
    );
  }

  /// `Specialization List`
  String get specialization_list {
    return Intl.message(
      'Specialization List',
      name: 'specialization_list',
      desc: '',
      args: [],
    );
  }

  /// `WhatsApp is not installed on the device`
  String get whatsapp_is_not_installed_on_the_device {
    return Intl.message(
      'WhatsApp is not installed on the device',
      name: 'whatsapp_is_not_installed_on_the_device',
      desc: '',
      args: [],
    );
  }

  /// `Open WhatsApp Chat`
  String get open_whatsapp_chat {
    return Intl.message(
      'Open WhatsApp Chat',
      name: 'open_whatsapp_chat',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Trainer Profile`
  String get trainer_profile {
    return Intl.message(
      'Trainer Profile',
      name: 'trainer_profile',
      desc: '',
      args: [],
    );
  }

  /// `What is Your Weight?`
  String get what_is_your_weight {
    return Intl.message(
      'What is Your Weight?',
      name: 'what_is_your_weight',
      desc: '',
      args: [],
    );
  }

  /// `Weight in KG. Don’t Worry, you can always`
  String get weight_in_kg_do_not_worry_you_can_always {
    return Intl.message(
      'Weight in KG. Don’t Worry, you can always',
      name: 'weight_in_kg_do_not_worry_you_can_always',
      desc: '',
      args: [],
    );
  }

  /// `Select Package`
  String get select_package {
    return Intl.message(
      'Select Package',
      name: 'select_package',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Package`
  String get please_select_package {
    return Intl.message(
      'Please Select Package',
      name: 'please_select_package',
      desc: '',
      args: [],
    );
  }

  /// `View Workout Category`
  String get view_workout_category {
    return Intl.message(
      'View Workout Category',
      name: 'view_workout_category',
      desc: '',
      args: [],
    );
  }

  /// `Edit Workout Category`
  String get edit_workout_category {
    return Intl.message(
      'Edit Workout Category',
      name: 'edit_workout_category',
      desc: '',
      args: [],
    );
  }

  /// `Add Workout Category`
  String get add_workout_category {
    return Intl.message(
      'Add Workout Category',
      name: 'add_workout_category',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Title`
  String get please_enter_title {
    return Intl.message(
      'Please Enter Title',
      name: 'please_enter_title',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `EDIT CATEGORY`
  String get edit_category {
    return Intl.message(
      'EDIT CATEGORY',
      name: 'edit_category',
      desc: '',
      args: [],
    );
  }

  /// `Add CATEGORY`
  String get add_category {
    return Intl.message(
      'Add CATEGORY',
      name: 'add_category',
      desc: '',
      args: [],
    );
  }

  /// `Add Exercise`
  String get add_exercise {
    return Intl.message(
      'Add Exercise',
      name: 'add_exercise',
      desc: '',
      args: [],
    );
  }

  /// `Edit Exercise`
  String get edit_exercise {
    return Intl.message(
      'Edit Exercise',
      name: 'edit_exercise',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Exercise Title`
  String get please_enter_your_exercise_title {
    return Intl.message(
      'Please Enter Your Exercise Title',
      name: 'please_enter_your_exercise_title',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Title`
  String get exercise_title {
    return Intl.message(
      'Exercise Title',
      name: 'exercise_title',
      desc: '',
      args: [],
    );
  }

  /// `Select Category`
  String get select_category {
    return Intl.message(
      'Select Category',
      name: 'select_category',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Image`
  String get exercise_image {
    return Intl.message(
      'Exercise Image',
      name: 'exercise_image',
      desc: '',
      args: [],
    );
  }

  /// `Select Exercise Image`
  String get select_exercise_image {
    return Intl.message(
      'Select Exercise Image',
      name: 'select_exercise_image',
      desc: '',
      args: [],
    );
  }

  /// `CHOOSE`
  String get choose {
    return Intl.message(
      'CHOOSE',
      name: 'choose',
      desc: '',
      args: [],
    );
  }

  /// `YouTube URL`
  String get youtube_url {
    return Intl.message(
      'YouTube URL',
      name: 'youtube_url',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message(
      'Notes',
      name: 'notes',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Exercise Image or Youtube URL`
  String get please_select_exercise_image_or_youtube_url {
    return Intl.message(
      'Please Select Exercise Image or Youtube URL',
      name: 'please_select_exercise_image_or_youtube_url',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Valid Youtube Link`
  String get please_enter_valid_youtube_link {
    return Intl.message(
      'Please Enter Valid Youtube Link',
      name: 'please_enter_valid_youtube_link',
      desc: '',
      args: [],
    );
  }

  /// `Exercise added Successfully`
  String get exercise_added_successfully {
    return Intl.message(
      'Exercise added Successfully',
      name: 'exercise_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Exercise already exist`
  String get exercise_already_exist {
    return Intl.message(
      'Exercise already exist',
      name: 'exercise_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any Workout Category`
  String get you_do_not_have_any_workout_category {
    return Intl.message(
      'You don\'t have any Workout Category',
      name: 'you_do_not_have_any_workout_category',
      desc: '',
      args: [],
    );
  }

  /// `Add Workout`
  String get add_workout {
    return Intl.message(
      'Add Workout',
      name: 'add_workout',
      desc: '',
      args: [],
    );
  }

  /// `Workout Title`
  String get workout_title {
    return Intl.message(
      'Workout Title',
      name: 'workout_title',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Workout Title`
  String get please_enter_workout_title {
    return Intl.message(
      'Please Enter Workout Title',
      name: 'please_enter_workout_title',
      desc: '',
      args: [],
    );
  }

  /// `Enter Workout Title`
  String get enter_workout_title {
    return Intl.message(
      'Enter Workout Title',
      name: 'enter_workout_title',
      desc: '',
      args: [],
    );
  }

  /// `Workout For`
  String get workout_for {
    return Intl.message(
      'Workout For',
      name: 'workout_for',
      desc: '',
      args: [],
    );
  }

  /// `Select Item`
  String get select_item {
    return Intl.message(
      'Select Item',
      name: 'select_item',
      desc: '',
      args: [],
    );
  }

  /// `Assign Package`
  String get assign_package {
    return Intl.message(
      'Assign Package',
      name: 'assign_package',
      desc: '',
      args: [],
    );
  }

  /// `Duration(Weeks)`
  String get duration_weeks {
    return Intl.message(
      'Duration(Weeks)',
      name: 'duration_weeks',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Duration(Weeks)`
  String get please_enter_duration_weeks {
    return Intl.message(
      'Please Enter Duration(Weeks)',
      name: 'please_enter_duration_weeks',
      desc: '',
      args: [],
    );
  }

  /// `Enter Workout Duration`
  String get enter_workout_duration {
    return Intl.message(
      'Enter Workout Duration',
      name: 'enter_workout_duration',
      desc: '',
      args: [],
    );
  }

  /// `Workout Type`
  String get workout_type {
    return Intl.message(
      'Workout Type',
      name: 'workout_type',
      desc: '',
      args: [],
    );
  }

  /// `Free`
  String get free {
    return Intl.message(
      'Free',
      name: 'free',
      desc: '',
      args: [],
    );
  }

  /// `Premium`
  String get premium {
    return Intl.message(
      'Premium',
      name: 'premium',
      desc: '',
      args: [],
    );
  }

  /// `Total Trainer`
  String get total_trainer {
    return Intl.message(
      'Total Trainer',
      name: 'total_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Popular Workout`
  String get popular_workout {
    return Intl.message(
      'Popular Workout',
      name: 'popular_workout',
      desc: '',
      args: [],
    );
  }

  /// `Popular Packages`
  String get popular_packages {
    return Intl.message(
      'Popular Packages',
      name: 'popular_packages',
      desc: '',
      args: [],
    );
  }

  /// `Enable Dark Mode`
  String get enable_to_dark_mode {
    return Intl.message(
      'Enable Dark Mode',
      name: 'enable_to_dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Trainer Packages`
  String get trainer_packages {
    return Intl.message(
      'Trainer Packages',
      name: 'trainer_packages',
      desc: '',
      args: [],
    );
  }

  /// `Enable Mail Notification`
  String get enable_mail_notification {
    return Intl.message(
      'Enable Mail Notification',
      name: 'enable_mail_notification',
      desc: '',
      args: [],
    );
  }

  /// `Enable`
  String get enable {
    return Intl.message(
      'Enable',
      name: 'enable',
      desc: '',
      args: [],
    );
  }

  /// `Expiration Mail Notification`
  String get expiration_mail_notification {
    return Intl.message(
      'Expiration Mail Notification',
      name: 'expiration_mail_notification',
      desc: '',
      args: [],
    );
  }

  /// `Membership Runs Out`
  String get membership_runs_out {
    return Intl.message(
      'Membership Runs Out',
      name: 'membership_runs_out',
      desc: '',
      args: [],
    );
  }

  /// `Email settings`
  String get email_setting {
    return Intl.message(
      'Email settings',
      name: 'email_setting',
      desc: '',
      args: [],
    );
  }

  /// `General settings`
  String get general_setting {
    return Intl.message(
      'General settings',
      name: 'general_setting',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your GYM Name`
  String get please_enter_your_gym_name {
    return Intl.message(
      'Please Enter Your GYM Name',
      name: 'please_enter_your_gym_name',
      desc: '',
      args: [],
    );
  }

  /// `Gym Name`
  String get gym_name {
    return Intl.message(
      'Gym Name',
      name: 'gym_name',
      desc: '',
      args: [],
    );
  }

  /// `Starting Year`
  String get starting_year {
    return Intl.message(
      'Starting Year',
      name: 'starting_year',
      desc: '',
      args: [],
    );
  }

  /// `Gym Address`
  String get gym_address {
    return Intl.message(
      'Gym Address',
      name: 'gym_address',
      desc: '',
      args: [],
    );
  }

  /// `Official Phone Number`
  String get official_phone_number {
    return Intl.message(
      'Official Phone Number',
      name: 'official_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Official Email`
  String get official_email {
    return Intl.message(
      'Official Email',
      name: 'official_email',
      desc: '',
      args: [],
    );
  }

  /// `Choose Image`
  String get choose_image {
    return Intl.message(
      'Choose Image',
      name: 'choose_image',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Localization settings`
  String get localization_setting {
    return Intl.message(
      'Localization settings',
      name: 'localization_setting',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get select_language {
    return Intl.message(
      'Select Language',
      name: 'select_language',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: '',
      args: [],
    );
  }

  /// `Select Currency`
  String get select_currency {
    return Intl.message(
      'Select Currency',
      name: 'select_currency',
      desc: '',
      args: [],
    );
  }

  /// `Select Timezone`
  String get select_timezone {
    return Intl.message(
      'Select Timezone',
      name: 'select_timezone',
      desc: '',
      args: [],
    );
  }

  /// `Select Date Format`
  String get select_date_format {
    return Intl.message(
      'Select Date Format',
      name: 'select_date_format',
      desc: '',
      args: [],
    );
  }

  /// `Measurement units`
  String get measurement_units {
    return Intl.message(
      'Measurement units',
      name: 'measurement_units',
      desc: '',
      args: [],
    );
  }

  /// `kg`
  String get kg {
    return Intl.message(
      'kg',
      name: 'kg',
      desc: '',
      args: [],
    );
  }

  /// `lbs`
  String get lbs {
    return Intl.message(
      'lbs',
      name: 'lbs',
      desc: '',
      args: [],
    );
  }

  /// `Centimeter`
  String get centimeter {
    return Intl.message(
      'Centimeter',
      name: 'centimeter',
      desc: '',
      args: [],
    );
  }

  /// `Change Plan`
  String get change_plan {
    return Intl.message(
      'Change Plan',
      name: 'change_plan',
      desc: '',
      args: [],
    );
  }

  /// `Inches`
  String get inches {
    return Intl.message(
      'Inches',
      name: 'inches',
      desc: '',
      args: [],
    );
  }

  /// `Chest`
  String get chest {
    return Intl.message(
      'Chest',
      name: 'chest',
      desc: '',
      args: [],
    );
  }

  /// `Waist`
  String get waist {
    return Intl.message(
      'Waist',
      name: 'waist',
      desc: '',
      args: [],
    );
  }

  /// `Thigh`
  String get thigh {
    return Intl.message(
      'Thigh',
      name: 'thigh',
      desc: '',
      args: [],
    );
  }

  /// `Arms`
  String get arms {
    return Intl.message(
      'Arms',
      name: 'arms',
      desc: '',
      args: [],
    );
  }

  /// `Payment settings`
  String get payment_setting {
    return Intl.message(
      'Payment settings',
      name: 'payment_setting',
      desc: '',
      args: [],
    );
  }

  /// `Cash - Offline`
  String get cash_offline {
    return Intl.message(
      'Cash - Offline',
      name: 'cash_offline',
      desc: '',
      args: [],
    );
  }

  /// `Enable Sandbox`
  String get enable_sandbox {
    return Intl.message(
      'Enable Sandbox',
      name: 'enable_sandbox',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your PayPal Email Id`
  String get please_enter_your_paypal_email_id {
    return Intl.message(
      'Please Enter Your PayPal Email Id',
      name: 'please_enter_your_paypal_email_id',
      desc: '',
      args: [],
    );
  }

  /// `PayPal Email ID`
  String get paypal_email_id {
    return Intl.message(
      'PayPal Email ID',
      name: 'paypal_email_id',
      desc: '',
      args: [],
    );
  }

  /// `U.S.Dollar`
  String get us_dollar {
    return Intl.message(
      'U.S.Dollar',
      name: 'us_dollar',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Secret Key`
  String get please_enter_your_secret_key {
    return Intl.message(
      'Please Enter Your Secret Key',
      name: 'please_enter_your_secret_key',
      desc: '',
      args: [],
    );
  }

  /// `Secret Key`
  String get secret_key {
    return Intl.message(
      'Secret Key',
      name: 'secret_key',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Publishable Key`
  String get please_enter_your_publishable_key {
    return Intl.message(
      'Please Enter Your Publishable Key',
      name: 'please_enter_your_publishable_key',
      desc: '',
      args: [],
    );
  }

  /// `Publishable Key`
  String get publishable_key {
    return Intl.message(
      'Publishable Key',
      name: 'publishable_key',
      desc: '',
      args: [],
    );
  }

  /// `Pincode`
  String get pincode {
    return Intl.message(
      'Pincode',
      name: 'pincode',
      desc: '',
      args: [],
    );
  }

  /// `Virtual class settings`
  String get virtual_class_settings {
    return Intl.message(
      'Virtual class settings',
      name: 'virtual_class_settings',
      desc: '',
      args: [],
    );
  }

  /// `Payment settings`
  String get payment_settings {
    return Intl.message(
      'Payment settings',
      name: 'payment_settings',
      desc: '',
      args: [],
    );
  }

  /// `Localization`
  String get localization {
    return Intl.message(
      'Localization',
      name: 'localization',
      desc: '',
      args: [],
    );
  }

  /// `Email settings`
  String get email_settings {
    return Intl.message(
      'Email settings',
      name: 'email_settings',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get notification {
    return Intl.message(
      'Notifications',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Dark mode`
  String get dark_mode {
    return Intl.message(
      'Dark mode',
      name: 'dark_mode',
      desc: '',
      args: [],
    );
  }

  /// `Administrator is Trainer?`
  String get administrator_is_trainer {
    return Intl.message(
      'Administrator is Trainer?',
      name: 'administrator_is_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Virtual Class Schedule`
  String get virtual_class_schedule {
    return Intl.message(
      'Virtual Class Schedule',
      name: 'virtual_class_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Client Id`
  String get please_enter_your_clint_id {
    return Intl.message(
      'Please Enter Your Client Id',
      name: 'please_enter_your_clint_id',
      desc: '',
      args: [],
    );
  }

  /// `Client Id`
  String get clint_id {
    return Intl.message(
      'Client Id',
      name: 'clint_id',
      desc: '',
      args: [],
    );
  }

  /// `That will be provided by zoom.`
  String get that_will_be_provide_by_zoom {
    return Intl.message(
      'That will be provided by zoom.',
      name: 'that_will_be_provide_by_zoom',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Your Secret Client Id`
  String get please_enter_your_secret_client_id {
    return Intl.message(
      'Please Enter Your Secret Client Id',
      name: 'please_enter_your_secret_client_id',
      desc: '',
      args: [],
    );
  }

  /// `Client Secret ID`
  String get client_secret_id {
    return Intl.message(
      'Client Secret ID',
      name: 'client_secret_id',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Redirect Url`
  String get please_enter_redirect_url {
    return Intl.message(
      'Please Enter Redirect Url',
      name: 'please_enter_redirect_url',
      desc: '',
      args: [],
    );
  }

  /// `Please copy this Redirect URL and add in your zoom account Redirect URL.`
  String
      get please_copy_this_redirect_url_and_ass_in_your_zoom_account_redirect_url {
    return Intl.message(
      'Please copy this Redirect URL and add in your zoom account Redirect URL.',
      name:
          'please_copy_this_redirect_url_and_ass_in_your_zoom_account_redirect_url',
      desc: '',
      args: [],
    );
  }

  /// `Redirect URL`
  String get redirect_url {
    return Intl.message(
      'Redirect URL',
      name: 'redirect_url',
      desc: '',
      args: [],
    );
  }

  /// `Days`
  String get days {
    return Intl.message(
      'Days',
      name: 'days',
      desc: '',
      args: [],
    );
  }

  /// `View Details`
  String get view_details {
    return Intl.message(
      'View Details',
      name: 'view_details',
      desc: '',
      args: [],
    );
  }

  /// `Free for all`
  String get free_for_all {
    return Intl.message(
      'Free for all',
      name: 'free_for_all',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get select {
    return Intl.message(
      'Select',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `Selected`
  String get selected {
    return Intl.message(
      'Selected',
      name: 'selected',
      desc: '',
      args: [],
    );
  }

  /// `Member ID`
  String get member_id {
    return Intl.message(
      'Member ID',
      name: 'member_id',
      desc: '',
      args: [],
    );
  }

  /// `Current Plan`
  String get current_plan {
    return Intl.message(
      'Current Plan',
      name: 'current_plan',
      desc: '',
      args: [],
    );
  }

  /// `Assign Membership Plan`
  String get assign_membership_plan {
    return Intl.message(
      'Assign Membership Plan',
      name: 'assign_membership_plan',
      desc: '',
      args: [],
    );
  }

  /// `Assign Membership`
  String get assign_membership {
    return Intl.message(
      'Assign Membership',
      name: 'assign_membership',
      desc: '',
      args: [],
    );
  }

  /// `Package`
  String get package {
    return Intl.message(
      'Package',
      name: 'package',
      desc: '',
      args: [],
    );
  }

  /// `Total workout completed`
  String get total_workout_completed {
    return Intl.message(
      'Total workout completed',
      name: 'total_workout_completed',
      desc: '',
      args: [],
    );
  }

  /// `Triceps`
  String get triceps {
    return Intl.message(
      'Triceps',
      name: 'triceps',
      desc: '',
      args: [],
    );
  }

  /// `Assign Workout`
  String get assign_workout {
    return Intl.message(
      'Assign Workout',
      name: 'assign_workout',
      desc: '',
      args: [],
    );
  }

  /// `Assign to Trainer`
  String get assign_to_trainer {
    return Intl.message(
      'Assign to Trainer',
      name: 'assign_to_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Set`
  String get please_enter_set {
    return Intl.message(
      'Please Enter Set',
      name: 'please_enter_set',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Reps`
  String get please_enter_reps {
    return Intl.message(
      'Please Enter Reps',
      name: 'please_enter_reps',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Sec`
  String get please_enter_sec {
    return Intl.message(
      'Please Enter Sec',
      name: 'please_enter_sec',
      desc: '',
      args: [],
    );
  }

  /// `Please Enter Rest`
  String get please_enter_rest {
    return Intl.message(
      'Please Enter Rest',
      name: 'please_enter_rest',
      desc: '',
      args: [],
    );
  }

  /// `Set`
  String get set {
    return Intl.message(
      'Set',
      name: 'set',
      desc: '',
      args: [],
    );
  }

  /// `Reps`
  String get reps {
    return Intl.message(
      'Reps',
      name: 'reps',
      desc: '',
      args: [],
    );
  }

  /// `Sec`
  String get sec {
    return Intl.message(
      'Sec',
      name: 'sec',
      desc: '',
      args: [],
    );
  }

  /// `Rest`
  String get rest {
    return Intl.message(
      'Rest',
      name: 'rest',
      desc: '',
      args: [],
    );
  }

  /// `Let’s Start`
  String get lets_start {
    return Intl.message(
      'Let’s Start',
      name: 'lets_start',
      desc: '',
      args: [],
    );
  }

  /// `Weeks`
  String get weeks {
    return Intl.message(
      'Weeks',
      name: 'weeks',
      desc: '',
      args: [],
    );
  }

  /// `Videos`
  String get videos {
    return Intl.message(
      'Videos',
      name: 'videos',
      desc: '',
      args: [],
    );
  }

  /// `paid`
  String get paid {
    return Intl.message(
      'paid',
      name: 'paid',
      desc: '',
      args: [],
    );
  }

  /// `unpaid`
  String get un_paid {
    return Intl.message(
      'unpaid',
      name: 'un_paid',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Invoice ID`
  String get invoice_id {
    return Intl.message(
      'Invoice ID',
      name: 'invoice_id',
      desc: '',
      args: [],
    );
  }

  /// `Invoice`
  String get invoice {
    return Intl.message(
      'Invoice',
      name: 'invoice',
      desc: '',
      args: [],
    );
  }

  /// `Trainer Fees Payment`
  String get trainer_fees_payment {
    return Intl.message(
      'Trainer Fees Payment',
      name: 'trainer_fees_payment',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get sort_by {
    return Intl.message(
      'Sort by',
      name: 'sort_by',
      desc: '',
      args: [],
    );
  }

  /// `Income`
  String get income {
    return Intl.message(
      'Income',
      name: 'income',
      desc: '',
      args: [],
    );
  }

  /// `Create Workout`
  String get create_workout {
    return Intl.message(
      'Create Workout',
      name: 'create_workout',
      desc: '',
      args: [],
    );
  }

  /// `Create Custom Workout`
  String get create_custom_workout {
    return Intl.message(
      'Create Custom Workout',
      name: 'create_custom_workout',
      desc: '',
      args: [],
    );
  }

  /// `Member already exits`
  String get member_already_exits {
    return Intl.message(
      'Member already exits',
      name: 'member_already_exits',
      desc: '',
      args: [],
    );
  }

  /// `User Not Found.`
  String get user_not_found {
    return Intl.message(
      'User Not Found.',
      name: 'user_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email or phone number.`
  String get please_enter_a_valid_email_or_phone_number {
    return Intl.message(
      'Please enter a valid email or phone number.',
      name: 'please_enter_a_valid_email_or_phone_number',
      desc: '',
      args: [],
    );
  }

  /// `Email / Mobile Number`
  String get email_or_mobile_number {
    return Intl.message(
      'Email / Mobile Number',
      name: 'email_or_mobile_number',
      desc: '',
      args: [],
    );
  }

  /// `Member Profile`
  String get member_profile {
    return Intl.message(
      'Member Profile',
      name: 'member_profile',
      desc: '',
      args: [],
    );
  }

  /// `Progress`
  String get progress {
    return Intl.message(
      'Progress',
      name: 'progress',
      desc: '',
      args: [],
    );
  }

  /// `Personal`
  String get personal {
    return Intl.message(
      'Personal',
      name: 'personal',
      desc: '',
      args: [],
    );
  }

  /// `Membership List`
  String get membership_list {
    return Intl.message(
      'Membership List',
      name: 'membership_list',
      desc: '',
      args: [],
    );
  }

  /// `Search Membership`
  String get search_membership {
    return Intl.message(
      'Search Membership',
      name: 'search_membership',
      desc: '',
      args: [],
    );
  }

  /// `You Don't have any Packages`
  String get you_do_not_have_any_packages {
    return Intl.message(
      'You Don\'t have any Packages',
      name: 'you_do_not_have_any_packages',
      desc: '',
      args: [],
    );
  }

  /// `You Don't have any Membership`
  String get you_do_not_have_any_membership {
    return Intl.message(
      'You Don\'t have any Membership',
      name: 'you_do_not_have_any_membership',
      desc: '',
      args: [],
    );
  }

  /// `You Don't have any Class`
  String get you_do_not_have_any_class {
    return Intl.message(
      'You Don\'t have any Class',
      name: 'you_do_not_have_any_class',
      desc: '',
      args: [],
    );
  }

  /// `Membership Packages`
  String get membership_packages {
    return Intl.message(
      'Membership Packages',
      name: 'membership_packages',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get buy {
    return Intl.message(
      'Buy',
      name: 'buy',
      desc: '',
      args: [],
    );
  }

  /// `Week`
  String get week {
    return Intl.message(
      'Week',
      name: 'week',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `Update Password`
  String get update_password {
    return Intl.message(
      'Update Password',
      name: 'update_password',
      desc: '',
      args: [],
    );
  }

  /// `Class List`
  String get class_list {
    return Intl.message(
      'Class List',
      name: 'class_list',
      desc: '',
      args: [],
    );
  }

  /// `Search Class List`
  String get search_class_list {
    return Intl.message(
      'Search Class List',
      name: 'search_class_list',
      desc: '',
      args: [],
    );
  }

  /// `Search Trainer List`
  String get search_trainer_list {
    return Intl.message(
      'Search Trainer List',
      name: 'search_trainer_list',
      desc: '',
      args: [],
    );
  }

  /// `Join`
  String get join {
    return Intl.message(
      'Join',
      name: 'join',
      desc: '',
      args: [],
    );
  }

  /// `Mobile`
  String get mobile {
    return Intl.message(
      'Mobile',
      name: 'mobile',
      desc: '',
      args: [],
    );
  }

  /// `Plan`
  String get plan {
    return Intl.message(
      'Plan',
      name: 'plan',
      desc: '',
      args: [],
    );
  }

  /// `days left in packages`
  String get days_left_in_membership {
    return Intl.message(
      'days left in packages',
      name: 'days_left_in_membership',
      desc: '',
      args: [],
    );
  }

  /// `Recent Plans`
  String get recent_plans {
    return Intl.message(
      'Recent Plans',
      name: 'recent_plans',
      desc: '',
      args: [],
    );
  }

  /// `View Workout`
  String get view_workout {
    return Intl.message(
      'View Workout',
      name: 'view_workout',
      desc: '',
      args: [],
    );
  }

  /// `Whatsapp`
  String get whatsapp {
    return Intl.message(
      'Whatsapp',
      name: 'whatsapp',
      desc: '',
      args: [],
    );
  }

  /// `Pause`
  String get pause {
    return Intl.message(
      'Pause',
      name: 'pause',
      desc: '',
      args: [],
    );
  }

  /// `Resend code in`
  String get resend_code_in {
    return Intl.message(
      'Resend code in',
      name: 'resend_code_in',
      desc: '',
      args: [],
    );
  }

  /// `Resend code`
  String get resend_code {
    return Intl.message(
      'Resend code',
      name: 'resend_code',
      desc: '',
      args: [],
    );
  }

  /// `Verify with OTP`
  String get verify_with_otp {
    return Intl.message(
      'Verify with OTP',
      name: 'verify_with_otp',
      desc: '',
      args: [],
    );
  }

  /// `Enter SMS Code sent to`
  String get enter_sms_code_sent_to {
    return Intl.message(
      'Enter SMS Code sent to',
      name: 'enter_sms_code_sent_to',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid OTP`
  String get please_enter_valid_otp {
    return Intl.message(
      'Please enter valid OTP',
      name: 'please_enter_valid_otp',
      desc: '',
      args: [],
    );
  }

  /// `Verify Code`
  String get verify_code {
    return Intl.message(
      'Verify Code',
      name: 'verify_code',
      desc: '',
      args: [],
    );
  }

  /// `File downloaded successfully`
  String get file_downloaded_successfully {
    return Intl.message(
      'File downloaded successfully',
      name: 'file_downloaded_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Add exercises to workout`
  String get add_exercises_to_workout {
    return Intl.message(
      'Add exercises to workout',
      name: 'add_exercises_to_workout',
      desc: '',
      args: [],
    );
  }

  /// `Expense`
  String get expense {
    return Intl.message(
      'Expense',
      name: 'expense',
      desc: '',
      args: [],
    );
  }

  /// `Newest First`
  String get newest_first {
    return Intl.message(
      'Newest First',
      name: 'newest_first',
      desc: '',
      args: [],
    );
  }

  /// `Oldest First`
  String get oldest_first {
    return Intl.message(
      'Oldest First',
      name: 'oldest_first',
      desc: '',
      args: [],
    );
  }

  /// `Search anything here`
  String get search_anything_here {
    return Intl.message(
      'Search anything here',
      name: 'search_anything_here',
      desc: '',
      args: [],
    );
  }

  /// `Measurement`
  String get measurement {
    return Intl.message(
      'Measurement',
      name: 'measurement',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Data Update Successfully`
  String get exercise_data_update_successfully {
    return Intl.message(
      'Exercise Data Update Successfully',
      name: 'exercise_data_update_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Report`
  String get report {
    return Intl.message(
      'Report',
      name: 'report',
      desc: '',
      args: [],
    );
  }

  /// `Members`
  String get members {
    return Intl.message(
      'Members',
      name: 'members',
      desc: '',
      args: [],
    );
  }

  /// `Plans`
  String get plans {
    return Intl.message(
      'Plans',
      name: 'plans',
      desc: '',
      args: [],
    );
  }

  /// `My packages`
  String get my_packages {
    return Intl.message(
      'My packages',
      name: 'my_packages',
      desc: '',
      args: [],
    );
  }

  /// `Recent Packages`
  String get recent_packages {
    return Intl.message(
      'Recent Packages',
      name: 'recent_packages',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `New Member Arrived`
  String get new_member_arrived {
    return Intl.message(
      'New Member Arrived',
      name: 'new_member_arrived',
      desc: '',
      args: [],
    );
  }

  /// `New Members`
  String get new_members {
    return Intl.message(
      'New Members',
      name: 'new_members',
      desc: '',
      args: [],
    );
  }

  /// `Total Income`
  String get total_income {
    return Intl.message(
      'Total Income',
      name: 'total_income',
      desc: '',
      args: [],
    );
  }

  /// `Seconds`
  String get seconds {
    return Intl.message(
      'Seconds',
      name: 'seconds',
      desc: '',
      args: [],
    );
  }

  /// `You Don't have any plan`
  String get you_do_not_have_any_plan {
    return Intl.message(
      'You Don\'t have any plan',
      name: 'you_do_not_have_any_plan',
      desc: '',
      args: [],
    );
  }

  /// `Select Trainer`
  String get select_trainer {
    return Intl.message(
      'Select Trainer',
      name: 'select_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Workout not assign to member`
  String get workout_not_assign_to_member {
    return Intl.message(
      'Workout not assign to member',
      name: 'workout_not_assign_to_member',
      desc: '',
      args: [],
    );
  }

  /// `Recent Membership`
  String get recent_membership {
    return Intl.message(
      'Recent Membership',
      name: 'recent_membership',
      desc: '',
      args: [],
    );
  }

  /// `Select Workout Category`
  String get select_workout_category {
    return Intl.message(
      'Select Workout Category',
      name: 'select_workout_category',
      desc: '',
      args: [],
    );
  }

  /// `Membership History`
  String get membership_history {
    return Intl.message(
      'Membership History',
      name: 'membership_history',
      desc: '',
      args: [],
    );
  }

  /// `Select Workout`
  String get select_workout {
    return Intl.message(
      'Select Workout',
      name: 'select_workout',
      desc: '',
      args: [],
    );
  }

  /// `Select Class`
  String get select_class {
    return Intl.message(
      'Select Class',
      name: 'select_class',
      desc: '',
      args: [],
    );
  }

  /// `Select Exercise Category`
  String get select_exercise_category {
    return Intl.message(
      'Select Exercise Category',
      name: 'select_exercise_category',
      desc: '',
      args: [],
    );
  }

  /// `Select Exercise`
  String get select_exercise {
    return Intl.message(
      'Select Exercise',
      name: 'select_exercise',
      desc: '',
      args: [],
    );
  }

  /// `Ask your trainer to assign Workout`
  String get ask_your_trainer_to_assign_workout {
    return Intl.message(
      'Ask your trainer to assign Workout',
      name: 'ask_your_trainer_to_assign_workout',
      desc: '',
      args: [],
    );
  }

  /// `Extend Date`
  String get extend_date {
    return Intl.message(
      'Extend Date',
      name: 'extend_date',
      desc: '',
      args: [],
    );
  }

  /// `Email Notification`
  String get email_notification {
    return Intl.message(
      'Email Notification',
      name: 'email_notification',
      desc: '',
      args: [],
    );
  }

  /// `Extend Days`
  String get extend_days {
    return Intl.message(
      'Extend Days',
      name: 'extend_days',
      desc: '',
      args: [],
    );
  }

  /// `Edit Member`
  String get edit_member {
    return Intl.message(
      'Edit Member',
      name: 'edit_member',
      desc: '',
      args: [],
    );
  }

  /// `Email not matched`
  String get email_not_matched {
    return Intl.message(
      'Email not matched',
      name: 'email_not_matched',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Image`
  String get please_select_image {
    return Intl.message(
      'Please Select Image',
      name: 'please_select_image',
      desc: '',
      args: [],
    );
  }

  /// `Please Select Category`
  String get please_select_Category {
    return Intl.message(
      'Please Select Category',
      name: 'please_select_Category',
      desc: '',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message(
      'From',
      name: 'from',
      desc: '',
      args: [],
    );
  }

  /// `Please enter current password`
  String get please_enter_current_password {
    return Intl.message(
      'Please enter current password',
      name: 'please_enter_current_password',
      desc: '',
      args: [],
    );
  }

  /// `Duration`
  String get duration {
    return Intl.message(
      'Duration',
      name: 'duration',
      desc: '',
      args: [],
    );
  }

  /// `Selected Trainer`
  String get selected_trainer {
    return Intl.message(
      'Selected Trainer',
      name: 'selected_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Goals`
  String get exercise_goals {
    return Intl.message(
      'Exercise Goals',
      name: 'exercise_goals',
      desc: '',
      args: [],
    );
  }

  /// `Membership not assign`
  String get membership_not_assign {
    return Intl.message(
      'Membership not assign',
      name: 'membership_not_assign',
      desc: '',
      args: [],
    );
  }

  /// `No package assigned`
  String get no_package_assigned {
    return Intl.message(
      'No package assigned',
      name: 'no_package_assigned',
      desc: '',
      args: [],
    );
  }

  /// `Days left`
  String get days_left {
    return Intl.message(
      'Days left',
      name: 'days_left',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any Payment History`
  String get you_do_not_have_any_payment_history {
    return Intl.message(
      'You don\'t have any Payment History',
      name: 'you_do_not_have_any_payment_history',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any Income History`
  String get you_do_not_have_any_income_history {
    return Intl.message(
      'You don\'t have any Income History',
      name: 'you_do_not_have_any_income_history',
      desc: '',
      args: [],
    );
  }

  /// `Member Id Prefix`
  String get member_id_prefix {
    return Intl.message(
      'Member Id Prefix',
      name: 'member_id_prefix',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get current_password {
    return Intl.message(
      'Current Password',
      name: 'current_password',
      desc: '',
      args: [],
    );
  }

  /// `Ask Your trainer to assign Workout Category`
  String get ask_your_trainer_to_assign_workout_category {
    return Intl.message(
      'Ask Your trainer to assign Workout Category',
      name: 'ask_your_trainer_to_assign_workout_category',
      desc: '',
      args: [],
    );
  }

  /// `You don't have acccess`
  String get you_have_no_access {
    return Intl.message(
      'You don\'t have acccess',
      name: 'you_have_no_access',
      desc: '',
      args: [],
    );
  }

  /// `your membership is expired please contact to your trainer`
  String get your_membership_is_expired_please_contect_your_trainer {
    return Intl.message(
      'your membership is expired please contact to your trainer',
      name: 'your_membership_is_expired_please_contect_your_trainer',
      desc: '',
      args: [],
    );
  }

  /// `your package is expired please contact to your admin`
  String get your_package_is_expired_please_contect_your_admin {
    return Intl.message(
      'your package is expired please contact to your admin',
      name: 'your_package_is_expired_please_contect_your_admin',
      desc: '',
      args: [],
    );
  }

  /// `Earning`
  String get earning {
    return Intl.message(
      'Earning',
      name: 'earning',
      desc: '',
      args: [],
    );
  }

  /// `Please add class`
  String get please_add_class {
    return Intl.message(
      'Please add class',
      name: 'please_add_class',
      desc: '',
      args: [],
    );
  }

  /// `Please add specialization`
  String get please_add_specialization {
    return Intl.message(
      'Please add specialization',
      name: 'please_add_specialization',
      desc: '',
      args: [],
    );
  }

  /// `Please add membership`
  String get please_add_membership {
    return Intl.message(
      'Please add membership',
      name: 'please_add_membership',
      desc: '',
      args: [],
    );
  }

  /// `Please add workout category`
  String get please_add_workout_category {
    return Intl.message(
      'Please add workout category',
      name: 'please_add_workout_category',
      desc: '',
      args: [],
    );
  }

  /// `Please add workout`
  String get please_add_workout {
    return Intl.message(
      'Please add workout',
      name: 'please_add_workout',
      desc: '',
      args: [],
    );
  }

  /// `Recurring Membership`
  String get recurring_membership {
    return Intl.message(
      'Recurring Membership',
      name: 'recurring_membership',
      desc: '',
      args: [],
    );
  }

  /// `Exercise data added Successfully`
  String get exercise_data_added_successfully {
    return Intl.message(
      'Exercise data added Successfully',
      name: 'exercise_data_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Started Successfully`
  String get exercise_started_successfully {
    return Intl.message(
      'Exercise Started Successfully',
      name: 'exercise_started_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Paused Successfully`
  String get exercise_paused_successfully {
    return Intl.message(
      'Exercise Paused Successfully',
      name: 'exercise_paused_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Resumed Successfully`
  String get exercise_resume_successfully {
    return Intl.message(
      'Exercise Resumed Successfully',
      name: 'exercise_resume_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Finished Successfully`
  String get exercise_finished_successfully {
    return Intl.message(
      'Exercise Finished Successfully',
      name: 'exercise_finished_successfully',
      desc: '',
      args: [],
    );
  }

  /// `View Recept`
  String get view_recept {
    return Intl.message(
      'View Recept',
      name: 'view_recept',
      desc: '',
      args: [],
    );
  }

  /// `Payment Id`
  String get payment_id {
    return Intl.message(
      'Payment Id',
      name: 'payment_id',
      desc: '',
      args: [],
    );
  }

  /// `Payment Status`
  String get payment_status {
    return Intl.message(
      'Payment Status',
      name: 'payment_status',
      desc: '',
      args: [],
    );
  }

  /// `Payment By`
  String get payment_by {
    return Intl.message(
      'Payment By',
      name: 'payment_by',
      desc: '',
      args: [],
    );
  }

  /// `Please update currency (INR) not supported in paypal`
  String get please_update_currency_inr_not_supported_in_paypal {
    return Intl.message(
      'Please update currency (INR) not supported in paypal',
      name: 'please_update_currency_inr_not_supported_in_paypal',
      desc: '',
      args: [],
    );
  }

  /// `CrossFit`
  String get app_name {
    return Intl.message(
      'CrossFit',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Envato Purchase Key`
  String get envanto_key {
    return Intl.message(
      'Envato Purchase Key',
      name: 'envanto_key',
      desc: '',
      args: [],
    );
  }

  /// `Please enter envato purchase key`
  String get please_enter_envato_purchase_key {
    return Intl.message(
      'Please enter envato purchase key',
      name: 'please_enter_envato_purchase_key',
      desc: '',
      args: [],
    );
  }

  /// `pay`
  String get pay {
    return Intl.message(
      'pay',
      name: 'pay',
      desc: '',
      args: [],
    );
  }

  /// `Good Morning,`
  String get good_morning {
    return Intl.message(
      'Good Morning,',
      name: 'good_morning',
      desc: '',
      args: [],
    );
  }

  /// `Good Afternoon,`
  String get good_afternoon {
    return Intl.message(
      'Good Afternoon,',
      name: 'good_afternoon',
      desc: '',
      args: [],
    );
  }

  /// `Good Evening,`
  String get good_evening {
    return Intl.message(
      'Good Evening,',
      name: 'good_evening',
      desc: '',
      args: [],
    );
  }

  /// `member out of`
  String get member_out_of {
    return Intl.message(
      'member out of',
      name: 'member_out_of',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get month {
    return Intl.message(
      'Month',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get year {
    return Intl.message(
      'Year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `Beginner`
  String get beginner {
    return Intl.message(
      'Beginner',
      name: 'beginner',
      desc: '',
      args: [],
    );
  }

  /// `Intermediate`
  String get intermediate {
    return Intl.message(
      'Intermediate',
      name: 'intermediate',
      desc: '',
      args: [],
    );
  }

  /// `Advance`
  String get advance {
    return Intl.message(
      'Advance',
      name: 'advance',
      desc: '',
      args: [],
    );
  }

  /// `Class Already Exist`
  String get class_already_exist {
    return Intl.message(
      'Class Already Exist',
      name: 'class_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Class added Successfully`
  String get class_add_successfully {
    return Intl.message(
      'Class added Successfully',
      name: 'class_add_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Class Updated Successfully`
  String get class_update_successfully {
    return Intl.message(
      'Class Updated Successfully',
      name: 'class_update_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Class deleted Successfully`
  String get class_deleted_successfully {
    return Intl.message(
      'Class deleted Successfully',
      name: 'class_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `ClassScheduleId is empty`
  String get class_schedule_id_is_empty {
    return Intl.message(
      'ClassScheduleId is empty',
      name: 'class_schedule_id_is_empty',
      desc: '',
      args: [],
    );
  }

  /// `Class Assigned Successfully`
  String get class_Assigned_successfully {
    return Intl.message(
      'Class Assigned Successfully',
      name: 'class_Assigned_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Exercise deleted Successfully`
  String get exercise_deleted_sucessfully {
    return Intl.message(
      'Exercise deleted Successfully',
      name: 'exercise_deleted_sucessfully',
      desc: '',
      args: [],
    );
  }

  /// `Exercise Updated Successfully`
  String get exercise_updated_successfully {
    return Intl.message(
      'Exercise Updated Successfully',
      name: 'exercise_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Gym Already Exist`
  String get gym_already_exist {
    return Intl.message(
      'Gym Already Exist',
      name: 'gym_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Gym Added Successfully`
  String get gym_added_successfully {
    return Intl.message(
      'Gym Added Successfully',
      name: 'gym_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Measurement Already Exist`
  String get measurement_already_exist {
    return Intl.message(
      'Measurement Already Exist',
      name: 'measurement_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Measurement Added Successfully`
  String get measurement_added_successfully {
    return Intl.message(
      'Measurement Added Successfully',
      name: 'measurement_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Setting Update Successfully`
  String get setting_update_successfully {
    return Intl.message(
      'Setting Update Successfully',
      name: 'setting_update_successfully',
      desc: '',
      args: [],
    );
  }

  /// `General Setting Table Not Found`
  String get general_setting_table_not_found {
    return Intl.message(
      'General Setting Table Not Found',
      name: 'general_setting_table_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Measurement Update Successfully`
  String get measurement_update_successfully {
    return Intl.message(
      'Measurement Update Successfully',
      name: 'measurement_update_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Setting Added Successfully`
  String get setting_added_successfully {
    return Intl.message(
      'Setting Added Successfully',
      name: 'setting_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Payment type Already Selected`
  String get payment_type_already_selected {
    return Intl.message(
      'Payment type Already Selected',
      name: 'payment_type_already_selected',
      desc: '',
      args: [],
    );
  }

  /// `Payment Type Added Successfully`
  String get payment_type_added_successfully {
    return Intl.message(
      'Payment Type Added Successfully',
      name: 'payment_type_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Payment Type Already exist`
  String get payment_type_already_exist {
    return Intl.message(
      'Payment Type Already exist',
      name: 'payment_type_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Email/Mobile number Already Exist`
  String get email_or_mobile_number_already_exist {
    return Intl.message(
      'Email/Mobile number Already Exist',
      name: 'email_or_mobile_number_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Member Added Successfully`
  String get member_added_successfully {
    return Intl.message(
      'Member Added Successfully',
      name: 'member_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Member Already exist`
  String get member_already_exist {
    return Intl.message(
      'Member Already exist',
      name: 'member_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Member Updated Successfully`
  String get member_update_successfully {
    return Intl.message(
      'Member Updated Successfully',
      name: 'member_update_successfully',
      desc: '',
      args: [],
    );
  }

  /// `User Updated Successfully`
  String get user_updated_successfully {
    return Intl.message(
      'User Updated Successfully',
      name: 'user_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Member Assigned Successfully`
  String get member_assign_successfully {
    return Intl.message(
      'Member Assigned Successfully',
      name: 'member_assign_successfully',
      desc: '',
      args: [],
    );
  }

  /// `User Password Matched`
  String get user_password_matched {
    return Intl.message(
      'User Password Matched',
      name: 'user_password_matched',
      desc: '',
      args: [],
    );
  }

  /// `User Password Not Matched`
  String get user_password_not_matched {
    return Intl.message(
      'User Password Not Matched',
      name: 'user_password_not_matched',
      desc: '',
      args: [],
    );
  }

  /// `Profile Updated Successfully`
  String get profile_update_successfully {
    return Intl.message(
      'Profile Updated Successfully',
      name: 'profile_update_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Membership Already Exist`
  String get membership_already_exist {
    return Intl.message(
      'Membership Already Exist',
      name: 'membership_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Membership Added Successfully`
  String get membership_added_successfully {
    return Intl.message(
      'Membership Added Successfully',
      name: 'membership_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Membership Updated Successfully`
  String get membership_updated_successfully {
    return Intl.message(
      'Membership Updated Successfully',
      name: 'membership_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Membership deleted Successfully`
  String get membership_deleted_successfully {
    return Intl.message(
      'Membership deleted Successfully',
      name: 'membership_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Invoice deleted successfully`
  String get invoice_deleted_successfully {
    return Intl.message(
      'Invoice deleted successfully',
      name: 'invoice_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Status Updated Successfully`
  String get status_updated_successfully {
    return Intl.message(
      'Status Updated Successfully',
      name: 'status_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Payment Success`
  String get payment_success {
    return Intl.message(
      'Payment Success',
      name: 'payment_success',
      desc: '',
      args: [],
    );
  }

  /// `Envento purchase successfully`
  String get envento_purchase_successfully {
    return Intl.message(
      'Envento purchase successfully',
      name: 'envento_purchase_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Admin not found`
  String get admin_not_found {
    return Intl.message(
      'Admin not found',
      name: 'admin_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Specialization Already Exist`
  String get specialization_already_exist {
    return Intl.message(
      'Specialization Already Exist',
      name: 'specialization_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Trainer added Successfully`
  String get trainer_added_successfully {
    return Intl.message(
      'Trainer added Successfully',
      name: 'trainer_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Trainer deleted Successfully`
  String get trainer_deleted_successfully {
    return Intl.message(
      'Trainer deleted Successfully',
      name: 'trainer_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Trainer Assigned Successfully`
  String get trainer_assigned_successfully {
    return Intl.message(
      'Trainer Assigned Successfully',
      name: 'trainer_assigned_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Trainer Already exist`
  String get trainer_already_exist {
    return Intl.message(
      'Trainer Already exist',
      name: 'trainer_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Trainer Updated Successfully`
  String get trainer_updated_successfully {
    return Intl.message(
      'Trainer Updated Successfully',
      name: 'trainer_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Profile Updated Successfully`
  String get profile_updated_successfully {
    return Intl.message(
      'Profile Updated Successfully',
      name: 'profile_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `User Already exist`
  String get user_already_exist {
    return Intl.message(
      'User Already exist',
      name: 'user_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Workout Category Already Exist`
  String get workout_category_already_exist {
    return Intl.message(
      'Workout Category Already Exist',
      name: 'workout_category_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Workout Category Added Successfully`
  String get workout_category_added_successfully {
    return Intl.message(
      'Workout Category Added Successfully',
      name: 'workout_category_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Workout Category deleted Successfully`
  String get workout_category_deleted_successfully {
    return Intl.message(
      'Workout Category deleted Successfully',
      name: 'workout_category_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Workout Category Updated Successfully`
  String get workout_category_updated_successfully {
    return Intl.message(
      'Workout Category Updated Successfully',
      name: 'workout_category_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Workout Data Added Successfully`
  String get workout_data_added_successfully {
    return Intl.message(
      'Workout Data Added Successfully',
      name: 'workout_data_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Workout Already Exist`
  String get workout_already_exist {
    return Intl.message(
      'Workout Already Exist',
      name: 'workout_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Workout Added Successfully`
  String get workout_added_successfully {
    return Intl.message(
      'Workout Added Successfully',
      name: 'workout_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Assigned workout Successfully`
  String get assigned_workout_successfully {
    return Intl.message(
      'Assigned workout Successfully',
      name: 'assigned_workout_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Workout Updated Successfully`
  String get workout_updated_successfully {
    return Intl.message(
      'Workout Updated Successfully',
      name: 'workout_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Workout deleted Successfully`
  String get workout_deleted_successfully {
    return Intl.message(
      'Workout deleted Successfully',
      name: 'workout_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Workout is empty`
  String get workout_is_empty {
    return Intl.message(
      'Workout is empty',
      name: 'workout_is_empty',
      desc: '',
      args: [],
    );
  }

  /// `Workout Complete`
  String get workout_complete {
    return Intl.message(
      'Workout Complete',
      name: 'workout_complete',
      desc: '',
      args: [],
    );
  }

  /// `Selected Member`
  String get selected_member {
    return Intl.message(
      'Selected Member',
      name: 'selected_member',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message(
      'View',
      name: 'view',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `With in 30 Days`
  String get with_in_thirty_days {
    return Intl.message(
      'With in 30 Days',
      name: 'with_in_thirty_days',
      desc: '',
      args: [],
    );
  }

  /// `With in 60 Days`
  String get with_in_sixty_days {
    return Intl.message(
      'With in 60 Days',
      name: 'with_in_sixty_days',
      desc: '',
      args: [],
    );
  }

  /// `By End of Plan`
  String get by_end_0f_plan {
    return Intl.message(
      'By End of Plan',
      name: 'by_end_0f_plan',
      desc: '',
      args: [],
    );
  }

  /// `Z to A`
  String get z_to_a {
    return Intl.message(
      'Z to A',
      name: 'z_to_a',
      desc: '',
      args: [],
    );
  }

  /// `A to Z`
  String get a_to_z {
    return Intl.message(
      'A to Z',
      name: 'a_to_z',
      desc: '',
      args: [],
    );
  }

  /// `Order By`
  String get order_by {
    return Intl.message(
      'Order By',
      name: 'order_by',
      desc: '',
      args: [],
    );
  }

  /// `Sendinblue Details`
  String get sendinblue_details {
    return Intl.message(
      'Sendinblue Details',
      name: 'sendinblue_details',
      desc: '',
      args: [],
    );
  }

  /// `Email From`
  String get email_from {
    return Intl.message(
      'Email From',
      name: 'email_from',
      desc: '',
      args: [],
    );
  }

  /// `Domain`
  String get domain {
    return Intl.message(
      'Domain',
      name: 'domain',
      desc: '',
      args: [],
    );
  }

  /// `Email Name`
  String get email_name {
    return Intl.message(
      'Email Name',
      name: 'email_name',
      desc: '',
      args: [],
    );
  }

  /// `SMTP Server`
  String get smtp_server {
    return Intl.message(
      'SMTP Server',
      name: 'smtp_server',
      desc: '',
      args: [],
    );
  }

  /// `SMTP Server Port`
  String get smtp_server_port {
    return Intl.message(
      'SMTP Server Port',
      name: 'smtp_server_port',
      desc: '',
      args: [],
    );
  }

  /// `Login Email`
  String get login_email {
    return Intl.message(
      'Login Email',
      name: 'login_email',
      desc: '',
      args: [],
    );
  }

  /// `SMTP Password`
  String get smtp_password {
    return Intl.message(
      'SMTP Password',
      name: 'smtp_password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter SMTP server`
  String get please_enter_smtp_server {
    return Intl.message(
      'Please enter SMTP server',
      name: 'please_enter_smtp_server',
      desc: '',
      args: [],
    );
  }

  /// `Please enter SMTP server port`
  String get please_enter_smtp_server_port {
    return Intl.message(
      'Please enter SMTP server port',
      name: 'please_enter_smtp_server_port',
      desc: '',
      args: [],
    );
  }

  /// `Please enter login email`
  String get please_enter_login_email {
    return Intl.message(
      'Please enter login email',
      name: 'please_enter_login_email',
      desc: '',
      args: [],
    );
  }

  /// `Please enter SMTP password`
  String get please_enter_smtp_password {
    return Intl.message(
      'Please enter SMTP password',
      name: 'please_enter_smtp_password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter email name`
  String get please_enter_email_name {
    return Intl.message(
      'Please enter email name',
      name: 'please_enter_email_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter domain`
  String get please_enter_domain {
    return Intl.message(
      'Please enter domain',
      name: 'please_enter_domain',
      desc: '',
      args: [],
    );
  }

  /// `Please added general setting details`
  String get please_added_general_setting_details {
    return Intl.message(
      'Please added general setting details',
      name: 'please_added_general_setting_details',
      desc: '',
      args: [],
    );
  }

  /// `Sendblue details updated successfully`
  String get sendblue_details_updated_successfully {
    return Intl.message(
      'Sendblue details updated successfully',
      name: 'sendblue_details_updated_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid pincode`
  String get please_enter_valid_pincode {
    return Intl.message(
      'Please enter valid pincode',
      name: 'please_enter_valid_pincode',
      desc: '',
      args: [],
    );
  }

  /// `Select country`
  String get select_country {
    return Intl.message(
      'Select country',
      name: 'select_country',
      desc: '',
      args: [],
    );
  }

  /// `Payment Cancelled`
  String get payment_cancelled {
    return Intl.message(
      'Payment Cancelled',
      name: 'payment_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Payment Failed`
  String get payment_failed {
    return Intl.message(
      'Payment Failed',
      name: 'payment_failed',
      desc: '',
      args: [],
    );
  }

  /// `Please add Your Address, City, Postel Code,State and Country For Payment`
  String
      get please_add_your_address_city_postelCode_state_and_country_for_payment {
    return Intl.message(
      'Please add Your Address, City, Postel Code,State and Country For Payment',
      name:
          'please_add_your_address_city_postelCode_state_and_country_for_payment',
      desc: '',
      args: [],
    );
  }

  /// `Api Key`
  String get api_key {
    return Intl.message(
      'Api Key',
      name: 'api_key',
      desc: '',
      args: [],
    );
  }

  /// `Please enter sendinblue api`
  String get please_enter_sendinblue_api {
    return Intl.message(
      'Please enter sendinblue api',
      name: 'please_enter_sendinblue_api',
      desc: '',
      args: [],
    );
  }

  /// `Add Nutrition`
  String get add_nutrition {
    return Intl.message(
      'Add Nutrition',
      name: 'add_nutrition',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition Name`
  String get nutrition_name {
    return Intl.message(
      'Nutrition Name',
      name: 'nutrition_name',
      desc: '',
      args: [],
    );
  }

  /// `Please enter nutrition`
  String get please_enter_nutrition {
    return Intl.message(
      'Please enter nutrition',
      name: 'please_enter_nutrition',
      desc: '',
      args: [],
    );
  }

  /// `Please enter nutrition detail`
  String get please_enter_nutrition_detail {
    return Intl.message(
      'Please enter nutrition detail',
      name: 'please_enter_nutrition_detail',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition Detail`
  String get nutrition_detail {
    return Intl.message(
      'Nutrition Detail',
      name: 'nutrition_detail',
      desc: '',
      args: [],
    );
  }

  /// `BreakFast Nutrition`
  String get break_fast_nutrition {
    return Intl.message(
      'BreakFast Nutrition',
      name: 'break_fast_nutrition',
      desc: '',
      args: [],
    );
  }

  /// `Please enter break fast detail`
  String get please_enter_break_fast_detail {
    return Intl.message(
      'Please enter break fast detail',
      name: 'please_enter_break_fast_detail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter mid morning snacks detail`
  String get please_enter_mid_morning_snacks_detail {
    return Intl.message(
      'Please enter mid morning snacks detail',
      name: 'please_enter_mid_morning_snacks_detail',
      desc: '',
      args: [],
    );
  }

  /// `BreakFast`
  String get break_fast {
    return Intl.message(
      'BreakFast',
      name: 'break_fast',
      desc: '',
      args: [],
    );
  }

  /// `Mid Morning Snacks`
  String get mid_morning_snacks {
    return Intl.message(
      'Mid Morning Snacks',
      name: 'mid_morning_snacks',
      desc: '',
      args: [],
    );
  }

  /// `Lunch`
  String get lunch {
    return Intl.message(
      'Lunch',
      name: 'lunch',
      desc: '',
      args: [],
    );
  }

  /// `Afternoon Snacks`
  String get afternoon_snacks {
    return Intl.message(
      'Afternoon Snacks',
      name: 'afternoon_snacks',
      desc: '',
      args: [],
    );
  }

  /// `Dinner`
  String get dinner {
    return Intl.message(
      'Dinner',
      name: 'dinner',
      desc: '',
      args: [],
    );
  }

  /// `Please enter dinner detail`
  String get please_enter_dinner_detail {
    return Intl.message(
      'Please enter dinner detail',
      name: 'please_enter_dinner_detail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter dinner detail`
  String get please_enter_afternoon_snacks_detail {
    return Intl.message(
      'Please enter dinner detail',
      name: 'please_enter_afternoon_snacks_detail',
      desc: '',
      args: [],
    );
  }

  /// `Please enter lunch detail`
  String get please_enter_lunch_detail {
    return Intl.message(
      'Please enter lunch detail',
      name: 'please_enter_lunch_detail',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition added successfully`
  String get nutrition_added_successfully {
    return Intl.message(
      'Nutrition added successfully',
      name: 'nutrition_added_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition already exist`
  String get nutrition_already_exist {
    return Intl.message(
      'Nutrition already exist',
      name: 'nutrition_already_exist',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition Plan`
  String get nutrition_plan {
    return Intl.message(
      'Nutrition Plan',
      name: 'nutrition_plan',
      desc: '',
      args: [],
    );
  }

  /// `You don't have any nutrition`
  String get you_do_not_have_any_nutrition {
    return Intl.message(
      'You don\'t have any nutrition',
      name: 'you_do_not_have_any_nutrition',
      desc: '',
      args: [],
    );
  }

  /// `Search nutrition`
  String get search_nutrition {
    return Intl.message(
      'Search nutrition',
      name: 'search_nutrition',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition update successfully`
  String get nutrition_update_successfully {
    return Intl.message(
      'Nutrition update successfully',
      name: 'nutrition_update_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Edit Nutrition`
  String get edit_nutrition {
    return Intl.message(
      'Edit Nutrition',
      name: 'edit_nutrition',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition delete successfully`
  String get nutrition_deleted_successfully {
    return Intl.message(
      'Nutrition delete successfully',
      name: 'nutrition_deleted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `View Nutrition`
  String get view_nutrition {
    return Intl.message(
      'View Nutrition',
      name: 'view_nutrition',
      desc: '',
      args: [],
    );
  }

  /// ` to `
  String get to {
    return Intl.message(
      ' to ',
      name: 'to',
      desc: '',
      args: [],
    );
  }

  /// `Package assigned successfully`
  String get package_assigned_successfully {
    return Intl.message(
      'Package assigned successfully',
      name: 'package_assigned_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Membership assigned successfully`
  String get membership_assigned_successfully {
    return Intl.message(
      'Membership assigned successfully',
      name: 'membership_assigned_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Please update email setting from admin side`
  String get please_update_email_setting_from_admin_side {
    return Intl.message(
      'Please update email setting from admin side',
      name: 'please_update_email_setting_from_admin_side',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
      Locale.fromSubtags(languageCode: 'bn'),
      Locale.fromSubtags(languageCode: 'ca'),
      Locale.fromSubtags(languageCode: 'cs'),
      Locale.fromSubtags(languageCode: 'da'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'el'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'et'),
      Locale.fromSubtags(languageCode: 'fa'),
      Locale.fromSubtags(languageCode: 'fi'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'gu'),
      Locale.fromSubtags(languageCode: 'hi'),
      Locale.fromSubtags(languageCode: 'hr'),
      Locale.fromSubtags(languageCode: 'hu'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'kn'),
      Locale.fromSubtags(languageCode: 'lt'),
      Locale.fromSubtags(languageCode: 'mi'),
      Locale.fromSubtags(languageCode: 'mr'),
      Locale.fromSubtags(languageCode: 'nl'),
      Locale.fromSubtags(languageCode: 'no'),
      Locale.fromSubtags(languageCode: 'pa'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ro'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'sv'),
      Locale.fromSubtags(languageCode: 'ta'),
      Locale.fromSubtags(languageCode: 'te'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'ur'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
