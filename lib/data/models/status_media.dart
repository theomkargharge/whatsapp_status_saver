class StatusMedia {
  final String images; // Can be file path OR content URI
  final bool isVideo;
  final String? name;
  final int? size;
  final int? lastModified;
  
  StatusMedia({
    required this.images,
    required this.isVideo,
    this.name,
    this.size,
    this.lastModified,
  });
  
  Map<String, dynamic> toJson() => {
    'images': images,
    'isVideo': isVideo,
    'name': name,
    'size': size,
    'lastModified': lastModified,
  };
  
  factory StatusMedia.fromJson(Map<String, dynamic> json) => StatusMedia(
    images: json['images'] as String,
    isVideo: json['isVideo'] as bool,
    name: json['name'] as String?,
    size: json['size'] as int?,
    lastModified: json['lastModified'] as int?,
  );
}