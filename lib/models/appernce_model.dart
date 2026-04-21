/* class AppearanceModel {
  final int? id;
  final String? name;
  final String? value;

  AppearanceModel({this.id, this.name, this.value});

  factory AppearanceModel.fromJson(Map<String, dynamic> json) {
    return AppearanceModel(
      id: json['id'],
      name: json['name'],
      value: json['value'],
    );
  }
}
 */

class AppearanceModel {
  final String primaryColor;
  final String secondaryColor;
  final String sidebarColor;
  final String fontFamily;

  AppearanceModel({
    required this.primaryColor,
    required this.secondaryColor,
    required this.sidebarColor,
    required this.fontFamily,
  });

  factory AppearanceModel.fromJson(Map<String, dynamic> json) {
    return AppearanceModel(
      primaryColor: json['primary_color'] ?? '#FFFFFF',
      secondaryColor: json['secondary_color'] ?? '#FFFFFF',
      sidebarColor: json['sidebar_color'] ?? '#FFFFFF',
      fontFamily: json['font_family'] ?? 'Arial',
    );
  }
}
