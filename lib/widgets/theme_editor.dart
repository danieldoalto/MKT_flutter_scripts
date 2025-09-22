import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/theme_config.dart';
import '../services/theme_service.dart';

/// Editor de temas personalizados
class ThemeEditor extends StatefulWidget {
  final ThemeConfig? initialTheme;
  final VoidCallback? onSaved;
  final VoidCallback? onCancelled;

  const ThemeEditor({
    Key? key,
    this.initialTheme,
    this.onSaved,
    this.onCancelled,
  }) : super(key: key);

  @override
  State<ThemeEditor> createState() => _ThemeEditorState();
}

class _ThemeEditorState extends State<ThemeEditor> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _fontSizeController;
  
  late ThemeConfig _workingTheme;
  bool _isEditing = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    _isEditing = widget.initialTheme != null;
    _workingTheme = widget.initialTheme ?? PredefinedThemes.darkTheme.copyWith(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Meu Tema',
      description: 'Tema personalizado',
      isCustom: true,
    );

    _nameController = TextEditingController(text: _workingTheme.name);
    _descriptionController = TextEditingController(text: _workingTheme.description);
    _fontSizeController = TextEditingController(
      text: _workingTheme.textTheme.bodyMedium?.fontSize?.toString() ?? '14',
    );

    _nameController.addListener(_updateThemeName);
    _descriptionController.addListener(_updateThemeDescription);
    _fontSizeController.addListener(_updateFontSize);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _fontSizeController.dispose();
    super.dispose();
  }

  void _updateThemeName() {
    setState(() {
      _workingTheme = _workingTheme.copyWith(name: _nameController.text);
      _validateTheme();
    });
  }

  void _updateThemeDescription() {
    setState(() {
      _workingTheme = _workingTheme.copyWith(description: _descriptionController.text);
    });
  }

  void _updateFontSize() {
    final fontSize = double.tryParse(_fontSizeController.text);
    if (fontSize != null && fontSize > 0) {
      setState(() {
        _workingTheme = _workingTheme.copyWith(
          textTheme: _workingTheme.textTheme.copyWith(
            bodyMedium: _workingTheme.textTheme.bodyMedium?.copyWith(fontSize: fontSize),
          ),
        );
      });
    }
  }

  void _validateTheme() {
    if (_nameController.text.trim().isEmpty) {
      _validationError = 'Nome do tema é obrigatório';
    } else if (_nameController.text.trim().length < 3) {
      _validationError = 'Nome deve ter pelo menos 3 caracteres';
    } else {
      _validationError = null;
    }
  }

  Future<void> _saveTheme() async {
    _validateTheme();
    if (_validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validationError!),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      final themeService = Provider.of<ThemeService>(context, listen: false);
      
      if (_isEditing) {
        await themeService.updateCustomTheme(_workingTheme);
      } else {
        await themeService.addCustomTheme(_workingTheme);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Tema atualizado!' : 'Tema criado!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar tema: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Tema' : 'Criar Tema'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancelled,
        ),
        actions: [
          TextButton(
            onPressed: _validationError == null ? _saveTheme : null,
            child: Text(
              _isEditing ? 'Atualizar' : 'Salvar',
              style: TextStyle(
                color: _validationError == null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Geral'),
            Tab(icon: Icon(Icons.palette), text: 'Cores'),
            Tab(icon: Icon(Icons.text_fields), text: 'Tipografia'),
            Tab(icon: Icon(Icons.preview), text: 'Preview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(),
          _buildColorsTab(),
          _buildTypographyTab(),
          _buildPreviewTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nome do Tema',
              hintText: 'Ex: Meu Tema Escuro',
              errorText: _validationError,
              prefixIcon: const Icon(Icons.title),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              hintText: 'Descreva seu tema personalizado',
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          Text(
            'Tipo de Tema',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildThemeTypeSelector(),
        ],
      ),
    );
  }

  Widget _buildThemeTypeSelector() {
    return Column(
      children: ThemeType.values.map((type) {
        return RadioListTile<ThemeType>(
          title: Text(_getThemeTypeName(type)),
          subtitle: Text(_getThemeTypeDescription(type)),
          value: type,
          groupValue: _workingTheme.type,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _workingTheme = _workingTheme.copyWith(type: value);
              });
            }
          },
        );
      }).toList(),
    );
  }

  String _getThemeTypeName(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        return 'Claro';
      case ThemeType.dark:
        return 'Escuro';
      case ThemeType.mikrotik:
        return 'MikroTik';
      case ThemeType.terminal:
        return 'Terminal';
    }
  }

  String _getThemeTypeDescription(ThemeType type) {
    switch (type) {
      case ThemeType.light:
        return 'Tema com cores claras e fundo branco';
      case ThemeType.dark:
        return 'Tema com cores escuras e fundo preto';
      case ThemeType.mikrotik:
        return 'Tema inspirado na interface MikroTik';
      case ThemeType.terminal:
        return 'Tema estilo terminal de comando';
    }
  }

  Widget _buildColorsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorSection('Cores Principais', [
            _buildColorPicker('Primária', _workingTheme.colorScheme.primary, (color) {
              setState(() {
                _workingTheme = _workingTheme.copyWith(
                  colorScheme: _workingTheme.colorScheme.copyWith(primary: color),
                );
              });
            }),
            _buildColorPicker('Secundária', _workingTheme.colorScheme.secondary, (color) {
              setState(() {
                _workingTheme = _workingTheme.copyWith(
                  colorScheme: _workingTheme.colorScheme.copyWith(secondary: color),
                );
              });
            }),
          ]),
          const SizedBox(height: 24),
          _buildColorSection('Cores de Fundo', [
            _buildColorPicker('Fundo', _workingTheme.colorScheme.background, (color) {
              setState(() {
                _workingTheme = _workingTheme.copyWith(
                  colorScheme: _workingTheme.colorScheme.copyWith(background: color),
                );
              });
            }),
            _buildColorPicker('Superfície', _workingTheme.colorScheme.surface, (color) {
              setState(() {
                _workingTheme = _workingTheme.copyWith(
                  colorScheme: _workingTheme.colorScheme.copyWith(surface: color),
                );
              });
            }),
          ]),
          const SizedBox(height: 24),
          _buildColorSection('Cores de Estado', [
            _buildColorPicker('Erro', _workingTheme.colorScheme.error, (color) {
              setState(() {
                _workingTheme = _workingTheme.copyWith(
                  colorScheme: _workingTheme.colorScheme.copyWith(error: color),
                );
              });
            }),
          ]),
        ],
      ),
    );
  }

  Widget _buildColorSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildColorPicker(String label, Color color, ValueChanged<Color> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          GestureDetector(
            onTap: () => _showColorPicker(context, color, onChanged),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, Color initialColor, ValueChanged<Color> onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Cor'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: initialColor,
            onColorChanged: onChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configurações de Tipografia',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _fontSizeController,
            decoration: const InputDecoration(
              labelText: 'Tamanho da Fonte Base',
              suffixText: 'px',
              prefixIcon: Icon(Icons.format_size),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Família da Fonte',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _buildFontFamilySelector(),
        ],
      ),
    );
  }

  Widget _buildFontFamilySelector() {
    final fontFamilies = [
      'Roboto',
      'Arial',
      'Helvetica',
      'Times New Roman',
      'Courier New',
      'Georgia',
      'Verdana',
    ];

    final currentFont = _workingTheme.textTheme.bodyMedium?.fontFamily ?? 'Roboto';

    return DropdownButtonFormField<String>(
      value: fontFamilies.contains(currentFont) ? currentFont : fontFamilies.first,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.font_download),
      ),
      items: fontFamilies.map((font) {
        return DropdownMenuItem(
          value: font,
          child: Text(
            font,
            style: TextStyle(fontFamily: font),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _workingTheme = _workingTheme.copyWith(
              textTheme: _workingTheme.textTheme.apply(fontFamily: value),
            );
          });
        }
      },
    );
  }

  Widget _buildPreviewTab() {
    return Theme(
      data: _workingTheme.toThemeData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview do Tema',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildPreviewCard(),
            const SizedBox(height: 16),
            _buildPreviewButtons(),
            const SizedBox(height: 16),
            _buildPreviewInputs(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exemplo de Card',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Este é um exemplo de como o texto aparecerá com o tema selecionado.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informação importante',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewButtons() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () {},
          child: const Text('Botão Primário'),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Botão Secundário'),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () {},
          child: const Text('Botão Texto'),
        ),
      ],
    );
  }

  Widget _buildPreviewInputs() {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Campo de Texto',
            hintText: 'Digite algo aqui',
            prefixIcon: Icon(Icons.edit),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Campo com Erro',
            errorText: 'Este campo é obrigatório',
            prefixIcon: Icon(Icons.error),
          ),
        ),
      ],
    );
  }
}

/// Seletor de cores simples
class BlockPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const BlockPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
  }) : super(key: key);

  static const List<Color> _colors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _colors.length,
        itemBuilder: (context, index) {
          final color = _colors[index];
          final isSelected = color.value == pickerColor.value;
          
          return GestureDetector(
            onTap: () => onColorChanged(color),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}