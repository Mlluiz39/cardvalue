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
}
