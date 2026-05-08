import 'package:flutter/material.dart';

class QuickEditDialog extends StatefulWidget {
  final String title;
  final double initialValue;
  final String unit;
  final double min;
  final double max;
  final double step;
  final Function(double) onSave;

  const QuickEditDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.unit,
    required this.min,
    required this.max,
    required this.step,
    required this.onSave,
  });

  @override
  State<QuickEditDialog> createState() => _QuickEditDialogState();
}

class _QuickEditDialogState extends State<QuickEditDialog> {
  late double _value;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _controller.text = _value % 1 == 0
        ? _value.toStringAsFixed(0)
        : _value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateValue(double newValue) {
    setState(() {
      _value = newValue.clamp(widget.min, widget.max);
      if (widget.title == 'Pasos') {
        _controller.text = _value.toInt().toString();
      } else {
        _controller.text = _value.toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSteps = widget.title == 'Pasos';
    final isWater = widget.title == 'Agua (litros)';

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A),
      title:
          Text(widget.title, style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Color(0xFF00D4AA),
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: widget.unit,
              suffixStyle: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFF252525),
            ),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) {
                _value = val.clamp(widget.min, widget.max);
              }
            },
          ),
          const SizedBox(height: 16),

          if (isSteps) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _QuickButton(
                    label: '+100',
                    onTap: () => _updateValue(_value + 100)),
                _QuickButton(
                    label: '+500',
                    onTap: () => _updateValue(_value + 500)),
                _QuickButton(
                    label: '+1000',
                    onTap: () => _updateValue(_value + 1000)),
                _QuickButton(
                    label: '+5000',
                    onTap: () => _updateValue(_value + 5000)),
                _QuickButton(
                    label: '-100',
                    onTap: () => _updateValue(_value - 100)),
                _QuickButton(
                    label: '-500',
                    onTap: () => _updateValue(_value - 500)),
                _QuickButton(
                    label: 'Limpiar',
                    onTap: () => _updateValue(0),
                    isClear: true),
              ],
            ),
            const SizedBox(height: 16),
          ],

          if (isWater) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _QuickButton(
                    label: '+0.25L',
                    onTap: () => _updateValue(_value + 0.25)),
                _QuickButton(
                    label: '+0.5L',
                    onTap: () => _updateValue(_value + 0.5)),
                _QuickButton(
                    label: '+1L',
                    onTap: () => _updateValue(_value + 1)),
                _QuickButton(
                    label: '-0.25L',
                    onTap: () => _updateValue(_value - 0.25)),
                _QuickButton(
                    label: '-0.5L',
                    onTap: () => _updateValue(_value - 0.5)),
                _QuickButton(
                    label: 'Limpiar',
                    onTap: () => _updateValue(0),
                    isClear: true),
              ],
            ),
            const SizedBox(height: 16),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _value > widget.min
                    ? () => _updateValue(_value - widget.step)
                    : null,
                icon: const Icon(Icons.remove_circle,
                    color: Color(0xFF00D4AA), size: 40),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: _value < widget.max
                    ? () => _updateValue(_value + widget.step)
                    : null,
                icon: const Icon(Icons.add_circle,
                    color: Color(0xFF00D4AA), size: 40),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 16)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_value);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00D4AA),
            foregroundColor: Colors.black,
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Guardar',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isClear;

  const _QuickButton(
      {required this.label, required this.onTap, this.isClear = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isClear
              ? const Color(0xFFFF6B6B).withOpacity(0.2)
              : const Color(0xFF00D4AA).withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isClear
                ? const Color(0xFFFF6B6B)
                : const Color(0xFF00D4AA),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
