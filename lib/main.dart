// ignore_for_file: depend_on_referenced_packages
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crossfit_gym_trainer/Utils/shared_preferences_manager.dart';
import 'package:crossfit_gym_trainer/mobile_pages/membership_package_screen.dart';
import 'package:crossfit_gym_trainer/providers/nutrition_provider.dart';
import 'package:crossfit_gym_trainer/utils/tables_keys_values.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:crossfit_gym_trainer/providers/class_provider.dart';
import 'package:crossfit_gym_trainer/providers/exercise_provider.dart';
import 'package:crossfit_gym_trainer/providers/general_setting_provider.dart';
import 'package:crossfit_gym_trainer/providers/global_search_provider.dart';
import 'package:crossfit_gym_trainer/providers/measurement_provider.dart';
import 'package:crossfit_gym_trainer/providers/member_provider.dart';
import 'package:crossfit_gym_trainer/providers/payment_history_provider.dart';
import 'package:crossfit_gym_trainer/providers/specialization_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_category_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_history_provider.dart';
import 'package:crossfit_gym_trainer/providers/workout_provider.dart';
import 'package:crossfit_gym_trainer/utils/static_data.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'Utils/color_code.dart';
import 'Utils/theme_data.dart';
import 'l10n/app_locale.dart';
import 'member_screen/member_workout_screen.dart';
import 'mobile_pages/splash_screen.dart';
import 'mobile_pages/trainer_class_list_screen.dart';
import 'providers/dark_theme_provider.dart';
import 'providers/membership_provider.dart';
import 'providers/trainer_provider.dart';
// import 'package:sizer/sizer.dart';

bool isDarkTheme = true;
bool isExpired = false;
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool notificationInitialized = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && Platform.isAndroid) {
    ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
    SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
  }
  try {
    await Firebase.initializeApp(options: StaticData.platformOptions, name: StaticData.appName);
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeProvider = DarkThemeProvider();
  void getCurrentAppTheme() async {
    themeProvider.setDarkTheme = await themeProvider.darkThemePrefs.getTheme();
  }

  @override
  void initState() {
    getCurrentAppTheme();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            return themeProvider;
          },
        ),
        ChangeNotifierProvider(
          create: (_) => AppLocale(),
        ),
        ChangeNotifierProvider(
          create: (_) => SpecializationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MembershipProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TrainerProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClassProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MemberProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutCategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExerciseProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentHistoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => GlobalSearchProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => MeasurementProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutHistoryProvider(),
        ),ChangeNotifierProvider(
          create: (_) => NutritionProvider(),
        ),
      ],
      child: Consumer<DarkThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<AppLocale>(
            builder: (context, locale, child) {
              return LayoutBuilder(//return LayoutBuilder
                  builder: (context, constraints) {
                return OrientationBuilder(//return OrientationBuilder
                    builder: (context, orientation) {
                  //initialize SizerUtil()
                  SizerUtil.setScreenSize(constraints, orientation); //initialize SizerUtil
                  return MaterialApp(
                    navigatorKey: navigatorKey,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: locale.locale,
                    debugShowCheckedModeBanner: false,
                    theme: Styles.themeData(themeProvider.getDarkTheme, context),
                    home: const SplashScreen(),
                  );
                });
              });
            },
          );
        },
      ),
    );
  }
}

Future<void> notificationInit() async {
  if (notificationInitialized) {
    debugPrint("notificationInitialized already.");
    return;
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  var initializationSettingsAndroid = const AndroidInitializationSettings('ic_notification_logo');
  var initializationSettingsIOs = const IOSInitializationSettings();
  var initSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
  await flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: selectNotification);
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (kDebugMode) {
    print('notificationInit payload=');
  }
  String? payload = notificationAppLaunchDetails!.payload;
  if (kDebugMode) {
    print(payload);
  }
  if (payload != null && payload.isNotEmpty) {
    if (kDebugMode) {
      print("selectNotification : $payload");
    }
    selectNotification(payload);
  }

  /// Create an Android Notification Channel.
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    debugPrint('User granted permission');
    RemoteNotification? notification;
    Map<String, dynamic> notificationData;
    messaging.getInitialMessage().then((message) => {
          debugPrint("getInitialMessage received : "),
          if (message != null)
            {
              notification = message.notification,
              notificationData = message.data,
              debugPrint("New Notification received : "),
              debugPrint(notification.toString()),
              debugPrint(notificationData.toString()),
              debugPrint("New Notification received data : $notificationData")
            }
        });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      Map<String, dynamic> notificationData = message.data;
      debugPrint("New Notification received : ");
      debugPrint(notification.toString());
      debugPrint(notificationData.toString());
      debugPrint("New Notification received data : $notificationData");
      if (notificationData.isNotEmpty) {
        flutterLocalNotificationsPlugin.show(
            Random().nextInt(10000),
            notificationData['title'] ?? "",
            notificationData['body'] ?? "",
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                color: ColorCode.lightScreenBackground,
                icon: 'ic_notification_logo',
              ),
            ),
            payload: jsonEncode(notificationData));
      } else if (notification != null && notification.title != null) {
        flutterLocalNotificationsPlugin.show(
            Random().nextInt(10000),
            notification.title ?? "",
            notification.body ?? "",
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: ColorCode.lightScreenBackground,
                icon: 'ic_notification_logo',
              ),
            ),
            payload: jsonEncode(notificationData));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage pushMessage) async {
      debugPrint('Message opened by user');

      RemoteNotification? notification = pushMessage.notification;
      Map<String, dynamic> notificationData = pushMessage.data;
      debugPrint(notification.toString());
      debugPrint(notificationData.toString());
    });
    notificationInitialized = true;
  } else {
    debugPrint('User declined or has not accepted permission');
  }
}

void selectNotification(String? payload) async {
  final SharedPreferencesManager preference = SharedPreferencesManager();
  String userRole = "";
  String userId = "";
  userRole = await preference.getValue(prefUserRole, "");
  userId = await preference.getValue(prefUserId, "");
  if (payload != null && payload.isNotEmpty) {
    Map<String, dynamic> jsonMap = jsonDecode(payload);
    if (kDebugMode) {
      print(jsonMap);
    }
    String notificationType = jsonMap['type'];
    if (notificationType == notificationTrainerPackageAssign) {
      navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => MembershipPackageScreen(userRole: userRole,)));
    } else if(notificationType == notificationMemberMembershipAssign){
      navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => MembershipPackageScreen(userRole: userRole,)));
    }else if(notificationType == notificationWorkoutAssign){
      navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => MemberWorkoutScreen(userRole: userRole,userId: userId,)));
    }else if(notificationType == notificationWorkoutUnAssign){
      navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => MemberWorkoutScreen(userRole: userRole,userId: userId,)));
    }else if(notificationType == notificationClassAssign){
      navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => const TrainerClassListScreen()));
    }
  } else {
    // debugPrint('notification payload: null');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  debugPrint("Handling a background message: ${message.messageId}");

  RemoteNotification? notification = message.notification;
  Map<String, dynamic> notificationData = message.data;
  debugPrint("New Notification received : ");
  debugPrint(notification.toString());
  debugPrint(notificationData.toString());
  debugPrint("New Notification received data : $notificationData");

  late AndroidNotificationChannel channelNew;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  var initializationSettingsAndroid = const AndroidInitializationSettings('ic_notification_logo');
  var initializationSettingsIOs = const IOSInitializationSettings();
  var initSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOs);
  await flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: selectNotification);
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  channelNew = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );
  if (kDebugMode) {
    print('payload=');
  }
  String? payload = notificationAppLaunchDetails!.payload;
  if (kDebugMode) {
    print(payload);
  }

  if (notificationData.isNotEmpty) {
    flutterLocalNotificationsPlugin.show(
        Random().nextInt(10000),
        notificationData['title'] ?? "",
        notificationData['body'] ?? "",
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelNew.id,
            channelNew.name,
            channelDescription: channelNew.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            color: ColorCode.lightScreenBackground,
            icon: 'ic_notification_logo',
          ),
        ),
        payload: jsonEncode(notificationData));
  }
}
