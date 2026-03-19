import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/trophy_model.dart';
import '../providers/trophy_provider.dart';
import '../providers/user_provider.dart';
import '../utils/colors.dart';
import '../widgets/game_scaffold.dart';
import '../widgets/trophy_widget.dart';

class TrophyLabScreen extends StatefulWidget {
  const TrophyLabScreen({super.key});

  @override
  State<TrophyLabScreen> createState() => _TrophyLabScreenState();
}

class _TrophyLabScreenState extends State<TrophyLabScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  TrophyRarity _selectedRarity = TrophyRarity.rare;
  IconData _selectedIcon = Icons.emoji_events;
  Color _selectedColor = AppColors.primary;
  bool _awardNow = true;

  final List<IconData> _iconChoices = const [
    Icons.emoji_events,
    Icons.auto_awesome,
    Icons.star,
    Icons.code,
    Icons.school,
    Icons.local_fire_department,
    Icons.bolt,
    Icons.lightbulb,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      appBar: AppBar(
        title: const Text('Trophy Lab'),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        children: [
          _buildPreview(),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _nameController,
            label: 'Trophy name',
            hint: 'Creative Builder',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Describe how it is earned',
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _imageUrlController,
            label: 'Trophy photo URL',
            hint: 'https://...',
          ),
          const SizedBox(height: 16),
          _buildRaritySelector(),
          const SizedBox(height: 16),
          _buildIconSelector(),
          const SizedBox(height: 16),
          _buildColorSelector(),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            value: _awardNow,
            onChanged: (value) => setState(() => _awardNow = value),
            title: const Text(
              'Award to my profile',
              style: TextStyle(color: AppColors.text),
            ),
            subtitle: const Text(
              'Unlock this trophy immediately.',
              style: TextStyle(color: AppColors.textMuted),
            ),
            activeThumbColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _saveTrophy,
            child: const Text('Save Trophy'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navBorder),
      ),
      child: Row(
        children: [
          TrophyWidget(
            trophy: TrophyModel(
              id: 'preview',
              name: _nameController.text.isEmpty
                  ? 'New Trophy'
                  : _nameController.text,
              description: _descriptionController.text.isEmpty
                  ? 'Preview your trophy design.'
                  : _descriptionController.text,
              rarity: _selectedRarity,
              icon: _selectedIcon,
              color: _selectedColor,
              imageUrl: _imageUrlController.text,
              createdAt: DateTime.now(),
            ),
            size: 70,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty
                      ? 'New Trophy'
                      : _nameController.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _descriptionController.text.isEmpty
                      ? 'Preview your trophy details here.'
                      : _descriptionController.text,
                  style: const TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedRarity.name.toUpperCase(),
                  style: TextStyle(
                    color: _selectedColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildRaritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rarity',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TrophyRarity.values.map((rarity) {
            final selected = _selectedRarity == rarity;
            return ChoiceChip(
              label: Text(rarity.name.toUpperCase()),
              selected: selected,
              onSelected: (_) => setState(() => _selectedRarity = rarity),
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              backgroundColor: AppColors.surfaceAlt,
              labelStyle: TextStyle(
                color: selected ? AppColors.primary : AppColors.textLight,
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Icon',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _iconChoices.map((icon) {
            final selected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () => setState(() => _selectedIcon = icon),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.navBorder,
                  ),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      Colors.orange,
      Colors.green,
      Colors.pinkAccent,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Highlight Color',
          style: TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: colors.map((color) {
            final selected = _selectedColor == color;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? Colors.white : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _saveTrophy() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a name and description first.')),
      );
      return;
    }

    final provider = context.read<TrophyProvider>();
    final trophy = provider.createCustomTrophy(
      name: name,
      description: description,
      rarity: _selectedRarity,
      icon: _selectedIcon,
      color: _selectedColor,
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
    );

    provider.addTrophy(trophy);
    if (_awardNow) {
      await context.read<UserProvider>().addTrophy(trophy.id);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trophy created!')),
    );
    Navigator.pop(context);
  }
}
