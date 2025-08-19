import 'package:flutter/material.dart';
import '../widgets/rounded_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Track your health',
                    style: Theme.of(context).textTheme.displayMedium),
              ),
              const SizedBox(height: 20),
              Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: RoundedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quick Log',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _noteController,
                                  decoration: const InputDecoration(
                                    hintText: 'Write a brief note... ',
                                    prefixIcon: Icon(Icons.edit_rounded),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a note';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Note saved successfully!')),
                                        );
                                      }
                                    },
                                    icon:
                                        const Icon(Icons.check_circle_rounded),
                                    label: const Text('Save Note'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: isWide ? 20 : 0, height: isWide ? 0 : 20),
                  Expanded(
                    flex: 3,
                    child: RoundedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overview',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          const Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _Metric(
                                  icon: Icons.favorite_rounded,
                                  label: 'Heart',
                                  value: '72 bpm'),
                              _Metric(
                                  icon: Icons.local_fire_department_rounded,
                                  label: 'Calories',
                                  value: '560'),
                              _Metric(
                                  icon: Icons.directions_run_rounded,
                                  label: 'Steps',
                                  value: '7.2k'),
                              _Metric(
                                  icon: Icons.nightlight_round,
                                  label: 'Sleep',
                                  value: '7h 30m'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/list'),
                              icon: const Icon(Icons.list_alt_rounded),
                              label: const Text('View All Logs'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: const [
          BoxShadow(
              color: Color(0x140B0F1A), blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
