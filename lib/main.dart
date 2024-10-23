//import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'event_editing_page.dart';
import 'event.dart';
import 'event_data_source.dart';
import 'tasks_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart';
import 'signinwidgets.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'appointment_card.dart';
import 'config.dart';
import 'event_editing_page.dart';
import 'event.dart';
import 'event_data_source.dart';
import 'tasks_widget.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Medicate App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 34, 211, 255)),
        ),
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = "";
  List medications = ["Albuterol", "Amoxicillin", "Ibuprofen", "Vitamin D", "Atorvastin", "Adderall"];
  var index = 0;
  bool buttonClicked = false;
  List<DateTime> takenMedications = [];

  void addTakenMedication(DateTime date) {
    takenMedications.add(date);
    notifyListeners(); // Notify listeners to update the UI
  }

  final List<Event> _events = [];
  List<Event> get events => _events;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<Event> get eventsOfSelectedDate => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _events.remove(event);
    notifyListeners();
  }

  void updateClick() {
    buttonClicked = true;
    notifyListeners();
  }

  void startingMed() {
    current = medications[index];
  }

  void getNext() {
    index += 1;
    current = medications[index];
    notifyListeners();
  }

  void goBack() {
    index -= 1;
    current = medications[index];
    notifyListeners();
  }

  var medsTaken = <String>[];

  void toggleCheck() {
    if (medsTaken.contains(current)) {
      medsTaken.remove(current);
    } else {
      medsTaken.add(current);
    }
    notifyListeners();
  }

}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  //Login Function
  static Future<User?> loginUsingEmailPassword({required String email, required String password, required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        print("No User was found for that email");
      }
    }

    return user;
  }


  @override
  Widget build(BuildContext context) {
    //create the textfilled controller
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();


    return Material(
      // padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Medicate", style: TextStyle(color: Colors.black, fontSize: 28.0, fontWeight: FontWeight.bold)),
          const Text("Log in", style: TextStyle(color: Colors.black, fontSize: 44.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 44.0),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "User Email",
              prefixIcon: Icon(Icons.mail, color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 26.0,
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: "User Password",
              prefixIcon: Icon(Icons.lock, color: Colors.black),
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          const Text(
              "Forgot your Password?",
              style: TextStyle(color: Colors.blue)
          ),
          const SizedBox(
            height: 5.0,
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> SignIn()));
            },
            child: const Text(
              "Don't have an account? Sign up",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          const SizedBox(
            height: 58.0,
          ),
          Container(
            width: 400,
            child: RawMaterialButton(
              fillColor: const Color(0xFF0069FE),
              elevation: 0.0,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)
              ),
              onPressed: () async {
                User? user = await loginUsingEmailPassword(email: _emailController.text, password: _passwordController.text, context: context);
                print(user);
                if (user != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=> MyHomePage()));
                }
              },
              child: const Text("Log In",
                style: TextStyle (
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MedsPage();
    //VS code told me to remove these: break;
      case 1:
        page = MedsTakenPage();
    //break;
      case 2:
        page = CalendarPage();
      case 3:
        page = SearchPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.check_circle_rounded),
                  label: Text('Medications Taken'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month),
                  label: Text('Calendar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}


class MedsPage extends StatelessWidget {
  final List<Map<String, dynamic>> medCat = [
    {
      'icon': Icons.home,
      'category': 'Home',

    },
    {
      'icon': Icons.search,
      'category': 'Search',
    },
    {
      'icon': Icons.check_circle_rounded,
      'category': 'History',
    },
    {
      'icon': Icons.calendar_month,
      'category': 'Calendar',
    },
  ];

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    var db = FirebaseFirestore.instance;


    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
              FutureBuilder<DocumentSnapshot>(
                future: db.collection('Users').doc(user!.uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text(
                      'Loading...',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    );
                  }

                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  String name = userData['Name'] ?? 'No name found';

                  return Text(
                      'Welcome, $name',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  );
                },
              ),
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/Medicate.png'),
                ),
              ],
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ButtonWidget(
                    title: 'Home Page',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPage()),
                      );
                    },
                  ),
                  ButtonWidget(
                    title: 'History',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MedsTakenPage()),
                      );
                    },
                  ),
                  ButtonWidget(
                    title: 'Calendar',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CalendarPage()),
                      );
                    },
                  ),
                  ButtonWidget(
                    title: 'Search Page',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            AppointmentCard(),
          ],
        ),
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  ButtonWidget({required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120, // Set a fixed width for buttons
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Center( // Center the text within the button
          child: Text(
            title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}


class MedsTakenPage extends StatefulWidget {
  @override
  State<MedsTakenPage> createState() => _MedsTakenPageState();
}

class _MedsTakenPageState extends State<MedsTakenPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    List<DateTime> takenMedications = appState.takenMedications; // Accessing the list

    return Scaffold(
      appBar: AppBar(title: Text("Medication History"), backgroundColor: Colors.blue.shade100,),
      body: takenMedications.isEmpty
          ? Center(child: Text("No medications taken"))
          : ListView.builder(
        itemCount: takenMedications.length,
        itemBuilder: (context, index) {
          // Convert to local time before formatting
          DateTime localTime = takenMedications[index].toLocal();
          String formattedDate = DateFormat('MMMM d, y – h:mm a').format(localTime);
          return ListTile(
            title: Text("Medication taken on: $formattedDate"),
          );
        },
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController _calendarController = CalendarController();
  _AppointmentDataSource _events = _getCalendarDataSource();
  DateTime today = DateTime.now();

  DateTime? _lastTapTime;

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<MyAppState>(context).events;
    User user = FirebaseAuth.instance.currentUser!;
    var db = FirebaseFirestore.instance;

    Future<QuerySnapshot<Map<String, dynamic>>> _Events() async {
      return await db
          .collection('Users')
          .doc(user.uid)
          .collection('Events')
          .get();
    }

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: _Events(),
          builder: (context, snapshot) {

            final events1 = snapshot.data!.docs.map((doc) {

              if (doc.data().containsKey('from') &&
                  doc.data().containsKey('to') &&
                  doc.data().containsKey('name') &&
                  doc.data().containsKey('description') &&
                  doc.data().containsKey('isAllDay') && doc.data != null) {

                return Event(
                  from: (doc['from'] as Timestamp).toDate(),
                  isAllDay: doc['isAllDay'] ?? false,
                  title: doc['name'] ?? 'No Title',
                  to: (doc['to'] as Timestamp).toDate(),
                  description: doc['description'] ?? 'No Description',
                );
              } else {
                print("Document does not have the fields");
              }
            }).whereType<Event>().toList();

            events.addAll(events1);

            return Stack(
              children: [
                SfCalendar(
                  view: CalendarView.schedule,
                  allowedViews: [
                    CalendarView.schedule,
                    CalendarView.day,
                    CalendarView.week,
                    CalendarView.month,
                  ],
                  onTap: (details) {
                    _handleDoubleTap(details, context);
                  },
                  onLongPress: (details) {
                    final provider = Provider.of<MyAppState>(context, listen: false);
                    provider.setDate(details.date!);
                    _showMarkAsTakenDialog(context, details.date!);
                  },
                  monthViewSettings: MonthViewSettings(
                    navigationDirection: MonthNavigationDirection.vertical,
                  ),
                  headerStyle: CalendarHeaderStyle(
                    backgroundColor: Colors.transparent,
                  ),
                  controller: _calendarController,
                  dataSource: EventDataSource(events),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => EventEditingPage()),
        ),
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
  void _handleDoubleTap(CalendarTapDetails details, BuildContext context) {
    final currentTime = DateTime.now();

    if (_lastTapTime == null ||
        currentTime.difference(_lastTapTime!) > Duration(milliseconds: 500)) {
      _lastTapTime = currentTime;
    } else {
      if (details.targetElement == CalendarElement.appointment) {
        final selectedEvent = details.appointments?.first as Event?;
        if (selectedEvent != null) {
          _showDeleteDialog(context, selectedEvent);
        }
      }
      _lastTapTime = null;
    }
  }

  void _deleteEvent(Event event) async {
    User user = FirebaseAuth.instance.currentUser!;
    var db = FirebaseFirestore.instance;

    try {
      QuerySnapshot snapshot = await db
          .collection('Users')
          .doc(user.uid)
          .collection('Events')
          .where('name', isEqualTo: event.title)
          .where('from', isEqualTo: event.from)
          .where('to', isEqualTo: event.to)
          .where('isAllDay', isEqualTo: event.isAllDay)
          .where('description', isEqualTo: event.description)
          .get();


      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      final provider = Provider.of<MyAppState>(context, listen: false);
      provider.events.remove(event);
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  void _showMarkAsTakenDialog(BuildContext context, DateTime date) {
    // Capture the current time
    DateTime now = DateTime.now();
    // Combine the date from the calendar with the current time
    DateTime medicationTakenTime = DateTime(
      date.year,
      date.month,
      date.day,
      now.hour,
      now.minute,
    );


    String formattedDate = DateFormat('MMMM d, y – h:mm a').format(medicationTakenTime);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Mark Medication as Taken"),
          content: Text("Have you taken the medication for $formattedDate?"),
          actions: [
            TextButton(
              onPressed: () {
                markMedicationAsTaken(medicationTakenTime);
                Navigator.of(context).pop();
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }



  void markMedicationAsTaken(DateTime date) {
    Provider.of<MyAppState>(context, listen: false).addTakenMedication(date);
  }

  void _showDeleteDialog(BuildContext context, Event event) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Delete Event'),
            content: Text('Are you sure you want to delete this event?'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  final provider = Provider.of<MyAppState>(context, listen: false);
                  provider.deleteEvent(event);
                  _deleteEvent(event);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
}

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: MySearchDelegate());
              },
            ),
          ],
        ),
        body: const Center(child: Text('This is the Search Page! Search up any Medication to learn more about the Medications you are taking or any medications you may be interested in taking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w400,
            )),
        ));
  }
}


class MySearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> _searchResults = [
    {
      'name': 'Aciclovir (Zovirax)',
      'description': 'It is used to decrease pain and speed the healing of sores or blisters in people who have chickenpox. It is also used to prevent and treat herpes infections on the skin, mouth, and mucous membranes. It does not cure herpes, but it relieves the pain and makes the infection clear faster.',
      'drug class': 'Antiviral medications called synthetic nucleoside analogues',
      'side effects': ['Headaches','Feeling dizzy','Feeling or being sick (nausea or vomiting)','Diarrhea','Skin becomes sensitive to sunlight'],
    },
    {
      'name': 'Acrivastine',
      'description': 'Acrivastine is a H1 receptor blocker of the second generation for antihistamines that is used to treat allergy symptoms related to hay fever, seasonal allergies, urticaria, angioedema and atopic dermatitis.',
      'drug class': 'Triprolidine Analog Antihistamine',
      'side effects': ['Blurred vision', 'Dry mouth and throat', 'Palpitations', 'Tachycardia', 'Abdominal distress','Constipation', 'Headache'],
    },
    {
      'name': 'Adalimumab',
      'description': 'Adalimumab is a biological medicine that is used to treat autoimmune conditions and inflammation. It is a recombinant monoclonal antibody that binds to tumor necrosis factor-alpha (TNF-alpha. By binding to TNF-alpha, adalimumab prevents it from binding to receptors on the surface of TNF cells, which inhibits immune responses mediated by TNF. This reduces inflammation by acting on the immune system.',
      'drug class': 'Tumor necrosis factor (TNF) inhibitors',
      'side effects': ['Blurred vision','Back pain','Blindness','Chest pain','Cold hands and feet','Dark urine','Hoarseness','Irregular breathing','Confusion','Diarrhea','Ear congestion','Eye pain','Pinpoint red spots on the skin'],
    },
    {
      'name': 'Alendronic Acid',
      'description': 'Alendronic acid is a type of medicine called a bisphosphonate. They are used to help bones stay strong. By taking Alendronic acid, it can help if people are developing osteoporosis which is a condition that makes your bones weaker and there is a higher chance of it getting broken.',
      'drug class': 'biophosphonate',
      'side effects': ['Diarrhea’, ‘Heartburn’ , ‘Nausea’, ‘Chest Pain’, ‘Dysphagia’, ‘Dizziness’, ‘Heavy Jaw Feeling’, ‘Hair loss’, ‘Itching’, ‘Skin blisters’, ‘Convulsion’, ‘Difficulty with breathing’, ‘Difficulty with moving'],
    },
    {
      'name': 'Adderall',
      'description': 'Adderall is also known as a mixed amphetamine salts, which is a combination of two forms of amphetamine and two forms of dextroamphetamine. The mixture produces an increase in wakefulness, attention, and resistance to fatigue while also reducing restlessness and impulsiveness which is a perfect medication for those who are struggling with ADHD and narcolepsy (a sleep disorder).',
      'drug class': 'Stimulant',
      'side effects': ['Insomnia', 'Headache', 'Weight loss', 'Loss of appetite', 'Nausea', 'Stomachache', 'Anxiety', 'High blood pressure', 'Fatigue', 'Hallucination', 'Moodiness', 'Restlessness', 'Tremor'],
    },
    {
      'name': 'Allopurinol',
      'description': 'Allopurinol lowers uric acid levels in the bloodstream. Moreover, it also lowers excess uric acid levels which is developed through cancer medications or with patients that have developed kidney stones. As a result, it helps prevent gout attacks/grouty arthritis which are caused by a high uric acid level. This is done stopping the biochemical reactions that create uric acid. ',
      'drug class': 'Xanthine Oxidase Inhibitors',
      'side effects': ['Skin rash', 'Diarrhea', 'Nausea'],
    },
    {
      'name': 'Albuterol',
      'description': 'Albuterol, also known as salbutamol, is a prescription medication that treats and prevents bronchospasm, or wheezing, in patients with reversible obstructive airway diseases, like asthma and chronic obstructive pulmonary disease. It is a bronchodilator which can open the bronchial tubes in the lungs to make breathing easier. Albuterol can help with coughing, shortness of breath, chest tightness, and difficulty breathing.',
      'drug class': 'Bronchodilators',
      'side effects': ['Sore throat','Chest pain','Heart arrhythmia','Swelling of the mouth or throat','Vomiting','Change in taste','Wheezing','Cough','Voice changes','Hoarseness','Noisy breathing'],
    },
    {
      'name': 'Alogliptin',
      'description': 'Alogliptin is an oral and antidiabetic medication for patients with type two diabetes. It helps to lower blood sugar in patients with high blood sugar caused from type 2 diabetes. This is done by increasing substances in the body that aid the body in releasing more insulin.',
      'drug class': 'DPP-4 Inhibitor',
      'side effects': ['Anxiety','Blurred vision','Chills','Cold sweats','Coma','Confusion','Cool', 'pale skin','Depression','Dizziness','Fast heartbeat','Headache','Increased hunger','Nausea','Nightmares','Seizures','Shakiness','Slurred speech','Unusual tiredness or weakness'],
    },
    {
      'name': 'Amlodipine',
      'description': 'Amlodipine is used to treat high blood pressure and chest pain. This is done by impacting the movement of calcium into the heart and blood vessels. As a result, blood vessels are relaxed and blood pressure is lowered. Moreover, this also increases the amount of blood and oxygen to the heart.',
      'drug class': 'Dihydropyridine Calcium Channel Blocker',
      'side effects': ['Headache','Indigestion','Swelling','Unusual tiredness or weakness','Belching','Frequent urination','Constipation','Flushed, dry skin','Cold sweat','Dark urine','Diarrhea','Difficult or labored breathing','Difficulty with moving','Fever','Flushing','Lack or loss of strength','Tingling of the hands or feet','Upset stomach'],
    },
    {
      'name': 'Amoxicillin',
      'description': 'Amoxicillin is created by adding an extra amino group to penicillin which is useful to fight against antibiotic resistance. It is effective to many bacteria as it can kill and slow its growth; however, it is not effective against viruses, colds, flu, etc. It gives additional protection to gram-negative organisms.',
      'drug class': 'Penicillinase-sensitive penicillin',
      'side effects': ['Diarrhea', 'Headache','Nausea','Vomiting'],
    },
    {
      'name': 'Anastrozole',
      'description': 'Anastrozole is used to treat breast cancer in women after menopause, when their period ends. There are some types of these cancers that grow faster because of a hormone named estrogen. The anastrozole is able to decrease the amount of estrogen in the body that eventually allows slowing or reverse for breast cancer.',
      'drug class': 'Aromatase inhibitors',
      'side effects': ['Blurred vision', 'Bone pain', 'Chest pain or discomfort', 'Dizziness', 'Headache','Nervousness','Pounding in the ears', 'Slow or fast heartbeat', 'Swelling of the feet or lower legs'],
    },
    {
      'name': 'Antidepressants',
      'description': 'Antidepressants are used to treat clinical depression. They are also used for other conditions: obsessive compulsive disorder (OCD). It accomplishes this by changing a certain chemical in the brain called neurotransmitters which is important for mood regulation. More specifically they work with serotonin and norepinephrine.',
      'drug class': 'Serotonin and norepinephrine reuptake inhibitors (SNRIs)',
      'side effects': ['Anxious', 'Feeling/actively sick','Stomach aches', 'Loss of appetite', 'Dizziness', 'Insomnia', 'Headaches'],
    },
    {
      'name': 'Apixaban',
      'description': 'Apixaban allows blood to flow through your veins more easily, so there are less blood clots. It is used to treat people who have had a health problem caused by a blood clot: deep vein thrombosis, a blood clot in the leg.',
      'drug class': 'Anticoagulant',
      'side effects': ['Serious bleeding','(medical attention)', 'Tired', 'Dizzy', 'A mild rash', 'Feeling sick (nausea)'],
    },
    {
      'name': 'Aripiprazole',
      'description': 'Aripiprazole is used to treat mental conditions like bipolar I (manic-depressive illness), major depressive disorder, and schizophrenia. It can also help children with irritability that is related to autism or Tourette syndrome. It can be used along with other medications together.',
      'drug class': 'Antipsychotics',
      'side effects': ['Blurred vision', 'Constipation', 'Headache','Restlessness', 'Seizures', 'Tiredness', 'Dizziness', 'Trouble swallowing'],
    },
    {
      'name': 'Aspirin',
      'description': 'Aspirin helps stop the production of certain things that will eventually cause fever, pain, swelling, and blood clots. Aspirin can also be found in other medications: antacids, pain relievers, and cold medications. Aspirin is part of the nonsteroidal anti-inflammatory agents.',
      'drug class': 'Salicylates',
      'side effects': ['Heartburn','Blood in your vomit','Confusion','Upset stomach','Melena','Headache', 'Dark urine', 'Fever', 'Nausea'],
    },
    {
      'name': 'Atenolol',
      'description': 'It is a beta blocker medication which treats high blood pressure, hypertension, and irregular heartbeats (arrhythmia). Moreover, a patient with high blood pressure taking this medication will help reduce risk of heart disease, heart attacks, and strokes. It can also prevent chest pain caused by angina. This works by relaxing blood vessels and slowing heart rate to improve blood flow and decrease blood pressure.',
      'drug class': 'Beta blocker',
      'side effects': ['Cold hands or feet', 'Dizziness', 'Tiredness or depressed mood','New or worsening chest pain','Slow or uneven heartbeats', 'A light-headed feeling', 'like you might pass out','Shortness of breath (even with mild exertion)', 'Swelling', 'Rapid weight gain', 'A cold feeling in your hands and feet'],
    },
    {
      'name': 'Atorvastatin',
      'description': 'This medication is used to treat high cholesterol and triglyceride levels. As a result, it can help reduce the risk of heart attacks, strokes, heart and blood vessel problems, as well as angina. It does this by blocking an enzyme needed to create cholesterol, which reduces the amount of cholesterol in the blood. ',
      'drug class': 'HMG-CoA reductase inhibitors (statins)',
      'side effects': ['Stuffy or runny nose', 'Sore throat','Muscle spasms or pain', 'Joint pain', 'Diarrhea', 'Upset stomach', 'Pain in your arms and legs', 'Urinary tract infection (UTI)'],
    },
    {
      'name': 'Azathioprine',
      'description': 'Known as AZA, this medication is used to prevent the rejection of a transplanted kidney as well as for the treatment of active rheumatoid arthritis (RA). It does this by lowering the body’s natural immunity to previous rejection of the new kidney. More specifically, it suppresses the blood cells that cause inflammation.',
      'drug class': 'Immunosuppressive Agents',
      'side effects': ['Increased stomach irritation', 'Abdominal pain', 'Nausea and vomiting', 'Changes in hair color and texture, along with hair loss', 'Loss of appetite', 'Blood in the urine or stool', 'Unusual bruising', 'Fatigue', 'Development of mouth sores and ulcers'],
    },
    {
      'name': 'Azithromycin',
      'description': 'It is an antibiotic medicine which is used to treat various infections such as pneumonia, ear, nose, throat, and nose infections. It does this by killing bacteria or preventing bacteria growth. However, it can not help cure colds, flus, or other viral infections and is only available with doctor’s prescription. Oral azithromycin works after 2 to 3 hours once it reaches full concentration in the body.',
      'drug class': 'Macrolide Antibiotics',
      'side effects': ['Chills','Dizziness','Difficulty Breathing','Drowsiness','Cough','Throat soreness', 'Diarrhea','Headache', 'Taste change'],
    },
    {
      'name': 'Baclofen',
      'description': 'Baclofen is used to help relax the muscles in the body. It helps stop spasms, cramping, and tightness in the muscles that are related to medical issues. This includes sclerosis or injuries to the spine. ',
      'drug class': 'Skeletal muscle relaxants',
      'side effects': ['Diarrhea','Dizziness','Headache', 'Blurred vision','Confusion','Frequent urination','Nausea', 'Insomnia'],
    },
    {
      'name': 'Bendroflumethiazide',
      'description': 'It is a diuretic medicine which is used to treat high blood pressure and the build-up of fluid in your body. Its goal is to get rid of the water in your body, so it will make you want to go to the bathroom more which allows the process of getting rid of extra liquid in the body.',
      'drug class': 'Thiazide diuretic',
      'side effects': ['Dizziness', 'Abdominal pain', 'Nausea', 'Sleepiness', 'Bloating', 'Blurred vision', 'Diarrhea', 'Muscle spasm', 'Restlessness'],
    },
    {
      'name': 'Benzoyl Peroxide',
      'description': 'This is for acne. It works as an antiseptic which reduces the bacteria on the surface of the skin. It is one of the first treatments that is recommended for mild acne. It is usually found in a gel like substance in face wash which has a small percentage of benzoyl',
      'drug class': 'Topical Antibiotics',
      'side effects': ['Itching', 'Xeroderma', 'Swelling', 'Dizziness', 'Shortness of breath', 'Hives', 'Erythema', 'Severe stinging or redness', 'Throat tightness'],
    },
    {
      'name': 'Benzydamine',
      'description': 'It is a non-steroidal anti-inflammatory drug which is used for local anesthetic and analgesic effects mainly for the mouth. It acts on inflammation such as pain and oedema. It completes this by stabilizing the cellular membrane and inhibiting the prostaglandin synthesis.',
      'drug class': 'Non-Steroidal Anti-Inflammatory Drug (NSAID)',
      'side effects': ['Burning or stinging', 'Numbness or tingling around the mouth', 'Upset stomach or throwing up', 'Throat irritation', 'Cough', 'Dry mouth', 'Feeling sleepy', 'Headache'],
    },
    {
      'name': 'Betahistine',
      'description': 'Betahistine is used to treat Ménière disease. These symptoms include: feeling dizzy and a spinning sensation and ringing in ears. Betahistine works by increasing blood flow to this part of your ear and reducing the amount of fluid there.',
      'drug class': 'Histamine',
      'side effects': ['Headache', 'Nausea', 'Heartburn or indigestion', 'Bloating', 'Abdominal Pain','Dizziness', 'Allergic reaction', 'Diarrhea', 'Dry mouth'],
    },
    {
      'name': 'Bimatoprost',
      'description': 'Bimatoprost lowers the pressure in the eye by increasing the flow of natural eye fluids out of the eye. As a result, it can be used to treat glaucoma. Moreover, it can also allow for eyelash growth. ',
      'drug class': 'Prostaglandin Analogs',
      'side effects': ['Itchy eyes','Dry eyes','Red eyes','Double vision','Crusting or drainage from the eye', 'Halos around lights', 'Cough', 'Difficulty seeing at night', 'Difficulty with breathing'],
    },
    {
      'name': 'Bisacodyl',
      'description': 'Bisacodyl helps relieve constipation by helping your bowel move so you can digest more easily. It also softens your poop.',
      'drug class': 'Stimulant laxative',
      'side effects': ['Bloating', 'Gas', 'Nausea', 'Stomach cramping'],
    },
    {
      'name': 'Bisoprolol',
      'description': 'Beta blocker medicine which can be used to treat high blood pressure and heart failure. It can’t stop heart disease, but it can be used to prevent them and strokes.',
      'drug class': 'Selective beta-blocker',
      'side effects': ['Headache', 'Extreme fatigue','Diarrhea','Nausea', 'Bradycardia', 'Fainting', 'Arthralgia','Nasal congestion', 'Sleeplessness'],
    },
    {
      'name': 'Brinzolamide',
      'description': 'It can help with high pressure inside the eye and with glaucoma. When there is too much fluid in the eye, the medicine will help the eye produce less fluids.',
      'drug class': 'Carbonic anhydrase inhibitors',
      'side effects': ['Eye pain', 'Dry eyes', 'Headache', 'Swelling of the eyes', 'Chills', 'Red eye', 'Abdominal or stomach pain', 'Hives', 'Sore throat'],
    },
    {
      'name': 'Bumetanide',
      'description': 'It helps treat fluid retention as well as swelling that is caused by congestive heart failure, liver disease, kidney disease, etc.',
      'drug class': 'Loop diuretics',
      'side effects': ['Dizziness', 'Hearing loss', 'Rapid breathing', 'Abdominal pain', 'Headache', 'Heart arrhythmia', 'Muscle cramps', 'Hallucination', 'Hives'],
    },
    {
      'name': 'Buprenorphine',
      'description': 'Buprenorphine is used to treat pain and opioid use disorder. This medication is a synthetic analog of thebaine which is from a poppy flower.',
      'drug class': 'Opioid partial agonist-antagonists',
      'side effects': ['Constipation','Feeling sleepy or sick', 'Sensation of spinning (vertigo)', 'Confusion', 'Headaches', 'Stomach pain', 'Itching or skin rashes'],
    },
    {
      'name': 'Buscopan (Hyoscine Butylbromide)',
      'description': 'Buscopan can help relieve stomach cramps which is linked to irritable bowel syndrome. It also helps bladder cramps during menstrual cycles. ',
      'drug class': 'Hyoscine Butylbromide',
      'side effects': ['Dry mouth','Constipation','Blurred vision','Fast heart rate'],
    },
    {
      'name': 'Calcipotriol',
      'description': 'Calcipotriol is a vitamin D medication that helps suppress the multiplication of keratinocytes, resulting in the expansion of a cell population. It is used in the treatment of plaque psoriasis ',
      'drug class': 'Synthetic vitamin D3 derivatives',
      'side effects': ['Rash', 'Itching', 'Worsening of psoriasis', 'Swelling or burning skin','Xeroderma', 'Headache','Erythema', 'Thinning of skin', 'Stinging sensation'],
    },
    {
      'name': 'Candesartan',
      'description': 'Candesartan blocks the action of a substance in the body that would cause blood vessels to tighten. Thus, candesartan can help relax blood vessels. This lowers blood pressure and increases the supply of blood and oxygen to the heart.',
      'drug class': 'Angiotensin II receptor blocker (ARB)',
      'side effects': ['Dizziness', 'Back pain', 'Fast or irregular heartbeat', 'Headache', 'Nausea', 'Confusion', 'Decreased urine output', 'Fever'],
    },
    {
      'name': 'Carbamazepine',
      'description': 'Carbamazepine is used to treat certain types of seizures and bipolar disorder. It is also used to relieve pain caused by tics.',
      'drug class': 'Anticonvulsants',
      'side effects': ['Nausea', 'Skin rash','Constipation','Dizziness','Drowsiness','Xerostomia','Fainting','Headache', 'Irregular heartbeat'],
    },
    {
      'name': 'Carbimazole',
      'description': 'Carbimazole is a medicine used to treat an overactive thyroid. This means when the thyroid gland makes too many hormones, it slows it down. This helps regulate things that control your heart rate and body temperature.',
      'drug class': 'Imidazoles',
      'side effects': ['Headache', 'Skin rash', 'Arthralgia', 'Nausea', 'Thinning hair', 'Dizziness', 'Fever', 'Bruise', 'Change in taste'],
    },
    {
      'name': 'Carbocisteine',
      'description': 'It works by making mucus less sticky which allows you to easily caught it up. If you are diagnosed with chronic obstructive pulmonary disease (COPD) or cystic fibrosis, your body can make too much phlegm and it can be thick and sticky.',
      'drug class': 'Mucolytic',
      'side effects': ['Struggle to breath', 'Swollen mouth'],
    },
    {
      'name': 'Carmellose Sodium Eye Drops',
      'description': 'It is a lubricant to treat dry eyes.',
      'drug class': 'Ophthalmic Medications ',
      'side effects': ['Itching and stinging of eye'],
    },
    {
      'name': 'Carvedilol',
      'description': 'Nonselective adrenergic blocker which is used for chronic therapy of heart failure. Simply, it works by affecting the response from nerve impulses to the certain parts of the body, the heart. This means the heart will be slower and decrease blood pressure.',
      'drug class': 'Nonselective adrenergic blocker',
      'side effects': ['Dizziness', 'Shortness of breath', 'Slow heartbeat', 'Confusion', 'Fainting', 'Weight gain', 'Cough', 'Decreased frequency or amount of urine', 'Diarrhea'],
    },
    {
      'name': 'Cefalexin',
      'description': 'It is used for bacterial infections, such as pneumonia and other chest infections. This also includes skin infections and urinary infections.',
      'drug class': 'Antibiotic',
      'side effects': ['Headache', 'Rash', 'Abdominal pain', 'Fatigue', 'Indigestion'],
    },
    {
      'name': 'Cetirizine',
      'description': 'It is used for allergies such as hay fever and conjunctivitis (red, itchy eye).',
      'drug class': 'Antihistamines',
      'side effects': ['Drowsiness, Dizziness, Stomach pain, Blurred vision, Vomiting, Shortness of breath, Diarrhea'],
    },
    {
      'name': 'Champix (varenicline)',
      'description': 'Champix is a medicine that can help with the addiction of smoking. This is only available through prescription. It reduces the cravings for nicotine and helps with the negative withdrawal symptoms.',
      'drug class': 'Smoking cessation aids',
      'side effects': ['Abnormal dreams', 'Absence of menstruation', 'Change in taste', 'Difficulty having a bowel movement', 'Difficulty in moving', 'Excess air or gas in the stomach or bowels', 'Joint pain or swelling', 'Lack or loss of strength'],
    },
    {
      'name': 'Chloramphenicol',
      'description': 'Chloramphenicol helps manage superficial eye infections such as bacterial conjunctivitis. It has also been used for the treatment of typhoid and cholera. Chloramphenicol is an antibiotic which inhibits protein synthesis.',
      'drug class': 'Antibiotic',
      'side effects': ['Rash', 'Drowsiness', 'Vomiting', 'Pale skin', 'Fever', 'Unresponsiveness', 'Unusual bleeding or bruising', 'Blurred vision', 'Confusion'],
    },
    {
      'name': 'Chlorhexidine',
      'description': 'Chlorhexidine is used to prevent infections from surgery as it cleans the skin before and needle injection or after an injury. It is also used to clean the hands before the procedure so it works by killing and preventing the growth of bacteria.',
      'drug class': 'Antiseptic antibacterial agents',
      'side effects': ['Swelling of the face','Mouth Irritation', 'Severe skin rash', 'Mouth ulcer','Decreased taste sensation', 'Tooth discoloration', 'Blistering or peeling', 'Xerostomia', 'Hives'],
    },
    {
      'name': 'Chlorphenamine (Piriton)',
      'description': 'Chlorphenamine is a medicine that relieves the symptoms of allergies. It is known as a drowsy (sedating) antihistamine. This means that it is likely to make you feel more sleepy than some other antihistamines.',
      'drug class': 'Antihistamine ',
      'side effects': ['Headache, Blurred vision, Drowsiness, Feeling sick, Difficulty peeing, Double vision'],
    },
    {
      'name': 'Cinnarizine',
      'description': 'Cinnarizine helps you stop feeling sick like nausea or vomiting. It accomplishes this by blocking the effects of histamine in the brain to reduce the travel sickness symptoms. It also improves blood flow in the inner ear.',
      'drug class': 'Antihistamine',
      'side effects': ['Headache', 'Weight gain', 'Skin rash', 'Sweating','Delayed onset muscle soreness', 'Depression'],
    },
    {
      'name': 'Ciprofloxacin',
      'description': 'Ciprofloxacin is used to treat bacterial infections like urinary infections and pneumonia.',
      'drug class': 'Antibiotic',
      'side effects': ['Seizures', 'Nausea', 'Paresthesia','Skin rash', 'Confusion', 'Joint stiffness'],
    },
    {
      'name': 'Citalopram',
      'description': 'Citalopram is often used to treat low mood such as depression) and also sometimes for panic attacks. It helps many people recover from depression, and has fewer side effects than older antidepressants.',
      'drug class': 'Selective serotonin reuptake inhibitor (SSRI)',
      'side effects': ['Insomnia','Sweating','Drowsiness','Sexual Problems','Dizziness','Nausea'],
    },
    {
      'name': 'Clarithromycin',
      'description': 'It kills bacteria and prevents its growth, but this medicine doesn’t work on colds, flu, or other virus infections. This will only work on doctor’s prescription.',
      'drug class': 'Macrolide antibiotics',
      'side effects': ['Itching skin rash', 'Abdominal pain', 'Dizziness', 'Headache', 'Nausea', 'Chills', 'Sore mouth or tongue'],
    },
    {
      'name': 'Clobetasol',
      'description': 'Clobetasol can combat itching, redness, dryness, crusting, and discomfort of  scalp and skin conditions, including psoriasis, which makes the skin red and scaly in some areas in patches. This also includes eczema which can cause skin to be dry and itchy.',
      'drug class': 'Corticosteroids',
      'side effects': ['Backache', 'Blindness' ,'Pain in hairy areas', 'Change in vision','Facial hair growth in females', 'Fractures', 'Fruit-like breath odor'],
    },
    {
      'name': 'Clonazepam',
      'description': 'Clonazepam is used for the treatment of panic disorder and epilepsy. It also helps with restless leg syndrome, acute mania, insomnia, etc. ',
      'drug class': 'Benzodiazepines',
      'side effects': ['Drowsiness', 'Unsteadiness', 'Problems with coordination', 'Difficulty remembering', 'Increased saliva', 'Muscle or joint pain', 'Frequent urination'],
    },
    {
      'name': 'Clonidine',
      'description': 'Clonidine lowers blood pressure and heart rate by relaxing our arteries and this increases the blood flow to the heart.  This can also help with ADHD in children or tics.',
      'drug class': 'Antihypertensive',
      'side effects': ['Sleepy, Dry Mouth, Headaches, Depression'],
    },
    {
      'name': 'Clopidogrel',
      'description': 'Clopidogrel reduces the chance that a harmful blood clot will form by stopping platelets from bumping together in the blood. It can also increase the chances of severe bleeding for certain individuals. ',
      'drug class': 'Platelet inhibitor',
      'side effects': ['Bruise', 'Headache', 'Nosebleed', 'Bleeding', 'Confusion', 'Fast heartbeat'],
    },
    {
      'name': 'Co-dydramol',
      'description': 'Co-dydramol is made up of paracetamol and dihydrocodeine which are two different types of painkillers. These are used to treat pains, including: headaches, migraines, muscle and joint, period pain and toothache.',
      'drug class': 'Opioids',
      'side effects': ['Headaches', 'Difficulty peeing', 'Skin rash', 'Shortness of breath','Difficulty swallowing'],
    },
    {
      'name': 'Codeine',
      'description': 'Codeine is a pain reliever which is for mild or somewhat severe pain. It is used to reduce coughing found in aspirin or other cough and cold medications.',
      'drug class': 'Opioid',
      'side effects': ['Dizziness', 'Respiratory depression', 'Fast heartbeat', 'Erythema', 'Noisy breathing'],
    },
    {
      'name': 'Colchicine',
      'description': 'Colchicine for treating inflammation and pain. It reduces the crystals of uric acid that can build up in the joints which results in inflammation.',
      'drug class': 'Anti-gout class',
      'side effects': ['Nausea', 'Sensation of pins and needles', 'Fatigue', 'Stomach pain: Cramp','Bleeding on probing'],
    },
    {
      'name': 'Colecalciferol',
      'description': 'Cholecalciferol will help the body use more calcium found in foods or other supplements taken. This way the body can develop healthier bones, muscles, nerves, and helps support our immune system.',
      'drug class': 'Vitamin D analogs',
      'side effects': ['Tightness in the chest', 'Allergy', 'Nausea', 'Cough', 'Fast heartbeat'],
    },
    {
      'name': 'Cyanocobalamin',
      'description': 'Cyanocobalamin is a compound of vitamin B12 which can help with vitamin deficiencies. ',
      'drug class': 'Corrinoid',
      'side effects': ['Shortness of breath', 'Swelling', 'Weight gain'],
    },
    {
      'name': 'Cyclizine',
      'description': 'Cyclizine helps you feel less sick such as feeling the urge to vomit or nausea. It completes its job by blocking a chemical called histamine in the brain that is in charge of making you feel bad. It can be used to treat morning sickness to treat morning sickness.',
      'drug class': 'Antihistamine',
      'side effects': ['Feeling Drowsy', 'Blurred vision', 'Headache', 'Dry mouth'],
    },
    {
      'name': 'Dabigatran',
      'description': 'Dabigatran helps thin the blood which can reduce the chances of strokes happening in patients that have non-valvular atrial fibrillation (AF), a heart rate abnormality. ',
      'drug class': 'Anticoagulant',
      'side effects': ['Bleeding', 'Heartburn', 'Vomit that looks like coffee grounds', 'Nausea', 'Upset stomach', 'Allergic reaction'],
    },
    {
      'name': 'Dapagliflozin',
      'description': 'Dapagliflozin is used to help with type 2 diabetes. It helps with working on the working kidney to prevent the absorption of glucose. It helps lower the blood sugar level, but does not help with diabetes 1.',
      'drug class': 'Sodium-glucose co-transporter 2 (SGLT2) inhibitors',
      'side effects': ['Skin rash', 'Back pain', 'Fast heartbeat', 'Bladder pain', 'Cough', 'Difficulty with swallowing'],
    },
    {
      'name': 'Diazepam',
      'description': 'Diazepam helps with the management of anxiety, but only gives short temp relief of the symptoms. ',
      'drug class': 'Benzodiazepine',
      'side effects': ['Dizziness', 'Decrease in urine volume', 'Chills'],
    },
    {
      'name': 'Diclofenac',
      'description': 'Diclofenac works by reducing hormones that cause inflammation and pain in the body. You can use it as a gel or take it as a tablet or capsule, but they all have the same effect. ',
      'drug class': 'Non-steroidal anti-inflammatory drugs (NSAID)',
      'side effects': ['Headache', 'Heartburn', 'Blistering', 'Peeling', 'Loosening of the skin', 'Nausea', 'Ringing in the ears', 'Stomach ache'],
    },
    {
      'name': 'Diphenhydramine',
      'description': 'Diphenhydramine relieves the symptoms of allergies. It also makes you feel drowsy, unlike other antihistamines.',
      'drug class': 'Antihistamine',
      'side effects': ['Constipation', 'Blurred vision', 'Confusion', 'Headache', 'Nausea', 'Irregular heartbeat', 'Sleepiness'],
    },
    {
      'name': 'Dipyridamole',
      'description': 'Dipyridamole helps against stroke by an adjunctive agent after the valve replacement.',
      'drug class': 'Antiplatelet agents',
      'side effects': ['Stomach pain','Headache', 'Rash', 'Vomiting', 'Flushing (feeling of warmth)', 'Itching'],
    },
    {
      'name': 'Docusate',
      'description': 'Docusate is a for managing and treating constipation. It completes this by reducing the surface tension of oil and water within the stool, which facilitates the water and lipids into the stool mass. ',
      'drug class': 'Stool softener',
      'side effects': ['Stomach cramp', 'Burning feeling', 'Nausea'],
    },
    {
      'name': 'Domperidone',
      'description': 'Domperidone helps stop feeling or being sick (nausea or vomiting). It completes this by relaxing the muscles at the top of the stomach and tightens the muscles at the bottom of the stomach which makes it less likely to vomit.',
      'drug class': 'Dopamine antagonists',
      'side effects': ['Menstrual irregularities', 'Irregular heartbeat', 'Abdominal cramps'],
    },
    {
      'name': 'Donepezil',
      'description': 'Donepezil is used to treat dementia, memory loss and mental changes, associated with mild, moderate, or severe Alzheimers disease. Donepezil will not cure Alzheimers disease, and it will not stop the disease from getting worse. However, it can improve thinking ability in some patients.',
      'drug class': 'Acetylcholinesterase inhibitor',
      'side effects': ['Diarrhea','Loss of appetite', 'Muscle cramps', 'Fatigue', 'Decreased Urination'],
    },
    {
      'name': 'Dosulepin',
      'description': 'Dosulepin is used for antidepressants which are also used for some types of nerve pain, and to prevent migraines. ',
      'drug class': 'Tricyclic antidepressant',
      'side effects': ['Blurred vision','Difficulty peeing','Dry mouth'],
    },
    {
      'name': 'Doxazosin',
      'description': 'Doxazosin treats high blood pressure and benign prostatic hyperplasia.',
      'drug class': 'Alpha blockers',
      'side effects': ['Swelling of hands','Headache', 'Tiredness', 'Weight gain'],
    },
    {
      'name': 'Doxycycline',
      'description': 'Doxycycline kills bacteria or prevents their growth. However, this medicine will not work for colds, flu, or other virus infections. This medicine is available only with your doctors prescription',
      'drug class': 'Tetracycline antibiotics',
      'side effects': ['Severe headaches', 'Vomiting', 'Blurred vision'],
    },
    {
      'name': 'Empagliflozin',
      'description': 'Empagliflozin is in a class of medications called. It lowers blood sugar by causing the kidneys to get rid of more glucose in the urine.',
      'drug class': 'Sodium-glucose co-transporter 2 (SGLT2) inhibitors',
      'side effects': ['Bladder pain', 'Bloody or cloudy urine', 'Difficult, burning, or painful urination', 'Frequent urge to urinate'],
    },
    {
      'name': 'Enalapril',
      'description': 'Enalapril blocks a substance in the body that causes the blood vessels to tighten. As a result, enalapril relaxes the blood vessels. This lowers blood pressure and increases the supply of blood and oxygen to the heart.',
      'drug class': 'Angiotensin converting enzyme (ACE) inhibitor',
      'side effects': ['Dry, tickly cough', 'Feeling dizzy', 'Headaches','Diarrhea', 'Itching or a mild rash','Blurred vision'],
    },
    {
      'name': 'Eplerenone',
      'description': 'Eplerenone is used in the management and treatment of heart failure and hypertension. ',
      'drug class': 'Aldosterone antagonist',
      'side effects': ['Headache', 'Diarrhea', 'Stomach pain', 'Cough', 'Excessive tiredness', 'Flu-like symptoms'],
    },
    {
      'name': 'Erythromycin',
      'description': 'Erythromycin stops the growth of bacteria. These antibiotics will not work on colds, flu, or other viral infections. ',
      'drug class': 'Macrolide antibiotics',
      'side effects': ['Yellowing of the whites in the skin or eyes.'],
    },
    {
      'name': 'Escitalopram',
      'description': 'Escitalopram is used to treat depression and generalized anxiety disorder. It increases the activity of the chemical serotonin in the brain.',
      'drug class': 'Selective serotonin reuptake inhibitors (SSRIs)',
      'side effects': ['Fever', 'Sweating', 'Confusion', 'Fast or irregular heartbeat', 'Severe muscle stiffness or twitching', 'Agitation', 'Hallucinations', 'Loss of coordination', 'Nausea, Vomiting, or diarrhea', 'Abnormal bleeding or bruising', 'Nose bleeding', 'Headache'],
    },
    {
      'name': 'Esomeprazole',
      'description': 'It reduces the amount of acid your stomach makes. This is used to treat indigestion, heartburn, and reflux. More importantly it can be used for gastro-oesophageal reflux disease which makes your acid reflux keep on happening.',
      'drug class': 'Proton pump inhibitors',
      'side effects': ['Headaches','Being sick', 'Diarrhea','Constipation', 'Stomach pain', 'Farting'],
    },
    {
      'name': 'Ezetimibe',
      'description': 'Ezetimibe reduces the absorption of cholesterol from foods and the production of cholesterol in your body. ',
      'drug class': 'Selective cholesterol-absorption inhibitors',
      'side effects': ['URTIs, including sinus infections', 'Diarrhea', 'Joint pain', 'Fatigue', 'Pain in your arms and legs', 'Back pain'],
    },
    {
      'name': 'Felodipine',
      'description': 'Felodipine affects the movement of calcium into the cells of the heart and blood vessels. In turn, it helps relax these blood vessels and increases the supply of blood and oxygen to the heart and reduces the workload.',
      'drug class': 'Calcium channel blocker',
      'side effects': ['Blurred vision', 'Chest pain', 'Congestion', 'Mucus', 'Irregular heartbeat'],
    },
    {
      'name': 'Fexofenadine',
      'description': 'Fexofenadine relieves symptoms of hay fever and hives of the skin by preventing the effects of a substance called histamine.',
      'drug class': 'Antihistamine',
      'side effects': ['Headaches', 'Feeling sleepy', 'Dry mouth', 'Feeling sick', 'Dizziness'],
    },
    {
      'name': 'Flucloxacillin',
      'description': 'Flucloxacillin is an antibiotic that kills bacteria that are causing infection.',
      'drug class': 'Penicillin',
      'side effects': ['Skin rash', 'Itching or hives', 'Swelling of the face, lips, tongue or other parts of the body', 'Shortness of breath', 'Wheezing or troubled breathing'],
    },
    {
      'name': 'Fluconazole',
      'description': 'Fluconazole is used to treat serious fungal or yeast infections, including vaginal candidiasis, oropharyngeal candidiasis, esophageal candidiasis, candida infections: urinary tract infections, peritonitis, inflammation of the lining of the stomach.',
      'drug class': 'Triazoles',
      'side effects': ['Chest tightness', 'Difficulty with swallowing', 'Fast heartbeat', 'Headache', 'Hives', 'itching or skin rash'],
    },
    {
      'name': 'Fluoxetine (Prozac)',
      'description': 'Fluoxetine is a type of antidepressant which is used to treat depression, and sometimes obsessive compulsive disorder and bulimia. It works by increasing the levels of serotonin in the brain.',
      'drug class': 'Selective serotonin reuptake inhibitor (SSRI)',
      'side effects': ['Agitation', 'Fever', 'Sweating', 'Confusion', 'Fast or irregular heartbeat', 'Shivering', 'Severe muscle stiffness or twitching', 'Hallucinations', 'Loss of coordination'],
    },
    {
      'name': 'Folic acid',
      'description': 'A nutrient in the vitamin B complex that the body has to have in order to be able to function properly and stay healthy/strong. The folic acid helps make red blood cells. This can be found in whole-grain breads and cereals, liver, green vegetables, orange juice, lentils, beans, and yeast.',
      'drug class': 'Antibiotics',
      'side effects': ['Bad taste in your mouth','Nausea', 'Loss of appetite', 'Confusion', 'Irritability', 'Sleep pattern disturbance'],
    },
    {
      'name': 'Furosemide',
      'description': 'Furosemide belongs to help treat fluid retention and swelling that is caused by congestive heart failure, liver disease, kidney disease, or other medical conditions.',
      'drug class': 'Loop diuretics',
      'side effects': ['Peeing more than normal','Feeling thirsty', 'Headaches', 'Feeling or being sick'],
    },
    {
      'name': 'Fusidic acid',
      'description': 'Fusidic acid is also sometimes known as sodium fusidate. It stops bacteria from growing. It is used to treat bacterial infections, such as skin infections and eye infections.',
      'drug class': 'Antibiotic',
      'side effects': ['Blurred vision, Eye irritation'],
    },
    {
      'name': 'Gabapentin',
      'description': 'Gabapentin treats seizures by decreasing abnormal excitement in the brain. Gabapentin relieves the pain of PHN by changing the way the body senses pain. It is not known exactly how gabapentin works to treat restless legs syndrome.',
      'drug class': 'Anticonvulsants',
      'side effects': ['Feeling tired','Dizziness','Headache','Nausea and vomiting','Fever','Difficulty speaking','Recurring infections', 'Memory loss'],
    },
    {
      'name': 'Gaviscon (alginic acid)',
      'description': 'Gavison forms a protective layer that floats on top of the items in the stomach. This stops stomach acid escaping up into your food pipe. Gaviscon also contains an antacid that neutralizes excess stomach acid and reduces pain and discomfort.',
      'drug class': 'Antacids',
      'side effects': ['Bloating', 'Lots of gas'],
    },
    {
      'name': 'Gliclazide',
      'description': 'Gliclazide is used to treat type 2 diabetes. It is a medicine known as a. It decreases the amount of insulin that the pancreas makes which eventually lowers the bodies blood sugar.',
      'drug class': 'Sulfonylurea',
      'side effects': ['Stomach pain or heartburn', 'Constipation, diarrhea, throwing up, or upset stomach', 'Back pain', 'Feeling full'],
    },
    {
      'name': 'Glimepiride',
      'description': 'Glimepiride is a medication used in the management and treatment of type 2 diabetes by increasing insulin levels.',
      'drug class': 'Sulfonylurea',
      'side effects': ['Difficulty with swallowing', 'Fast heartbeat', 'Hives', 'Itching', 'Puffiness or swelling of the eyelids', 'Skin rash', 'Tightness in the chest'],
    },
    {
      'name': 'Haloperidol',
      'description': 'Haloperidol is used to treat nervous, emotional, and mental conditions such as schizophrenia. It is also used to control the symptoms of Tourettes disorder. ',
      'drug class': 'Conventional antipsychotics',
      'side effects': ['Feeling dizzy or low blood pressure, Constipation, Blurred vision, Problems sleeping'],
    },
    {
      'name': 'Heparinoid',
      'description': 'A heparinoid is really similar to heparin by mimicking the effects that is used for treating cardiovascular disease. Unlike heparin, it doesn’t require injection which means it can be taken orally.',
      'drug class': 'Heparin-like polysaccharide',
      'side effects': ['Rash'],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': 'Hydroxocobalamin',
      'description': 'Hydroxocobalamin is an injectable form of vitamin B12. It is used to prevent macrocytic anemia associated with vitamin B12 deficiency. It can also be used in therapy to treat Leber optic atrophy.',
      'drug class': 'Cyanide Antidotes',
      'side effects': ['Pain', 'Swelling or itchy skin where you had the injection', 'Diarrhea', 'Headaches', 'Feeling dizzy', 'Hot flushes'],
    },
    {
      'name': 'Ibuprofen',
      'description': 'It is used to treat fever, swelling, pain, and redness by preventing the body from making a substance that causes inflammation. It is also known as Advil and Motrin.',
      'drug class': 'Nonsteroidal anti-inflammatory drug (NSAID)',
      'side effects': ['Headaches','Feeling dizzy','Feeling sick', 'Indigestion'],
    },
    {
      'name': 'Indapamide',
      'description': 'Indapamide is a water pill that reduces the amount of water in the body by increasing the flow of urine, which helps lower the blood pressure. ',
      'drug class': 'Thiazide-like diuretic',
      'side effects': ['Back pain', 'Blistering, peeling, or loosening of the skin', 'Increased sensitivity of skin to sunlight', 'Red irritated eyes', 'Red skin lesions, often with a purple center', 'Redness or other discoloration of the skin', 'Severe sunburn'],
    },
    {
      'name': 'Insulin',
      'description': 'It is a hormone that is found in the pancreas and made by the islet cells. Insulin controls the amount of sugar in the blood by moving it into the cells, where it can be used by the body for energy.',
      'drug class': 'Protein',
      'side effects': ['Bleeding or bruising where you inject', 'Fatty lumps under the skin', 'Changes in your vision'],
    },
    {
      'name': 'Irbesartan',
      'description': 'Irbesartan works by blocking a substance in the body that causes blood vessels to tighten. As a result, irbesartan relaxes the blood vessels. This lowers blood pressure and increases the supply of blood and oxygen to the heart.',
      'drug class': 'Angiotensin II receptor blocker (ARB)',
      'side effects': ['Feeling dizzy', 'Headaches','Feeling sick', 'Vomiting', 'Pain in your joints or muscles'],
    },
    {
      'name': 'Labetalol',
      'description': 'Labetalol affects the response to nerve impulses in certain parts of the body, like the heart. As a result, the heart beats slower and decreases the blood pressure. When the blood pressure is lowered, the amount of blood and oxygen is increased to the heart.',
      'drug class': 'Beat-blocker',
      'side effects': ['Cold fingers or toes', 'Feeling sick or being sick', 'Stomach pain'],
    },
    {
      'name': 'Lactulose',
      'description': 'Lactulose is a laxative when you have difficult pooping. It also helps a condition that is caused by liver disease. Lactulose comes as a sweet syrup that you swallow.',
      'drug class': 'Ammonium Detoxicants',
      'side effects': ['Confusion','Decreased urine','Fainting', 'Fast or irregular heartbeat', 'Increased thirst','Lightheadedness', 'Mood changes','Muscle pain, cramps, or twitching'],
    },
    {
      'name': 'Lansoprazole',
      'description': 'Lansoprazole reduces the amount of acid made in the stomach. It can help treat stomach ulcers, gastroesophageal reflux disease, and conditions in which the stomach makes too much acid.',
      'drug class': 'Proton pump inhibitor',
      'side effects': ['Headache', 'Diarrhea', 'Stomach pain'],
    },
    {
      'name': 'Letrozole',
      'description': 'It is used to treat certain types of breast cancer in postmenopausal women. It can also be studied for other treatments of different types of cancer. This medication lowers the amount of estrogen made in the body which can lower the growth of cancer cells.',
      'drug class': 'Nonsteroidal aromatase inhibitors',
      'side effects': ['Hot flushes', 'Night sweats', 'Nausea', 'Vomiting', 'Loss of appetite', 'Constipation', 'Diarrhea', 'Heartburn'],
    },
    {
      'name': 'Levothyroxine',
      'description': 'Levothyroxine is used to treat an underactive thyroid gland (hypothyroidism). The thyroid gland is used to help control energy levels and growth. Levothyroxine is taken to replace the missing thyroid hormone thyroxine.',
      'drug class': 'Hormones',
      'side effects': ['Excessive sweating', 'Trouble sleeping or insomnia', 'Fast heart rate','Headache', 'Irritability', 'Larger-than-normal appetite', 'Weight loss', 'Heat intolerance'],
    },
    {
      'name': 'Lidocaine',
      'description': 'Lidocaine prevents pain by blocking the signals at the nerve endings in the skin. This medicine does not cause unconsciousness as general anesthetics do when used for surgery, but allows for numbing.',
      'drug class': 'Local anesthetics',
      'side effects': ['Bluish-colored lips or fingernails','Discomfort','Cold, clammy, pale skin','Confusion', 'Continuing ringing or buzzing or other unexplained noise in the ears','Difficulty breathing', 'Difficulty swallowing', 'Dizziness or lightheadedness'],
    },
    {
      'name': 'Linagliptin',
      'description': 'Linagliptin treats high blood sugar levels caused by type 2 diabetes. It can control blood sugar levels by increasing substances in the body that make the pancreas release more insulin.',
      'drug class': 'Dipeptidyl peptidase-4 (DPP-4) inhibitors',
      'side effects': ['Anxiety','Cold sweats','Confusion','Cool, pale skin','Depression', 'Fast heartbeat', 'Headache', 'Increased hunger'],
    },
    {
      'name': 'Lisinopril',
      'description': 'Lisinopril treats high blood pressure (hypertension) and heart failure. It can be used after a heart attack in order to prevent it from happening or getting worse the next time. It also improves the survival of a heart attack. ',
      'drug class': 'ACE inhibitor',
      'side effects': ['Blurred vision','Cloudy urine','Confusion','Decrease in urine output or decrease in urine-concentrating ability','Dizziness, faintness, or lightheadedness when getting up suddenly from a lying or sitting position','Sweating', 'Unusual tiredness or weakness'],
    },
    {
      'name': 'Lorazepam',
      'description': 'Lorazepam relieves symptoms of anxiety because it is a central nervous system depressant. These medicines slow down the nervous system.',
      'drug class': 'Benzodiazepine',
      'side effects': ['Sedation','Dizziness','Asthenia','Local injection site reaction','Respiratory depression','Hypoventilation with IV use','Hypotension'],
    },
    {
      'name': 'Lymecycline',
      'description': 'Lymecycline is a 2nd generation tetracycline antibiotic used to treat acne and other bacterial infections. It is very cost-effective and has safety and efficacy.',
      'drug class': 'Tetracycline antibiotic',
      'side effects': ['Feeling sick', 'Stomach pain','Diarrhea', 'Headaches'],
    },
    {
      'name': 'Macrogol',
      'description': 'Macrogol is a type of laxative taken to treat constipation. It is also used to clear hard poop in the system which happens when you haven’t pooped in a long time.',
      'drug class': 'Osmotic laxative',
      'side effects': ['Diarrhea', 'Indigestion', 'Stomach pain', 'Bloating and farting','Feeling sick','Sore bottom'],
    },
    {
      'name': 'Mebendazole',
      'description': 'Mebendazole is used to treat infections from worms. Specifically, it is used for threadworms and other less common worm types. It works by stopping worms from using the glucose in our bodies to survive, so eventually it will lose energy and die. ',
      'drug class': 'Anthelmintics',
      'side effects': ['Loss of appetite', 'Abdominal pain', 'Diarrhea', 'Flatulence', 'Nausea','Vomiting', 'Headache', 'Tinnitus', 'Increased liver enzymes'],
    },
    {
      'name': 'Mebeverine',
      'description': 'Mebeverine treats people with muscle spasms. It makes stomach cramps less painful if someone has an irritable bowel or other conditions. It works by relaxing the muscles in the gut. ',
      'drug class': 'Antispasmodic',
      'side effects': ['Mild skin irritation', 'Bloating', 'Dry mouth', 'Heartburn', 'Dizziness', 'Lightheadedness'],
    },
    {
      'name': 'Medroxyprogesterone tablets',
      'description': 'Medroxyprogesterone is used for those who have the unusual stopping of menstrual periods or abnormal amounts of uterine bleeding. It can also be used to prevent the thickening of the lining in the womb with women who take estrogens.',
      'drug class': 'Progestin hormone',
      'side effects': ['Breast pain','Dizziness','Changes in your menstrual periods','Headache','Blurred vision','Weight gain','Changes in skin color','Depression','Fever'],
    },
    {
      'name': 'Melatonin',
      'description': 'Melatonin is a hormone in the brain that produces a response to darkness. This means that it plays a huge role in the circadian rhythm which is a 24 hour clock with sleep. When people are exposed to light before they sleep it will mess with the 24 hour clock, so the melatonin supplements help with that.',
      'drug class': 'Hormone',
      'side effects': ['Feeling sleepy or tired in the daytime', 'Headache', 'Stomach ache', 'Feeling dizzy', 'Feeling irritable or restless', 'Dry or itchy skin'],
    },
    {
      'name': 'Metformin',
      'description': 'Metformin decreases the amount of glucose released into the bloodstream from the liver. It also increases the bodys efficiency in the use of glucose. ',
      'drug class': 'Biguanides',
      'side effects': ['Headache', 'Diarrhea', 'Abdominal pain', 'Nausea', 'Decreased appetite', 'Dizziness', 'Heart arrhythmia', 'Shallow breathing'],
    },
    {
      'name': 'Methadone',
      'description': 'Methadone is used to treat people who abuse opioids. It works by changing how the brain and nervous system respond to pain. It makes the withdrawal symptoms better by lessening the pain. It blocks the euphoric effects of opioids. ',
      'drug class': 'Opiate (narcotic) analgesics',
      'side effects': ['Experience difficulty breathing or shallow breathing','Feel lightheaded or faint','Experience hives or a rash', 'Swelling of the face, lips, tongue, or throat','Feel chest pain','Experience a fast or pounding heartbeat', 'Experience hallucinations or confusion'],
    },
    {
      'name': 'Methotrexate',
      'description': 'Methotrexate is a type of cancer medication. It blocks the enzyme that is needed for cells to live. This interferes with the growth of the cancer cells which will eventually get killed by the body. ',
      'drug class': 'Antineoplastics',
      'side effects': ['Mouth ulcer','Nausea','Cough','Diarrhea', 'Fever', 'Unusual bruising or bleeding', 'Burning while urinating', 'Kidney disease', 'Stomach pain'],
    },
    {
      'name': 'Metoprolol',
      'description': 'Metoprolol is a type of medicine that can lower the blood pressure and heart rate in the body. It makes it easier for the heart to pump blood to the rest of the body. It can treat high blood pressure and can prevent chest pain or heart attacks.',
      'drug class': 'Beta-blocker',
      'side effects': ['Diarrhea','Dizziness', 'Tiredness', 'Rash', 'Bradycardia', 'Nausea', 'Cold feet and hands', 'Chest pain', 'Night blindness'],
    },
    {
      'name': 'Metronidazole',
      'description': 'Metronidazole works by killing bacteria and preventing its growth. This medication does not work with colds, flu, or other virus infections.',
      'drug class': 'Antibiotics',
      'side effects': ['Dizziness', 'Diarrhea', 'Headache', 'Nausea', 'Loss of appetite', 'Metallic Taste', 'Seizures', 'Confusion', 'Itching'],
    },
    {
      'name': 'Mirabegron',
      'description': 'Mirabegron is used for an overactive bladder which means when you have the urge to pee really often. It works on the muscles of the blatter that increases the amount of urine the bladder can hold.',
      'drug class': 'Sympathomimetic',
      'side effects': ['Headache', 'Constipation', 'High blood pressure', 'Back pain', 'Cough', 'Dizziness', 'Bladder pain', 'Diarrhea', 'Lip swelling'],
    },
    {
      'name': 'Mirtazapine',
      'description': 'Mirtazapine is an antidepressant and is used primarily for the treatment of a major depressive disorder. Mirtazapine inhibits the central presynaptic adrenergic receptors which allows there to be an increased release of serotonin and norepinephrine in the brain.',
      'drug class': 'Tetracyclic antidepressants',
      'side effects': ['Dizziness', 'Xerostomia', 'Constipation', 'Drowsiness', 'Increased appetite', 'Nausea', 'Skin rash', 'Weight gain', 'Abnormal dreams'],
    },
    {
      'name': 'Molnupiravir (Lagevrio)',
      'description': 'Molnupiravir is used to combat mild/medium coronavirus disease. It is specifically for those who are not in the hospital and who are at high risks of severe covid-19. It is also for those who do not have access to the vaccination.  ',
      'drug class': 'Nucleoside',
      'side effects': ['Diarrhea', 'Headache', 'Hives, itching, skin rash', 'Nausea', 'Redness of the skin'],
    },
    {
      'name': 'Morphine',
      'description': 'Morphine is used to treat severe pain that is constant 24/7 for a long period of time. This is used when other medications were not enough.',
      'drug class': 'Narcotic analgesics',
      'side effects': ['Constipation','Feeling sick','Feeling sleepy', 'Vertigo', 'Confusion', 'Headaches', 'Itchy skin or a rash'],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },
    {
      'name': '',
      'description': '',
      'drug class': '',
      'side effects': [''],
    },





  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final medication = _searchResults.firstWhere(
          (item) => item['name']!.toLowerCase() == query.toLowerCase(),
      orElse: () => {
        'name': 'Not Found',
        'description': 'No details available.',
        'drug class': '',
        'side effects': [],
      },
    );

    return MedicationDetailPage(medication: medication);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? []
        : _searchResults.where((item) =>
        item['name']!.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final suggestionName = suggestionList[index]['name']!;
        final String resultDescription = suggestionList[index]['description']!;

        return ListTile(
          title: Text(suggestionName),
          onTap: () {
            query = suggestionName;
            showResults(context);
          },
        );
      },
    );
  }
}

class MedicationDetailPage extends StatelessWidget {
  final Map<String, dynamic> medication;

  const MedicationDetailPage({Key? key, required this.medication}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medication['name'] ?? 'Medication Details'),
        backgroundColor: Colors.blue.shade100,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medication['description'] ?? 'No description available.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.0),
            if (medication['drug class'] != null && medication['drug class']!.isNotEmpty)
              Text(
                'Drug Class: ${medication['drug class']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            SizedBox(height: 16.0),
            if (medication['side effects'] != null && (medication['side effects'] as List).isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Side Effects:',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8.0),
                  ..._buildSideEffectsList(medication['side effects'] as List<String>),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSideEffectsList(List<String> sideEffects) {
    return sideEffects.map((effect) =>
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.brightness_1, size: 7.0, color: Colors.black),
            SizedBox(width: 8.0),
            Expanded(child: Text(effect)),
          ],
        ),
    ).toList();
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.med,
  });

  final String med;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(med, style: style),
      ),
    );
  }
}

_AppointmentDataSource _getCalendarDataSource() {
  List<Appointment> appointments = <Appointment>[];
  appointments.add(Appointment(
    startTime: DateTime.now(),
    endTime: DateTime.now().add(Duration(minutes: 5)),
    subject: 'Take Medication',
    color: Colors.blue,
    startTimeZone: '',
    endTimeZone: '',
  ));

  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source){
    appointments = source;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  String getStartTimeZone(int index) {
    return appointments![index].startTimeZone;
  }

  @override
  String getEndTimeZone(int index) {
    return appointments![index].endTimeZone;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }
}