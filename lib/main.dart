import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cadastro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Formulário de Cadastro'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _dataController = TextEditingController(); // só para exibir a data
  DateTime? _dataNascimento;
  String? _sexo; // "Homem" | "Mulher"

  @override
  void dispose() {
    _nomeController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  int _calcularIdade(DateTime nascimento) {
    final hoje = DateTime.now();
    var idade = hoje.year - nascimento.year;
    final fezAniversario = (hoje.month > nascimento.month) ||
        (hoje.month == nascimento.month && hoje.day >= nascimento.day);
    if (!fezAniversario) idade--;
    return idade;
  }

  String _formatar(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final inicial = _dataNascimento ?? DateTime(agora.year - 18, agora.month, agora.day);
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(1900),
      lastDate: agora,
    );
    if (escolhida != null) {
      setState(() {
        _dataNascimento = escolhida;
        _dataController.text = _formatar(escolhida);
      });
    }
  }

  void _enviar() {
    if (_formKey.currentState!.validate()) {
      // Aqui você faria o POST/cadastro.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro válido!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nome Completo
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) {
                  final texto = v?.trim() ?? '';
                  if (texto.isEmpty) return 'Informe o nome.';
                  if (texto.length < 3) return 'Nome muito curto.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Data de Nascimento (sem pacotes externos)
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  hintText: 'dd/mm/aaaa',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: _selecionarData,
                validator: (_) {
                  if (_dataNascimento == null) return 'Selecione a data.';
                  final idade = _calcularIdade(_dataNascimento!);
                  if (idade < 18) return 'É preciso ter 18 anos ou mais.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Sexo
              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: const InputDecoration(
                  labelText: 'Sexo',
                  border: OutlineInputBorder(),
                ),
                items: const ['Homem', 'Mulher']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _sexo = v),
                validator: (v) => v == null ? 'Selecione o sexo.' : null,
              ),
              const SizedBox(height: 24),

              // Botão
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _enviar,
                  child: const Text('Cadastrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
