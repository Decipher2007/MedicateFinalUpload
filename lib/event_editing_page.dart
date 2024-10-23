import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'utils.dart';
import 'event.dart';
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

class EventEditingPage extends StatefulWidget{
  final Event? event;

  const EventEditingPage({
    Key? key,
    this.event,
  }) : super(key: key);

  @override
  _EventEditingPageState createState() => _EventEditingPageState();
}

class _EventEditingPageState extends State<EventEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  late DateTime fromDate;
  late DateTime toDate;

  List<String> allOptions = [
    'Aciclovir (Zovirax)',
    'Acrivastine',
    'Adderall',
    'Adalimumab',
    'Adderall',
    'Albuterol',
    'Allopurinol',
    'Alogliptin',
    'Amlodipine',
    'Amoxicillin',
    'Anastrozole',
    'Antidepressants',
    'Apixaban',
    'Aripiprazole',
    'Aspirin',
    'Atenolol',
    'Atorvastatin',
    'Azathioprine',
    'Azithromycin',
    'Baclofen',
    'Bendroflumethiazide',
    'Benzoyl Peroxide',
    'Benzydamine',
    'Betahistine',
    'Bimatoprost',
    'Bisacodyl',
    'Bisoprolol',
    'Brinzolamide',
    'Bumetanide',
    'Buprenorphine',
    'Buscopan (Hyoscine Butylbromide)',
    'Calcipotriol',
    'Candesartan',
    'Carbamazepine',
    'Carbimazole',
    'Carbocisteine',
    'Carvedilol',
    'Cefalexin',
    'Cetirizine',
    'Champix (varenicline)',
    'Chloramphenicol',
    'Chlorhexidine',
    'Chlorphenamine (Piriton)',
    'Cinnarizine',
    'Ciprofloxacin',
    'Citalopram',
    'Clarithromycin',
    'Clobetasol',
    'Clonazepam',
    'Clonidine',
    'Clopidogrel',
    'Co-dydramol',
    'Codeine',
    'Colchicine',
    'Colecalciferol',
    'Cyanocobalamin',
    'Cyclizine',
    'Dabigatran',
    'Dapagliflozin',
    'Diazepam',
    'Diclofenac',
    'Diphenhydramine',
    'Dipyridamole',
    'Docusate',
    'Domperidone',
    'Donepezil',
    'Dosulepin',
    'Doxazosin',
    'Doxycycline',
    'Empagliflozin',
    'Enalapril',
    'Eplerenone',
    'Erythromycin',
    'Escitalopram',
    'Esomeprazole',
    'Ezetimibe',
    'Felodipine',
    'Fexofenadine',
    'Flucloxacillin',
    'Fluconazole',
    'Fluoxetine (Prozac)',
    'Folic Acid',
    'Furosemide',
    'Fusidic Acid',
    'Gabapentin',
    'Gaviscon (alginic acid)',
    'Gliclazide',
    'Glimepiride',
    'Haloperidol',
    'Heparinoid',
    'Hydroxocobalamin',
    'Ibuprofen',
    'Indapamide',
    'Insulin',
    'Irbesartan',
    'Labetalol',
    'Lactulose',
    'Lansoprazole',
    'Letrozole',
    'Levothyroxine',
    'Lidocaine',
    'Linagliptin',
    'Lisinopril',
    'Lorazepam',
    'Lymecycline',
    'Macrogol',
    'Mebendazole',
    'Mebeverine',
    'Medroxyprogesterone Tablets',
    'Melatonin',
    'Metformin',
    'Methadone',
    'Methotrexate',
    'Metoprolol',
    'Metronidazole',
    'Mirabegron',
    'Mirtazapine',
    'Molnupiravir (Lagevrio)',
    'Morphine',
    'Naproxen',
    'Nefopam',
    'Nicorandil',
    'Nifedipine',
    'Nitrofurantoin',
    'Nortriptyline',
    'Oestrogen',
    'Olanzapine',
    'Oxybutynin',
    'Oxycodone',
    'Paroxetine',
    'Paxlovid',
    'Pepto-Bismol (bismuth subsalicylate)',
    'Perindopril',
    'Phenoxymethylpenicillin',
    'Phenytoin',
    'Pioglitazone',
    'Pravastatin',
    'Pre-Exposure Prophylaxis (PrEP)',
    'Pregabalin',
    'Prochlorperazine',
    'Promethazine (Phenergan)',
    'Propranolol',
    'Pseudoephedrine (Sudafed)',
    'Quetiapine',
    'Rabeprazole',
    'Ramipril',
    'Ranitidine',
    'Risedronate',
    'Risperidone',
    'Rivaroxaban',
    'Ropinirole',
    'Rosuvastatin',
    'Salbutamol inhaler',
    'Saxagliptin',
    'Senna',
    'Sertraline',
    'Sildenafil (Viagra)',
    'Simeticone',
    'Simvastatin',
    'Sitagliptin',
    'Sodium cromoglicate',
    'Sodium Valproate',
    'Solifenacin',
    'Sotalol',
    'Sotrovimab (Xevudy)',
    'Spironolactone',
    'Sulfasalazine',
    'Sumatriptan',
    'Tadalafil',
    'Tamsulosin',
    'Temazepam',
    'Terbinafine',
    'Thiamine (vitamin B1)',
    'Tibolone',
    'Ticagrelor',
    'Timolol',
    'Tiotropium inhalers',
    'Tolterodine',
    'Topiramate',
    'Tramadol',
    'Tranexamic acid',
    'Trastuzumab (Herceptin)',
    'Trazodone',
    'Trimethoprim',
    'Tylenol',
    'Utrogestan (micronised progesterone)',
    'Valproic acid',
    'Valsartan',
    'Varenicline',
    'Venlafaxine',
    'Verapamil',
    'Warfarin',
    'Zolpidem',
    'Zopiclone',

  ];
  List<String> filteredOptions = [];

  @override
  void initState() {
    super.initState();
    if (widget.event == null) {
      fromDate = DateTime.now();
      toDate = DateTime.now().add(Duration(minutes: 5));
    }
    filteredOptions = allOptions; // Initialize filtered options
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  void filterOptions(String query) {
    final filtered = allOptions
        .where((option) => option.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredOptions = filtered;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        actions: buildEditingActions(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              buildTitle(),
              SizedBox(height: 12),
              buildDateTimePickers(), // Ensure you implement this method
              buildDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildEditingActions() => [
    ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      onPressed: saveForm,
      icon: Icon(Icons.done),
      label: Text('Save'),
    )
  ];

  Widget buildTitle() {
    return TextFormField(
      controller: titleController,
      style: TextStyle(fontSize: 24),
      decoration: InputDecoration(
        border: UnderlineInputBorder(),
        hintText: 'Type Medication Name',
      ),
      onChanged: filterOptions,
      onFieldSubmitted: (_) => saveForm(),
      validator: (title) =>
      title != null && title.isEmpty ? 'Title cannot be empty' : null,
    );
  }

  Widget buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align text to the start
      children: [
        SizedBox(height:8),
        Text(
          'Select Medication (click on medication name or type at top):',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Customize style as needed
        ),
        SizedBox(height: 8), // Add some space between the text and dropdown
        ListView.builder(
          shrinkWrap: true, // Ensures the ListView does not take unlimited height
          physics: NeverScrollableScrollPhysics(), // Prevents scrolling the dropdown
          itemCount: filteredOptions.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(filteredOptions[index]),
              onTap: () {
                titleController.text = filteredOptions[index];
                // Clear the options list if you select an item
                setState(() {
                  filteredOptions = [];
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget buildDateTimePickers() => Column(
    children: [
      buildFrom(),
      buildTo(),
    ],
  );

  Widget buildFrom() => buildHeader(
    header: 'FROM',
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: buildDropdownField(
            text: Utils.toDate(fromDate),
            onClicked: () => pickFromDateTime(pickDate: true),
          ),
        ),
        Expanded(
          child: buildDropdownField(
            text: Utils.toTime(fromDate),
            onClicked: () => pickFromDateTime(pickDate: false),
          ),
        ),
      ],
    ),
  );

  Widget buildTo() => buildHeader(
    header: 'TO',
    child: Row(
      children: [
        Expanded(
          flex: 2,
          child: buildDropdownField(
            text: Utils.toDate(toDate),
            onClicked: () => pickToDateTime(pickDate: true),
          ),
        ),
        Expanded(
          child: buildDropdownField(
            text: Utils.toTime(toDate),
            onClicked: () => pickToDateTime(pickDate: false),
          ),
        ),
      ],
    ),
  );

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if (date == null) return;

    if (date.isAfter(toDate)) {
      toDate = DateTime(date.year, date.month, date.day, toDate.hour, toDate.minute);
    }

    setState(() => fromDate = date);
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(
      toDate,
      pickDate: pickDate,
      firstDate: pickDate ? fromDate: null,
    );
    if (date == null) return;

    setState(() => toDate = date);
  }

  Future<DateTime?> pickDateTime(
      DateTime initialDate, {
        required bool pickDate,
        DateTime? firstDate,
      }) async {
    if (pickDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime(2015,8),
        lastDate: DateTime(2101),
      );

      if (date == null) return null;

      final time = Duration(hours: initialDate.hour, minutes: initialDate.minute);

      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (timeOfDay == null) return null;

      final date = DateTime(initialDate.year, initialDate.month, initialDate.day);
      final time = Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);

      return date.add(time);
    }
  }

  Widget buildDropdownField({
    required String text,
    required VoidCallback onClicked,
  }) =>
      ListTile(
        title: Text(text),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  Widget buildHeader({
    required String header,
    required Widget child,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: TextStyle(fontWeight: FontWeight.bold)),
          child,
        ],
      );

  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final event = Event(
        title: titleController.text,
        description: 'Description',
        from: fromDate,
        to: toDate,
        isAllDay: false,
      );

      //listen: true caused an error
      final provider = Provider.of<MyAppState>(context, listen: false);
      provider.addEvent(event);
      User user = FirebaseAuth.instance.currentUser!;
      var db = FirebaseFirestore.instance;

      await db.collection('Users').doc(user.uid).collection('Events').add({
        "name": titleController.text,
        "from": fromDate,
        "to": toDate,
        "isAllDay": false,
        "description": "No Description"
      });



      Navigator.of(context).pop();
    }
  }
}