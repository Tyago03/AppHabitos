import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(MyApp());
  });

  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      // Handle your notification response here
    },
  );

  await _checkAndRequestExactAlarmPermission(); // Verifica e solicita a permissão para alarmes exatos
}

Future<void> _checkAndRequestExactAlarmPermission() async {
  if (await Permission.systemAlertWindow.isDenied) {
    await openAppSettings();
  }

  if (await Permission.scheduleExactAlarm.isDenied) {
    await Permission.scheduleExactAlarm.request();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HábitoHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          labelStyle: TextStyle(color: Colors.black),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF6d0d8d),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              cursorColor: Colors.black,
              obscureText: _obscureText,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                } catch (e) {
                  print("Failed to sign in: $e");
                }
              },
              child: Text('Login', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6d0d8d),
                padding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Cadastro', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6d0d8d),
                padding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFe6e6e6),
    );
  }
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF50909a),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              cursorColor: Colors.black,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Senha',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              cursorColor: Colors.black,
              obscureText: _obscureText,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirmar Senha',
                labelStyle: TextStyle(color: Colors.black),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              cursorColor: Colors.black,
              obscureText: _obscureText,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_passwordController.text ==
                    _confirmPasswordController.text) {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text);
                    Navigator.pop(context);
                  } catch (e) {
                    print("Failed to register: $e");
                  }
                } else {
                  print("Passwords do not match");
                }
              },
              child: Text('Registrar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF50909a),
                padding: EdgeInsets.symmetric(vertical: 15.0),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFe6e6e6),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  final GlobalKey<HabitListState> _habitListKey = GlobalKey<HabitListState>();

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HabitList(key: _habitListKey),
      TodayHabits(),
      HabitStatistics(),
      ProfilePage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Hoje',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Estatísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF480044),
        unselectedItemColor: Color(0xFF6d0d8d),
        onTap: _onItemTapped,
      ),
    );
  }
}

class HabitList extends StatefulWidget {
  const HabitList({Key? key}) : super(key: key);

  @override
  HabitListState createState() => HabitListState();
}

class HabitListState extends State<HabitList> {
  final List<Habit> _habits = [];
  final List<Item> _data = generateItems(3); // Inicializa as seções como abertas

  @override
  void initState() {
    super.initState();
    _fetchHabits();
  }

  Future<void> _fetchHabits() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      _habits.addAll(snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return Habit.fromMap(data, doc.id);
      }).toList());
    });
  }

  void _toggleCompleted(int index) {
    setState(() {
      _habits[index].isCompleted = !_habits[index].isCompleted;
    });
  }

  Future<void> _addHabit(Habit habit) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('habits')
        .add(habit.toMap(userId));

    setState(() {
      habit.id = docRef.id;
      _habits.add(habit);
      _habits.sort((a, b) => a.nextReminder.compareTo(b.nextReminder));
    });

    _scheduleNotification(habit);
  }

  Future<void> _editHabit(int index, Habit editedHabit) async {
    if (editedHabit.id != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection('habits')
          .doc(editedHabit.id)
          .update(editedHabit.toMap(userId));

      setState(() {
        _habits[index] = editedHabit;
        _habits.sort((a, b) => a.nextReminder.compareTo(b.nextReminder));
      });

      _scheduleNotification(editedHabit);
    } else {
      print('Habit ID is null');
    }
  }

  Future<void> _deleteHabit(int index) async {
    String habitId = _habits[index].id!;
    await FirebaseFirestore.instance.collection('habits').doc(habitId).delete();

    setState(() {
      _habits.removeAt(index);
      _habits.sort((a, b) => a.nextReminder.compareTo(b.nextReminder));
    });
  }

  List<Habit> get _dailyHabits => _habits
      .where((habit) => habit.reminderFrequency == 'Diariamente')
      .toList();
  List<Habit> get _weeklyHabits => _habits
      .where((habit) => habit.reminderFrequency == 'Semanalmente')
      .toList();
  List<Habit> get _monthlyHabits => _habits
      .where((habit) => habit.reminderFrequency == 'Mensalmente')
      .toList();

  Future<void> _scheduleNotification(Habit habit) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'habit_channel',
      'Habit Notifications',
      channelDescription: 'Channel for habit reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      habit.id.hashCode,
      'Lembrete de Hábito',
      habit.title,
      tz.TZDateTime.from(habit.nextReminder, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoramento de Hábitos',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF6d0d8d),
        centerTitle: true,
      ),
      body: _habits.isEmpty
          ? Center(
              child: Text(
                'Você ainda não tem nenhum hábito adicionado.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0), // Adiciona espaço inferior
                child: Column(
                  children: _data.map<Widget>((Item item) {
                    return _buildHabitCategory(item);
                  }).toList(),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddHabitScreen()),
          );
          if (result != null && result is Habit) {
            _addHabit(result);
          }
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFF6d0d8d),
      ),
      backgroundColor: Color(0xFFe6e6e6),
    );
  }

  Widget _buildHabitCategory(Item item) {
    final habitsList = item.headerValue == 'Diários'
        ? _dailyHabits
        : item.headerValue == 'Semanais'
            ? _weeklyHabits
            : _monthlyHabits;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15), // Borda arredondada
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            ListTile(
              title: Text(
                item.headerValue,
                style: GoogleFonts.indieFlower(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Column(
              children: habitsList
                  .asMap()
                  .entries
                  .map(
                    (entry) => HabitTile(
                      habit: entry.value,
                      onToggleCompleted: () => _toggleCompleted(entry.key),
                      onEdit: () async {
                        final editedHabit = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditHabitScreen(habit: entry.value),
                          ),
                        );
                        if (editedHabit != null && editedHabit is Habit) {
                          _editHabit(entry.key, editedHabit);
                        }
                      },
                      onDelete: () => _deleteHabit(entry.key),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}



class Item {
  Item({
    required this.headerValue,
    this.isExpanded = true,
  });

  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int numberOfItems) {
  return List<Item>.generate(numberOfItems, (int index) {
    return Item(
      headerValue: index == 0
          ? 'Diários'
          : index == 1
              ? 'Semanais'
              : 'Mensais',
    );
  });
}

class HabitCategory extends StatelessWidget {
  final String title;
  final List<Habit> habits;
  final Function(int) toggleCompleted;
  final Function(int, Habit) editHabit;
  final Function(int) deleteHabit;

  HabitCategory({
    required this.title,
    required this.habits,
    required this.toggleCompleted,
    required this.editHabit,
    required this.deleteHabit,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      children: habits
          .asMap()
          .entries
          .map(
            (entry) => HabitTile(
              habit: entry.value,
              onToggleCompleted: () => toggleCompleted(entry.key),
              onEdit: () async {
                final editedHabit = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditHabitScreen(habit: entry.value),
                  ),
                );
                if (editedHabit != null && editedHabit is Habit) {
                  editHabit(entry.key, editedHabit);
                }
              },
              onDelete: () => deleteHabit(entry.key),
            ),
          )
          .toList(),
    );
  }
}

class HabitTile extends StatefulWidget {
  final Habit habit;
  final VoidCallback onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  HabitTile({
    required this.habit,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _HabitTileState createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  bool _expanded = false;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: widget.habit.color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    _expanded ? Icons.expand_more : Icons.chevron_right,
                    size: 24,
                    color: Colors.black,
                  ),
                  onPressed: _toggleExpand,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.habit.title,
                        style: GoogleFonts.indieFlower(
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (widget.habit.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            widget.habit.description,
                            style: GoogleFonts.indieFlower(
                              textStyle: TextStyle(
                                fontSize: 16, // Fonte da descrição aumentada
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                          height:
                              8), // Espaçamento entre descrição e próxima data
                      Text(
                        'Próximo Lembrete: ${DateFormat('dd/MM/yyyy – HH:mm').format(widget.habit.nextReminder)}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.habit.isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: widget.onToggleCompleted,
                ),
              ],
            ),
            if (_expanded)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: widget.onEdit,
                    icon: Icon(Icons.more_horiz, color: Colors.black),
                    label:
                        Text('Editar', style: TextStyle(color: Colors.black)),
                  ),
                  TextButton.icon(
                    onPressed: widget.onDelete,
                    icon: Icon(Icons.delete, color: Colors.black),
                    label:
                        Text('Excluir', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _reminderFrequency = 'Diariamente';
  TimeOfDay? _reminderTime;
  Color? _selectedColor = Colors.white;
  List<bool> _weekDaysSelected = List.generate(5, (_) => false);
  List<bool> _weekendSelected = List.generate(2, (_) => false);
  List<bool> _monthDaysSelected = List.generate(31, (_) => false);
  int _selectedMonth = DateTime.now().month;

  void _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _reminderTime = time;
      });
    }
  }

  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
        _reminderTime != null &&
        _reminderFrequency != null &&
        (_reminderFrequency == 'Diariamente' ||
            (_reminderFrequency == 'Semanalmente'
                ? _weekDaysSelected.contains(true) ||
                    _weekendSelected.contains(true)
                : _monthDaysSelected.contains(true)));
  }

  DateTime _calculateNextReminder() {
    final now = DateTime.now();
    if (_reminderFrequency == 'Diariamente') {
      return DateTime(now.year, now.month, now.day, _reminderTime!.hour,
              _reminderTime!.minute)
          .add(Duration(days: 1));
    } else if (_reminderFrequency == 'Semanalmente') {
      for (int i = 0; i < 7; i++) {
        final day = now.add(Duration(days: i));
        if ((day.weekday <= 5 && _weekDaysSelected[day.weekday - 1]) ||
            (day.weekday > 5 && _weekendSelected[day.weekday - 6])) {
          return DateTime(day.year, day.month, day.day, _reminderTime!.hour,
              _reminderTime!.minute);
        }
      }
    } else if (_reminderFrequency == 'Mensalmente') {
      final daysInMonth = DateUtils.getDaysInMonth(now.year, _selectedMonth);
      for (int i = 0; i < daysInMonth; i++) {
        final day = DateTime(now.year, _selectedMonth, i + 1);
        if (_monthDaysSelected[i]) {
          return DateTime(day.year, day.month, day.day, _reminderTime!.hour,
              _reminderTime!.minute);
        }
      }
    }
    return now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Hábito',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF6d0d8d),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Hábito',
                labelStyle: TextStyle(color: Colors.black), // Estilo do rótulo
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.black), // Cor da borda ao focar
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.black), // Cor da borda quando não está em foco
                ),
              ),
              cursorColor: Colors.black, // Cor do cursor
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição do Hábito',
                labelStyle: TextStyle(color: Colors.black), // Estilo do rótulo
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.black), // Cor da borda ao focar
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.black), // Cor da borda quando não está em foco
                ),
              ),
              cursorColor: Colors.black, // Cor do cursor
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(_reminderTime != null
                  ? _reminderTime!.format(context)
                  : 'Selecionar Horário'),
              trailing: Icon(Icons.timer),
              onTap: _pickTime,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: <Color>[
                Colors.white,
                Colors.lightBlueAccent,
                Colors.lightGreenAccent,
                const Color(0xFFf87764),
                Colors.yellowAccent
              ].map((Color color) {
                return ChoiceChip(
                  label: Text(' '),
                  selected: _selectedColor == color,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  backgroundColor: color,
                  selectedColor: color,
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _reminderFrequency,
              hint: Text('Frequência do Lembrete'),
              onChanged: (String? newValue) {
                setState(() {
                  _reminderFrequency = newValue;
                });
              },
              items: <String>['Diariamente', 'Semanalmente', 'Mensalmente']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            if (_reminderFrequency == 'Mensalmente')
              Column(
                children: [
                  DropdownButton<int>(
                    value: _selectedMonth,
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedMonth = newValue!;
                        _monthDaysSelected = List.generate(
                          DateUtils.getDaysInMonth(
                              DateTime.now().year, _selectedMonth),
                          (_) => false,
                        );
                      });
                    },
                    items: List.generate(12, (index) {
                      final month = DateFormat.MMMM('pt_BR')
                          .format(DateTime(0, index + 1));
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(month),
                      );
                    }),
                  ),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7),
                    itemCount: DateUtils.getDaysInMonth(
                        DateTime.now().year, _selectedMonth),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _monthDaysSelected[index] =
                                !_monthDaysSelected[index];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _monthDaysSelected[index]
                                ? Colors.blue
                                : Colors.transparent,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Center(child: Text('${index + 1}')),
                        ),
                      );
                    },
                  ),
                ],
              ),
            if (_reminderFrequency == 'Semanalmente')
              Column(
                children: [
                  ToggleButtons(
                    children: <Widget>[
                      for (var day in ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'])
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(day),
                        ),
                    ],
                    isSelected: _weekDaysSelected,
                    onPressed: (int index) {
                      setState(() {
                        _weekDaysSelected[index] = !_weekDaysSelected[index];
                      });
                    },
                  ),
                  ToggleButtons(
                    children: <Widget>[
                      for (var day in ['Sab', 'Dom'])
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(day),
                        ),
                    ],
                    isSelected: _weekendSelected,
                    onPressed: (int index) {
                      setState(() {
                        _weekendSelected[index] = !_weekendSelected[index];
                      });
                    },
                  ),
                ],
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar',
                        style: TextStyle(color: Color(0xFFFF6961))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFe6e6e6),
                      foregroundColor: Color(0xFFFF6961),
                      side: BorderSide(color: Color(0xFFFF6961), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isFormValid()) {
                        final newHabit = Habit(
                          title: _nameController.text,
                          description: _descriptionController.text,
                          reminderTime: _reminderTime!,
                          reminderFrequency: _reminderFrequency!,
                          color: _selectedColor!,
                          weekDays: _weekDaysSelected,
                          weekendDays: _weekendSelected,
                          monthDays: _monthDaysSelected,
                          nextReminder: _calculateNextReminder(),
                        );
                        Navigator.pop(context, newHabit);
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Erro'),
                            content: Text(
                                'Por favor, preencha todos os campos obrigatórios.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child:
                        Text('Salvar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8bc34a),
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFe6e6e6),
    );
  }
}

class EditHabitScreen extends StatefulWidget {
  final Habit habit;

  EditHabitScreen({required this.habit});

  @override
  _EditHabitScreenState createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String? _reminderFrequency;
  late TimeOfDay? _reminderTime;
  late Color? _selectedColor;
  late List<bool> _weekDaysSelected;
  late List<bool> _weekendSelected;
  late List<bool> _monthDaysSelected;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.habit.title);
    _descriptionController =
        TextEditingController(text: widget.habit.description);
    _reminderFrequency = widget.habit.reminderFrequency;
    _reminderTime = widget.habit.reminderTime;
    _selectedColor = widget.habit.color;
    _weekDaysSelected = List<bool>.from(widget.habit.weekDays);
    _weekendSelected = List<bool>.from(widget.habit.weekendDays);
    _monthDaysSelected = List<bool>.from(widget.habit.monthDays);
    _selectedMonth = DateTime.now().month;
  }

  void _pickTime() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState(() {
        _reminderTime = time;
      });
    }
  }

  bool _isFormValid() {
    return _nameController.text.isNotEmpty &&
        _reminderTime != null &&
        _reminderFrequency != null &&
        (_reminderFrequency == 'Diariamente' ||
            (_reminderFrequency == 'Semanalmente'
                ? _weekDaysSelected.contains(true) ||
                    _weekendSelected.contains(true)
                : _monthDaysSelected.contains(true)));
  }

  DateTime _calculateNextReminder() {
    final now = DateTime.now();
    if (_reminderFrequency == 'Diariamente') {
      return DateTime(now.year, now.month, now.day, _reminderTime!.hour,
              _reminderTime!.minute)
          .add(Duration(days: 1));
    } else if (_reminderFrequency == 'Semanalmente') {
      for (int i = 0; i < 7; i++) {
        final day = now.add(Duration(days: i));
        if ((day.weekday <= 5 && _weekDaysSelected[day.weekday - 1]) ||
            (day.weekday > 5 && _weekendSelected[day.weekday - 6])) {
          return DateTime(day.year, day.month, day.day, _reminderTime!.hour,
              _reminderTime!.minute);
        }
      }
    } else if (_reminderFrequency == 'Mensalmente') {
      final daysInMonth = DateUtils.getDaysInMonth(now.year, _selectedMonth);
      for (int i = 0; i < daysInMonth; i++) {
        final day = DateTime(now.year, _selectedMonth, i + 1);
        if (_monthDaysSelected[i]) {
          return DateTime(day.year, day.month, day.day, _reminderTime!.hour,
              _reminderTime!.minute);
        }
      }
    }
    return now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Hábito',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF6d0d8d),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome do Hábito',
                labelStyle: TextStyle(color: Colors.black), // Estilo do rótulo
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.black), // Cor da borda ao focar
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.black), // Cor da borda quando não está em foco
                ),
              ),
              cursorColor: Colors.black, // Cor do cursor
              textCapitalization: TextCapitalization.sentences,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição do Hábito',
                labelStyle: TextStyle(color: Colors.black), // Estilo do rótulo
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.black), // Cor da borda ao focar
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.black), // Cor da borda quando não está em foco
                ),
              ),
              cursorColor: Colors.black, // Cor do cursor
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(_reminderTime != null
                  ? _reminderTime!.format(context)
                  : 'Selecionar Horário'),
              trailing: Icon(Icons.timer),
              onTap: _pickTime,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: <Color>[
                Colors.white,
                Colors.lightBlueAccent,
                Colors.lightGreenAccent,
                const Color(0xFFf87764),
                Colors.yellowAccent
              ].map((Color color) {
                return ChoiceChip(
                  label: Text(' '),
                  selected: _selectedColor == color,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  backgroundColor: color,
                  selectedColor: color,
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: _reminderFrequency,
              hint: Text('Frequência do Lembrete'),
              onChanged: (String? newValue) {
                setState(() {
                  _reminderFrequency = newValue;
                });
              },
              items: <String>['Diariamente', 'Semanalmente', 'Mensalmente']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            if (_reminderFrequency == 'Mensalmente')
              Column(
                children: [
                  DropdownButton<int>(
                    value: _selectedMonth,
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedMonth = newValue!;
                        _monthDaysSelected = List.generate(
                          DateUtils.getDaysInMonth(
                              DateTime.now().year, _selectedMonth),
                          (_) => false,
                        );
                      });
                    },
                    items: List.generate(12, (index) {
                      final month = DateFormat.MMMM('pt_BR')
                          .format(DateTime(0, index + 1));
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(month),
                      );
                    }),
                  ),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7),
                    itemCount: DateUtils.getDaysInMonth(
                        DateTime.now().year, _selectedMonth),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _monthDaysSelected[index] =
                                !_monthDaysSelected[index];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _monthDaysSelected[index]
                                ? Colors.blue
                                : Colors.transparent,
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Center(child: Text('${index + 1}')),
                        ),
                      );
                    },
                  ),
                ],
              ),
            if (_reminderFrequency == 'Semanalmente')
              Column(
                children: [
                  ToggleButtons(
                    children: <Widget>[
                      for (var day in ['Seg', 'Ter', 'Qua', 'Qui', 'Sex'])
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(day),
                        ),
                    ],
                    isSelected: _weekDaysSelected,
                    onPressed: (int index) {
                      setState(() {
                        _weekDaysSelected[index] = !_weekDaysSelected[index];
                      });
                    },
                  ),
                  ToggleButtons(
                    children: <Widget>[
                      for (var day in ['Sab', 'Dom'])
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(day),
                        ),
                    ],
                    isSelected: _weekendSelected,
                    onPressed: (int index) {
                      setState(() {
                        _weekendSelected[index] = !_weekendSelected[index];
                      });
                    },
                  ),
                ],
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancelar',
                        style: TextStyle(color: Color(0xFFFF6961))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFe6e6e6),
                      foregroundColor: Color(0xFFFF6961),
                      side: BorderSide(color: Color(0xFFFF6961), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isFormValid()) {
                        final editedHabit = Habit(
                          id: widget.habit.id, // Certifique-se de manter o ID
                          title: _nameController.text,
                          description: _descriptionController.text,
                          reminderTime: _reminderTime!,
                          reminderFrequency: _reminderFrequency!,
                          color: _selectedColor!,
                          weekDays: _weekDaysSelected,
                          weekendDays: _weekendSelected,
                          monthDays: _monthDaysSelected,
                          nextReminder: _calculateNextReminder(),
                        );
                        Navigator.pop(context, editedHabit);
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Erro'),
                            content: Text(
                                'Por favor, preencha todos os campos obrigatórios.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child:
                        Text('Salvar', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8bc34a),
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFe6e6e6),
    );
  }
}

class Habit {
  String? id;
  final String title;
  final String description;
  final TimeOfDay reminderTime;
  final String reminderFrequency;
  final Color color;
  final List<bool> weekDays;
  final List<bool> weekendDays;
  final List<bool> monthDays;
  final DateTime nextReminder;
  bool isCompleted;

  Habit({
    this.id,
    required this.title,
    required this.description,
    required this.reminderTime,
    required this.reminderFrequency,
    required this.color,
    required this.weekDays,
    required this.weekendDays,
    required this.monthDays,
    required this.nextReminder,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'reminderTime': reminderTime.formatTime(), // Converte para string
      'reminderFrequency': reminderFrequency,
      'color': color.value,
      'weekDays': weekDays,
      'weekendDays': weekendDays,
      'monthDays': monthDays,
      'nextReminder': nextReminder,
      'isCompleted': isCompleted,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map, String id) {
    return Habit(
      id: id,
      title: map['title'],
      description: map['description'],
      reminderTime: _parseTimeOfDay(
          map['reminderTime']), // Converte de string para TimeOfDay
      reminderFrequency: map['reminderFrequency'],
      color: Color(map['color']),
      weekDays: List<bool>.from(map['weekDays']),
      weekendDays: List<bool>.from(map['weekendDays']),
      monthDays: List<bool>.from(map['monthDays']),
      nextReminder: (map['nextReminder'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'],
    );
  }

  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}

extension TimeOfDayExtension on TimeOfDay {
  String formatTime() {
    final hourString = hour.toString().padLeft(2, '0');
    final minuteString = minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString';
  }
}

class TodayHabits extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hábitos de Hoje',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF6d0d8d),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Aqui serão exibidos os hábitos que você deve cumprir hoje.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: Color(0xFFe6e6e6),
    );
  }
}

class HabitStatistics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estatísticas de Hábitos',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF6d0d8d),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'Aqui serão exibidas as estatísticas dos seus hábitos.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
      backgroundColor: Color(0xFFe6e6e6),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF6d0d8d),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Aqui serão exibidas as informações do seu perfil.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Logout', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6d0d8d),
                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFFe6e6e6),
    );
  }
}
