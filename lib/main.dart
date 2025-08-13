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
        useMaterial3: true,
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
  final PageController _pageController = PageController();
  final List<FormData> _formDataList = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Adiciona um formulário inicial vazio
    _addNewForm();
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose de todos os controllers
    for (var formData in _formDataList) {
      formData.dispose();
    }
    super.dispose();
  }

  void _addNewForm() {
    setState(() {
      _formDataList.add(FormData());
    });
  }

  void _removeForm(int index) {
    if (_formDataList.length > 1) {
      setState(() {
        _formDataList[index].dispose();
        _formDataList.removeAt(index);
        if (_currentIndex >= _formDataList.length) {
          _currentIndex = _formDataList.length - 1;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void _submitForm(int index) {
    final formData = _formDataList[index];
    if (formData.formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro ${index + 1} válido!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Indicadores de página
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Formulário ${_currentIndex + 1} de ${_formDataList.length}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
                Row(
                  children: List.generate(_formDataList.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Carrossel de formulários
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _formDataList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : (isTablet ? 32 : 64),
                    vertical: 8,
                  ),
                  child: FormCard(
                    formData: _formDataList[index],
                    index: index,
                    onSubmit: () => _submitForm(index),
                    onRemove: _formDataList.length > 1
                        ? () => _removeForm(index)
                        : null,
                    isMobile: isMobile,
                  ),
                );
              },
            ),
          ),

          // Botões de navegação
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _currentIndex > 0
                      ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Anterior'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _addNewForm();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _pageController.animateToPage(
                        _formDataList.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Novo'),
                ),
                ElevatedButton.icon(
                  onPressed: _currentIndex < _formDataList.length - 1
                      ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Próximo'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FormData {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController dataController = TextEditingController();
  DateTime? dataNascimento;
  String? sexo;

  void dispose() {
    nomeController.dispose();
    dataController.dispose();
  }

  int calcularIdade(DateTime nascimento) {
    final hoje = DateTime.now();
    var idade = hoje.year - nascimento.year;
    final fezAniversario = (hoje.month > nascimento.month) ||
        (hoje.month == nascimento.month && hoje.day >= nascimento.day);
    if (!fezAniversario) idade--;
    return idade;
  }

  String formatarData(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class FormCard extends StatefulWidget {
  final FormData formData;
  final int index;
  final VoidCallback onSubmit;
  final VoidCallback? onRemove;
  final bool isMobile;

  const FormCard({
    super.key,
    required this.formData,
    required this.index,
    required this.onSubmit,
    this.onRemove,
    required this.isMobile,
  });

  @override
  State<FormCard> createState() => _FormCardState();
}

class _FormCardState extends State<FormCard> {
  Future<void> _selecionarData() async {
    final agora = DateTime.now();
    final inicial = widget.formData.dataNascimento ??
        DateTime(agora.year - 18, agora.month, agora.day);

    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(1900),
      lastDate: agora,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (escolhida != null && mounted) {
      setState(() {
        widget.formData.dataNascimento = escolhida;
        widget.formData.dataController.text =
            widget.formData.formatarData(escolhida);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(widget.isMobile ? 16 : 24),
        child: Form(
          key: widget.formData.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header do card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pessoa ${widget.index + 1}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (widget.onRemove != null)
                      IconButton(
                        onPressed: widget.onRemove,
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        tooltip: 'Remover formulário',
                      ),
                  ],
                ),

                SizedBox(height: widget.isMobile ? 16 : 24),

                // Nome Completo
                TextFormField(
                  controller: widget.formData.nomeController,
                  decoration: InputDecoration(
                    labelText: 'Nome Completo',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    final texto = v?.trim() ?? '';
                    if (texto.isEmpty) return 'Informe o nome.';
                    if (texto.length < 3) return 'Nome muito curto.';
                    final palavras = texto.split(' ');
                    if (palavras.length < 2) return 'Informe nome e sobrenome.';
                    return null;
                  },
                ),

                SizedBox(height: widget.isMobile ? 16 : 20),

                // Data de Nascimento
                TextFormField(
                  controller: widget.formData.dataController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Data de Nascimento',
                    hintText: 'dd/mm/aaaa',
                    prefixIcon: const Icon(Icons.cake),
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onTap: _selecionarData,
                  validator: (_) {
                    if (widget.formData.dataNascimento == null) {
                      return 'Selecione a data.';
                    }
                    final idade = widget.formData.calcularIdade(
                        widget.formData.dataNascimento!);
                    if (idade < 0) return 'Data inválida.';
                    if (idade > 120) return 'Idade muito alta.';
                    return null;
                  },
                ),

                SizedBox(height: widget.isMobile ? 16 : 20),

                // Sexo
                DropdownButtonFormField<String>(
                  value: widget.formData.sexo,
                  decoration: InputDecoration(
                    labelText: 'Sexo',
                    prefixIcon: const Icon(Icons.wc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  items: const ['Homem', 'Mulher']
                      .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => widget.formData.sexo = v),
                  validator: (v) => v == null ? 'Selecione o sexo.' : null,
                ),

                SizedBox(height: widget.isMobile ? 24 : 32),

                // Botão de envio
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: widget.onSubmit,
                    icon: const Icon(Icons.check),
                    label: const Text('Validar Cadastro'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Informação adicional (idade se data selecionada)
                if (widget.formData.dataNascimento != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Idade: ${widget.formData.calcularIdade(widget.formData.dataNascimento!)} anos',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}