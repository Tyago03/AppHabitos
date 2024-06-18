import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Importação necessária para DateFormat

void main() {
  initializeDateFormatting('pt_BR', null).then((_) {
    runApp(MyApp());
  });
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
          labelStyle: TextStyle(color: Colors.black), // Estilo do rótulo quando em foco
        ),
      ),
      home: HabitList(),
    );
  }
}

class HabitList extends StatefulWidget {
  @override
  _HabitListState createState() => _HabitListState();
}

class _HabitListState extends State<HabitList> {
  final List<Habit> _habits = [];

  void _toggleCompleted(int index) {
    setState(() {
      _habits[index].isCompleted = !_habits[index].isCompleted;
    });
  }

  void _addHabit(Habit habit) {
    setState(() {
      _habits.add(habit);
      _habits.sort((a, b) => a.nextReminder.compareTo(b.nextReminder));
    });
  }

  void _editHabit(int index, Habit editedHabit) {
    setState(() {
      _habits[index] = editedHabit;
      _habits.sort((a, b) => a.nextReminder.compareTo(b.nextReminder));
    });
  }

  void _deleteHabit(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir este hábito?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _habits.removeAt(index);
                _habits.sort((a, b) => a.nextReminder.compareTo(b.nextReminder));
              });
              Navigator.of(ctx).pop();
            },
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoramento de Hábitos', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF50909a),
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
          : ListView.builder(
              itemCount: _habits.length,
              padding: EdgeInsets.only(bottom: 80.0), // Adiciona espaçamento inferior para rolagem extra
              itemBuilder: (context, index) {
                return HabitTile(
                  habit: _habits[index],
                  onToggleCompleted: () => _toggleCompleted(index),
                  onEdit: () async {
                    final editedHabit = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditHabitScreen(habit: _habits[index]),
                      ),
                    );
                    if (editedHabit != null && editedHabit is Habit) {
                      _editHabit(index, editedHabit);
                    }
                  },
                  onDelete: () => _deleteHabit(index),
                );
              },
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
        backgroundColor: Color(0xFF50909a),
      ),
      backgroundColor: Color(0xFFe6e6e6),
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
                      SizedBox(height: 8), // Espaçamento entre descrição e próxima data
                      Text(
                        'Próximo Lembrete: ${DateFormat('dd/MM/yyyy – HH:mm').format(widget.habit.nextReminder)}',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    widget.habit.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
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
                    label: Text('Editar', style: TextStyle(color: Colors.black)),
                  ),
                  TextButton.icon(
                    onPressed: widget.onDelete,
                    icon: Icon(Icons.delete, color: Colors.black),
                    label: Text('Excluir', style: TextStyle(color: Colors.black)),
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
  String? _reminderFrequency = 'Semanalmente';
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
           (_reminderFrequency == 'Semanalmente' ? _weekDaysSelected.contains(true) || _weekendSelected.contains(true) : _monthDaysSelected.contains(true));
  }

  DateTime _calculateNextReminder() {
    final now = DateTime.now();
    if (_reminderFrequency == 'Semanalmente') {
      for (int i = 0; i < 7; i++) {
        final day = now.add(Duration(days: i));
        if ((day.weekday <= 5 && _weekDaysSelected[day.weekday - 1]) || (day.weekday > 5 && _weekendSelected[day.weekday - 6])) {
          return DateTime(day.year, day.month, day.day, _reminderTime!.hour, _reminderTime!.minute);
        }
      }
    } else if (_reminderFrequency == 'Mensalmente') {
      final daysInMonth = DateUtils.getDaysInMonth(now.year, _selectedMonth);
      for (int i = 0; i < daysInMonth; i++) {
        final day = DateTime(now.year, _selectedMonth, i + 1);
        if (_monthDaysSelected[i]) {
          return DateTime(day.year, day.month, day.day, _reminderTime!.hour, _reminderTime!.minute);
        }
      }
    }
    return now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Hábito', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF50909a),
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
                  borderSide: BorderSide(color: Colors.black), // Cor da borda ao focar
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Cor da borda quando não está em foco
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
                  borderSide: BorderSide(color: Colors.black), // Cor da borda ao focar
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Cor da borda quando não está em foco
                ),
              ),
              cursorColor: Colors.black, // Cor do cursor
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(_reminderTime != null ? _reminderTime!.format(context) : 'Selecionar Horário'),
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
              items: <String>['Semanalmente', 'Mensalmente']
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
                          DateUtils.getDaysInMonth(DateTime.now().year, _selectedMonth),
                          (_) => false,
                        );
                      });
                    },
                    items: List.generate(12, (index) {
                      final month = DateFormat.MMMM('pt_BR').format(DateTime(0, index + 1));
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(month),
                      );
                    }),
                  ),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                    itemCount: DateUtils.getDaysInMonth(DateTime.now().year, _selectedMonth),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _monthDaysSelected[index] = !_monthDaysSelected[index];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _monthDaysSelected[index] ? Colors.blue : Colors.transparent,
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
                    child: Text('Cancelar', style: TextStyle(color: Color(0xFFFF6961))),
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
                            content: Text('Por favor, preencha todos os campos obrigatórios.'),
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
                    child: Text('Salvar', style: TextStyle(color: Colors.white)),
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
    _descriptionController = TextEditingController(text: widget.habit.description);
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
           (_reminderFrequency == 'Semanalmente' ? _weekDaysSelected.contains(true) || _weekendSelected.contains(true) : _monthDaysSelected.contains(true));
  }

  DateTime _calculateNextReminder() {
    final now = DateTime.now();
    if (_reminderFrequency == 'Semanalmente') {
      for (int i = 0; i < 7; i++) {
        final day = now.add(Duration(days: i));
        if ((day.weekday <= 5 && _weekDaysSelected[day.weekday - 1]) || (day.weekday > 5 && _weekendSelected[day.weekday - 6])) {
          return DateTime(day.year, day.month, day.day, _reminderTime!.hour, _reminderTime!.minute);
        }
      }
    } else if (_reminderFrequency == 'Mensalmente') {
      final daysInMonth = DateUtils.getDaysInMonth(now.year, _selectedMonth);
      for (int i = 0; i < daysInMonth; i++) {
        final day = DateTime(now.year, _selectedMonth, i + 1);
        if (_monthDaysSelected[i]) {
          return DateTime(day.year, day.month, day.day, _reminderTime!.hour, _reminderTime!.minute);
        }
      }
    }
    return now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Hábito', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
        backgroundColor: Color(0xFF50909a),
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
                  borderSide: BorderSide(color: Colors.black), // Cor da borda ao focar
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Cor da borda quando não está em foco
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
                  borderSide: BorderSide(color: Colors.black), // Cor da borda ao focar
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // Cor da borda quando não está em foco
                ),
              ),
              cursorColor: Colors.black, // Cor do cursor
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ListTile(
              title: Text(_reminderTime != null ? _reminderTime!.format(context) : 'Selecionar Horário'),
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
              items: <String>['Semanalmente', 'Mensalmente']
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
                          DateUtils.getDaysInMonth(DateTime.now().year, _selectedMonth),
                          (_) => false,
                        );
                      });
                    },
                    items: List.generate(12, (index) {
                      final month = DateFormat.MMMM('pt_BR').format(DateTime(0, index + 1));
                      return DropdownMenuItem<int>(
                        value: index + 1,
                        child: Text(month),
                      );
                    }),
                  ),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
                    itemCount: DateUtils.getDaysInMonth(DateTime.now().year, _selectedMonth),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _monthDaysSelected[index] = !_monthDaysSelected[index];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: _monthDaysSelected[index] ? Colors.blue : Colors.transparent,
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
                    child: Text('Cancelar', style: TextStyle(color: Color(0xFFFF6961))),
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
                            content: Text('Por favor, preencha todos os campos obrigatórios.'),
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
                    child: Text('Salvar', style: TextStyle(color: Colors.white)),
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
}
