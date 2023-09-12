class UploadedDocumentList {
  late String userId;
  late String search;
  late String month;
  late String year;
  late String sort;
  late String mode;
  int pageNumber = 0;
  late int limit;

  set setUserId(String value) {
    userId = value;
  }

  set setSearch(String value) {
    search = value;
  }

  set setMonth(String value) {
    month = value;
  }

  set setYear(String value) {
    year = value;
  }

  set setSort(String value) {
    sort = value;
  }

  set setPageNumber(int value) {
    pageNumber = value;
  }

  increamentPageNumber() {
    pageNumber++;
  }

  set setLimit(int value) {
    limit = value;
  }

  set setMode(String modeStr) {
    mode = modeStr;
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'search': search,
        'month': month,
        'year': year,
        'sort': sort,
        'mode': mode,
        'pageNumber': pageNumber,
        'limit': limit,
      };
}
