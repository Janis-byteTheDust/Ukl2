import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MatkulPage extends StatefulWidget {
  const MatkulPage({Key? key}) : super(key: key);

  @override
  State<MatkulPage> createState() => _MatkulPageState();
}

class _MatkulPageState extends State<MatkulPage> {
  List<Map<String, dynamic>> matkulList = [];
  Set<int> selectedIds = {};

  @override
  void initState() {
    super.initState();
    fetchMatkul();
  }

  Future<void> fetchMatkul() async {
    final response = await http.get(
      Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl1/api/getmatkul'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> data = body['data'];

      setState(() {
        matkulList = data.cast<Map<String, dynamic>>();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil data mata kuliah'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int get totalSKS {
    return matkulList
        .where((matkul) =>
            selectedIds.contains(int.parse(matkul['id'].toString())))
        .fold(0, (sum, matkul) => sum + int.parse(matkul['sks'].toString()));
  }

  Future<void> kirimMatkulTerpilih() async {
    final selectedMatkul = matkulList
        .where((matkul) =>
            selectedIds.contains(int.parse(matkul['id'].toString())))
        .map((matkul) => {
              'id': matkul['id'].toString(),
              'nama_matkul': matkul['nama_matkul'].toString(),
              'sks': int.parse(matkul['sks'].toString()),
            })
        .toList();

    final response = await http.post(
      Uri.parse('https://learn.smktelkom-mlg.sch.id/ukl1/api/selectmatkul'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'list_matkul': selectedMatkul}),
    );

    final result = jsonDecode(response.body);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['status'] == true ? Colors.green : Colors.red,
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      color: Colors.blue[300],
      padding: const EdgeInsets.all(10),
      child: Row(
        children: const [
          Expanded(
              flex: 1,
              child:
                  Text("ID", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 3,
              child: Text("Mat Kul",
                  style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child:
                  Text("SKS", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Center(
                  child: Text("Pilih",
                      style: TextStyle(fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget buildMatkulRow(Map<String, dynamic> matkul) {
    int id = int.parse(matkul['id'].toString());
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(flex: 1, child: Text(matkul['id'].toString())),
              Expanded(flex: 3, child: Text(matkul['nama_matkul'].toString())),
              Expanded(flex: 1, child: Text(matkul['sks'].toString())),
              Expanded(
                flex: 1,
                child: Checkbox(
                  value: selectedIds.contains(id),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        selectedIds.add(id);
                      } else {
                        selectedIds.remove(id);
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Mata Kuliah"),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildHeader(),
            const SizedBox(height: 4),
            Expanded(
              child: ListView.builder(
                itemCount: matkulList.length,
                itemBuilder: (context, index) {
                  return buildMatkulRow(matkulList[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total SKS: $totalSKS",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed:
                      selectedIds.isNotEmpty ? kirimMatkulTerpilih : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                  ),
                  child: const Text("Submit Matkul Terpilih"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
