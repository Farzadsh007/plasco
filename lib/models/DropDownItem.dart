class DropDownItem {
  int id;
  String value;
  dynamic data;

  DropDownItem(this.id, this.value, this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropDownItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          value == other.value &&
          data == other.data;

  @override
  int get hashCode => id.hashCode ^ value.hashCode ^ data.hashCode;
}
