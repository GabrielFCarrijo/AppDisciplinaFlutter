import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de Média',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'Calculadora de Média'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _disciplinaController = TextEditingController();
  final TextEditingController _alunoController = TextEditingController();
  final TextEditingController _notaController = TextEditingController();
  Map<String, Map<String, List<double>>> _disciplinas = {};

  void _adicionarAlunoENota() {
    final String disciplina = _disciplinaController.text;
    final String aluno = _alunoController.text;
    final double nota = double.tryParse(_notaController.text) ?? 0;

    setState(() {
      if (_disciplinas.containsKey(disciplina)) {
        if (_disciplinas[disciplina]!.containsKey(aluno)) {
          _disciplinas[disciplina]![aluno]!.add(nota);
        } else {
          _disciplinas[disciplina]![aluno] = [nota];
        }
      } else {
        _disciplinas[disciplina] = {aluno: [nota]};
      }
    });

    _alunoController.clear();
    _notaController.clear();
  }

  void _editarNotas(String disciplina, String aluno) {
    _notaController.text = _disciplinas[disciplina]![aluno]![0].toString();
    _alunoController.text = aluno;
    _disciplinaController.text = disciplina;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Notas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _disciplinaController,
                decoration: InputDecoration(labelText: 'Nova Disciplina'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _alunoController,
                decoration: InputDecoration(labelText: 'Novo Aluno'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _notaController,
                decoration: InputDecoration(labelText: 'Nova Nota'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final double novaNota = double.tryParse(_notaController.text) ?? 0;
                final String novaDisciplina = _disciplinaController.text;
                final String novoAluno = _alunoController.text;

                setState(() {
                  _disciplinas.remove(disciplina);
                  _disciplinas[novaDisciplina] = {_alunoController.text: [novaNota]};
                });
                Navigator.of(context).pop();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  double _calcularMedia(String disciplina) {
    if (_disciplinas.containsKey(disciplina)) {
      final notas = _disciplinas[disciplina]!.values.expand((e) => e).toList();
      if (notas.isNotEmpty) {
        return notas.reduce((a, b) => a + b) / notas.length;
      }
    }
    return 0;
  }

  String _calcularSituacao(double media) {
    return media >= 6.0 ? 'Aprovado' : 'Reprovado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _disciplinaController,
                decoration: InputDecoration(labelText: 'Disciplina'),
              ),
              TextField(
                controller: _alunoController,
                decoration: InputDecoration(labelText: 'Aluno'),
              ),
              TextField(
                controller: _notaController,
                decoration: InputDecoration(labelText: 'Nota'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              ElevatedButton(
                onPressed: _adicionarAlunoENota,
                child: Text('Adicionar Aluno e Nota'),
              ),
              const SizedBox(height: 20),
              if (_disciplinas.isNotEmpty)
                for (var disciplina in _disciplinas.keys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Disciplina: $disciplina',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      for (var aluno in _disciplinas[disciplina]!.keys)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Aluno: $aluno',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editarNotas(disciplina, aluno),
                                ),
                              ],
                            ),
                            Text(
                              'Nota: ${_disciplinas[disciplina]![aluno]![0]}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Média: ${_calcularMedia(disciplina).toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Situação: ${_calcularSituacao(_calcularMedia(disciplina))}',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
