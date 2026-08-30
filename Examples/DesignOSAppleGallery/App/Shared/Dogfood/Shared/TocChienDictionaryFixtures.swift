import Foundation

struct TocChienDictionaryEntry: Identifiable, Hashable, Sendable {
  let id: String
  let term: String
  let description: String
}

enum TocChienDictionaryFixtures {
  static let entries = [
    TocChienDictionaryEntry(
      id: "anh-suong",
      term: "Ánh sương",
      description: "Ánh sáng dịu xuất hiện khi sương mai còn phủ trên khu vườn thử nghiệm."
    ),
    TocChienDictionaryEntry(
      id: "gio-nhe",
      term: "Gió nhẹ",
      description: "Luồng gió nhỏ được dùng trong ví dụ cục bộ để minh họa một mô tả ngắn."
    ),
    TocChienDictionaryEntry(
      id: "mua-xanh",
      term: "Mưa xanh",
      description: longDescription
    ),
  ]

  private static let longDescription = """
    Mưa xanh là một mục từ tổng hợp chỉ dùng cho thử nghiệm cục bộ. Mô tả này cố ý dài để
    kiểm tra rằng nội dung tiếng Việt vẫn hiển thị đầy đủ trong hàng danh sách, không bị cắt
    ngắn hay thay bằng dấu ba chấm. Nó không mô tả dữ liệu, nhân vật, địa danh, tài sản hay
    thuật ngữ của bất kỳ sản phẩm nào. Người dùng có thể tìm bằng tên mục từ hoặc bằng các từ
    xuất hiện trong mô tả, và kết quả luôn được lọc trong bộ dữ liệu tổng hợp có sẵn trên thiết bị.
    """
}
