class Validators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email inválido';
    return null;
  }

  static String? Function(String?) minLength(int min) => (String? value) {
    if (value == null || value.trim().length < min) {
      return 'Mínimo de $min caracteres';
    }
    return null;
  };

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    final num = double.tryParse(value.replaceAll(',', '.'));
    if (num == null || num <= 0) return 'Valor deve ser positivo';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    final cleaned = value.replaceAll('.', '').replaceAll(',', '.');
    final num = double.tryParse(cleaned);
    if (num == null) return 'Valor inválido';
    if (num <= 0) return 'Valor deve ser positivo';
    return null;
  }

  static String? dayOfMonth(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    final num = int.tryParse(value.trim());
    if (num == null || num < 1 || num > 31) return 'Dia deve estar entre 1 e 31';
    return null;
  }

  static String? positiveInt(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    final num = int.tryParse(value.trim());
    if (num == null || num <= 0) return 'Valor deve ser positivo';
    return null;
  }
}
