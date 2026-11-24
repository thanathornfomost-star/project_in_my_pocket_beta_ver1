import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileManagerWidget extends StatefulWidget {
  final String projectId;
  final String taskId;

  const FileManagerWidget({
    super.key,
    required this.projectId,
    required this.taskId,
  });

  @override
  State<FileManagerWidget> createState() => _FileManagerWidgetState();
}

class _FileManagerWidgetState extends State<FileManagerWidget> {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _uploadingFileName = '';

  // Reference to the 'files' subcollection for this task
  late final CollectionReference _filesCollection;

  @override
  void initState() {
    super.initState();
    _filesCollection = FirebaseFirestore.instance
        .collection('Events')
        .doc(widget.projectId)
        .collection('tasks')
        .doc(widget.taskId)
        .collection('files');
  }

  Future<void> _uploadFile() async {
    final XFile? result = await openFile();

    if (result != null && result.path.isNotEmpty) {
      final file = File(result.path);
      final fileName = result.name;

      setState(() {
        _isUploading = true;
        _uploadingFileName = fileName;
        _uploadProgress = 0.0;
      });

      try {
        final storageRef = FirebaseStorage.instance.ref(
          'project_files/${widget.projectId}/${widget.taskId}/$fileName',
        );

        UploadTask uploadTask = storageRef.putFile(file);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (mounted) {
            setState(() {
              _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
            });
          }
        });

        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        await _filesCollection.add({
          'fileName': fileName,
          'downloadURL': downloadURL,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
      } on FirebaseException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('อัปโหลดไม่สำเร็จ: ${e.message}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  Future<void> _downloadAndOpenFile(String url, String fileName) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      try {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/$fileName';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('กำลังดาวน์โหลด $fileName...')),
          );
        }

        await Dio().download(url, filePath);

        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ไม่สามารถเปิดไฟล์ได้: ${result.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ดาวน์โหลดไม่สำเร็จ: $e')));
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่ได้รับอนุญาตให้เข้าถึงพื้นที่จัดเก็บ'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ไฟล์แนบ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('กำลังอัปโหลด: $_uploadingFileName'),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: _uploadProgress),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filesCollection
                  .orderBy('uploadedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'ยังไม่มีไฟล์แนบ\nกดปุ่ม + เพื่ออัปโหลด',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                final files = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final fileData =
                        files[index].data() as Map<String, dynamic>;
                    final fileName = fileData['fileName'] as String;
                    final downloadURL = fileData['downloadURL'] as String;
                    return ListTile(
                      leading: const Icon(Icons.insert_drive_file_outlined),
                      title: Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.download_for_offline_outlined,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () =>
                            _downloadAndOpenFile(downloadURL, fileName),
                      ),
                      onTap: () => _downloadAndOpenFile(downloadURL, fileName),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('อัปโหลดไฟล์'),
              onPressed: _isUploading ? null : _uploadFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
