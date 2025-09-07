class EverythingBody {
  final String? q;
  final int? page;
  final int? pageSize;

  EverythingBody({this.q = '*', this.page = 1, this.pageSize = 20});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'q': q, 'page': page, 'pageSize': pageSize};
  }

  factory EverythingBody.fromMap(Map<String, dynamic> map) {
    return EverythingBody(
      q: map['q'] as String,
      page: map['page'] != null ? map['page'] as int : null,
      pageSize: map['pageSize'] != null ? map['pageSize'] as int : null,
    );
  }
}
