import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';

import './src/injection_container.dart' as di;
import 'src/bloc_delegate.dart';
import 'src/features/todo_manager_features/presentation/bloc/add_list_bloc/add_list_bloc.dart'
    as addListBloc;
import 'src/features/todo_manager_features/presentation/bloc/add_quick_note_bloc/add_quick_note_bloc.dart'
    as addNoteBloc;
import 'src/features/todo_manager_features/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'src/features/todo_manager_features/presentation/bloc/dashboard_bloc/dashboard_bloc.dart';
import 'src/features/todo_manager_features/presentation/bloc/login_bloc/login_bloc.dart';
import 'src/features/todo_manager_features/presentation/pages/Dashboard.dart';
import 'src/features/todo_manager_features/presentation/pages/Login.dart';
import 'src/features/todo_manager_features/presentation/pages/add_new_list.dart';
import 'src/features/todo_manager_features/presentation/pages/add_quick_note.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  BlocSupervisor.delegate = MyBlocDelegate();
  await di.sl.allReady();
  // await FlutterStatusbarcolor.setStatusBarColor(Colors.white.withOpacity(0.90));
  // FlutterStatusbarcolor.setStatusBarWhiteForeground(false);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthBloc _authBloc;

  // CHANGE THIS parameter to true if you want to test GDPR privacy consent
  bool _requireConsent = true;

  @override
  void initState() {
    super.initState();
    _authBloc = di.sl<AuthBloc>();
    _authBloc.add(AppStarted());

    initPlatformState();
    OneSignal.shared.consentGranted(true);
  }

  @override
  void dispose() {
    _authBloc.close();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print('NOTIFICATION OPENED HANDLER CALLED WITH: ${result}');
      this.setState(() {
        final _debugLabelString =
            "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
        log('message :: _debugLabelString :: $_debugLabelString');
      });
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      print('FOREGROUND HANDLER CALLED WITH: ${event}');

      /// Display Notification, send null to not display
      event.complete(null);

      this.setState(() {
        final _debugLabelString =
            "Notification received in foreground notification: \n${event.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
        log('message :: _debugLabelString :: $_debugLabelString');
      });
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        final _debugLabelString =
            "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
        log('message :: _debugLabelString :: $_debugLabelString');
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      print("SUBSCRIPTION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
      print("PERMISSION STATE CHANGED: ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges changes) {
      print("EMAIL SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    });

    OneSignal.shared
        .setSMSSubscriptionObserver((OSSMSSubscriptionStateChanges changes) {
      print("SMS SUBSCRIPTION STATE CHANGED ${changes.jsonRepresentation()}");
    });

    OneSignal.shared.setOnWillDisplayInAppMessageHandler((message) {
      print("ON WILL DISPLAY IN APP MESSAGE ${message.messageId}");
    });

    OneSignal.shared.setOnDidDisplayInAppMessageHandler((message) {
      print("ON DID DISPLAY IN APP MESSAGE ${message.messageId}");
    });

    OneSignal.shared.setOnWillDismissInAppMessageHandler((message) {
      print("ON WILL DISMISS IN APP MESSAGE ${message.messageId}");
    });

    OneSignal.shared.setOnDidDismissInAppMessageHandler((message) {
      print("ON DID DISMISS IN APP MESSAGE ${message.messageId}");
    });

    // NOTE: Replace with your own app ID from https://www.onesignal.com
    await OneSignal.shared.setAppId("ad265f47-f06f-4e72-ae35-ec8ffc152780");

    // iOS-only method to open launch URLs in Safari when set to false
    OneSignal.shared.setLaunchURLsInApp(false);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    this.setState(() {
      // _enableConsentButton = requiresConsent;
    });

    // Some examples of how to use In App Messaging public methods with OneSignal SDK
    oneSignalInAppMessagingTriggerExamples();

    OneSignal.shared.disablePush(false);

    // Some examples of how to use Outcome Events public methods with OneSignal SDK
    oneSignalOutcomeEventsExamples();

    bool userProvidedPrivacyConsent =
        await OneSignal.shared.userProvidedPrivacyConsent();
    print("USER PROVIDED PRIVACY CONSENT: $userProvidedPrivacyConsent");
  }

  oneSignalInAppMessagingTriggerExamples() async {
    /// Example addTrigger call for IAM
    /// This will add 1 trigger so if there are any IAM satisfying it, it
    /// will be shown to the user
    OneSignal.shared.addTrigger("trigger_1", "one");

    /// Example addTriggers call for IAM
    /// This will add 2 triggers so if there are any IAM satisfying these, they
    /// will be shown to the user
    Map<String, Object> triggers = new Map<String, Object>();
    triggers["trigger_2"] = "two";
    triggers["trigger_3"] = "three";
    OneSignal.shared.addTriggers(triggers);

    // Removes a trigger by its key so if any future IAM are pulled with
    // these triggers they will not be shown until the trigger is added back
    OneSignal.shared.removeTriggerForKey("trigger_2");

    // Get the value for a trigger by its key
    final triggerValue =
        await OneSignal.shared.getTriggerValueForKey("trigger_3");
    print("'trigger_3' key trigger value: ${triggerValue?.toString()}");

    // Create a list and bulk remove triggers based on keys supplied
    List<String> keys = ["trigger_1", "trigger_3"];
    OneSignal.shared.removeTriggersForKeys(keys);

    // Toggle pausing (displaying or not) of IAMs
    OneSignal.shared.pauseInAppMessages(false);
  }

  oneSignalOutcomeEventsExamples() async {
    // Await example for sending outcomes
    outcomeAwaitExample();

    // Send a normal outcome and get a reply with the name of the outcome
    OneSignal.shared.sendOutcome("normal_1");
    OneSignal.shared.sendOutcome("normal_2").then((outcomeEvent) {
      print(outcomeEvent.jsonRepresentation());
    });

    // Send a unique outcome and get a reply with the name of the outcome
    OneSignal.shared.sendUniqueOutcome("unique_1");
    OneSignal.shared.sendUniqueOutcome("unique_2").then((outcomeEvent) {
      print(outcomeEvent.jsonRepresentation());
    });

    // Send an outcome with a value and get a reply with the name of the outcome
    OneSignal.shared.sendOutcomeWithValue("value_1", 3.2);
    OneSignal.shared.sendOutcomeWithValue("value_2", 3.9).then((outcomeEvent) {
      print(outcomeEvent.jsonRepresentation());
    });
  }

  Future<void> outcomeAwaitExample() async {
    var outcomeEvent = await OneSignal.shared.sendOutcome("await_normal_1");
    print(outcomeEvent.jsonRepresentation());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nxt App',
        theme: ThemeData(
          primaryColor: Color(0xff657AFF),
          accentColor: Color(0xff4F5578),
          primarySwatch: Colors.blue,
        ),
        home: BlocBuilder(
            bloc: _authBloc,
            builder: (BuildContext context, AuthState authState) {
              if (authState is Uninitialised) {
                return BlocProvider<LoginBloc>(
                    create: (context) {
                      return di.sl<LoginBloc>();
                    },
                    child: LoginPage());
              } else if (authState is AuthAuthenticated) {
                return FutureBuilder(
                    future: di.sl.allReady(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return BlocProvider<DashboardBloc>(
                          create: (context) {
                            return di.sl<DashboardBloc>();
                          },
                          child: DashboardScreen(),
                        );
                      } else {
                        return Scaffold(
                          body: Center(
                            child: Container(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }
                    });
              } else {
                return BlocProvider<LoginBloc>(
                    create: (context) {
                      return di.sl<LoginBloc>();
                    },
                    child: LoginPage());
              }
            }),
        routes: {
          "/dashboard": (context) => BlocProvider<DashboardBloc>(
                create: (context) {
                  return di.sl<DashboardBloc>();
                },
                child: DashboardScreen(),
              ),
          "/addQuickNote": (context) =>
              BlocProvider<addNoteBloc.AddQuickNoteBloc>(
                  create: (context) {
                    return di.sl<addNoteBloc.AddQuickNoteBloc>();
                  },
                  child: AddQuickNote()),
          "/addList": (context) => BlocProvider<addListBloc.AddListBloc>(
              create: (context) {
                return di.sl<addListBloc.AddListBloc>();
              },
              child: AddList()),
        },
      ),
    );
  }
}
