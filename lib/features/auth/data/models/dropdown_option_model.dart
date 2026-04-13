class DropdownOption {
  final String value;
  final String label;
  final String? iconPath;
  final String? trailingIconPath;
  DropdownOption({
    required this.value,
    required this.label,
    this.iconPath,
    this.trailingIconPath,
  });
}
