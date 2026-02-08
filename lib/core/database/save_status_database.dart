import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

/// Model for saved status
class SavedStatus {
  final int? id;
  final String uri; // Content URI or file path
  final String fileName;
  final bool isVideo;
  final int savedAt; // Timestamp in milliseconds
  final String? localPath; // Path where file is saved locally
  final int? size;
  final int? duration; // For videos

  SavedStatus({
    this.id,
    required this.uri,
    required this.fileName,
    required this.isVideo,
    required this.savedAt,
    this.localPath,
    this.size,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uri': uri,
      'fileName': fileName,
      'isVideo': isVideo ? 1 : 0,
      'savedAt': savedAt,
      'localPath': localPath,
      'size': size,
      'duration': duration,
    };
  }

  factory SavedStatus.fromMap(Map<String, dynamic> map) {
    return SavedStatus(
      id: map['id'] as int?,
      uri: map['uri'] as String,
      fileName: map['fileName'] as String,
      isVideo: map['isVideo'] == 1,
      savedAt: map['savedAt'] as int,
      localPath: map['localPath'] as String?,
      size: map['size'] as int?,
      duration: map['duration'] as int?,
    );
  }
}

/// Database helper for saved statuses
class SavedStatusDatabase {
  static final SavedStatusDatabase instance = SavedStatusDatabase._init();
  static Database? _database;

  SavedStatusDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('saved_statuses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE saved_statuses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uri TEXT NOT NULL,
        fileName TEXT NOT NULL,
        isVideo INTEGER NOT NULL,
        savedAt INTEGER NOT NULL,
        localPath TEXT,
        size INTEGER,
        duration INTEGER
      )
    ''');

    // Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_saved_at ON saved_statuses (savedAt DESC)
    ''');
  }

  /// Save a status
  Future<SavedStatus> create(SavedStatus status) async {
    final db = await database;
    final id = await db.insert('saved_statuses', status.toMap());
    return status.copyWith(id: id);
  }

  /// Get all saved statuses
  Future<List<SavedStatus>> getAllSaved() async {
    final db = await database;
    final result = await db.query(
      'saved_statuses',
      orderBy: 'savedAt DESC',
    );
    return result.map((map) => SavedStatus.fromMap(map)).toList();
  }

  /// Get saved images only
  Future<List<SavedStatus>> getSavedImages() async {
    final db = await database;
    final result = await db.query(
      'saved_statuses',
      where: 'isVideo = ?',
      whereArgs: [0],
      orderBy: 'savedAt DESC',
    );
    return result.map((map) => SavedStatus.fromMap(map)).toList();
  }

  /// Get saved videos only
  Future<List<SavedStatus>> getSavedVideos() async {
    final db = await database;
    final result = await db.query(
      'saved_statuses',
      where: 'isVideo = ?',
      whereArgs: [1],
      orderBy: 'savedAt DESC',
    );
    return result.map((map) => SavedStatus.fromMap(map)).toList();
  }

  /// Check if status is already saved
  Future<bool> isSaved(String uri) async {
    final db = await database;
    final result = await db.query(
      'saved_statuses',
      where: 'uri = ?',
      whereArgs: [uri],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  /// Delete a saved status
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'saved_statuses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete saved status and its local file
  Future<void> deleteWithFile(SavedStatus status) async {
    // Delete from database
    if (status.id != null) {
      await delete(status.id!);
    }

    // Delete local file if exists
    if (status.localPath != null) {
      try {
        final file = File(status.localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('Error deleting file: $e');
      }
    }
  }

  /// Get count of saved statuses
  Future<int> getCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM saved_statuses');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close database
  Future close() async {
    final db = await database;
    db.close();
  }
}

extension SavedStatusExtension on SavedStatus {
  SavedStatus copyWith({
    int? id,
    String? uri,
    String? fileName,
    bool? isVideo,
    int? savedAt,
    String? localPath,
    int? size,
    int? duration,
  }) {
    return SavedStatus(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      fileName: fileName ?? this.fileName,
      isVideo: isVideo ?? this.isVideo,
      savedAt: savedAt ?? this.savedAt,
      localPath: localPath ?? this.localPath,
      size: size ?? this.size,
      duration: duration ?? this.duration,
    );
  }
}