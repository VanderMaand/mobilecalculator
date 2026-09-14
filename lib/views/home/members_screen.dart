import 'package:flutter/material.dart';

class MembersScreen extends StatelessWidget {
  final List<Map<String, String>> members = [
    {'nama': 'Anggota 1', 'npm': '123456789', 'role': 'Project Manager'},
    {'nama': 'Anggota 2', 'npm': '123456790', 'role': 'Lead Programmer'},
    {'nama': 'Anggota 3', 'npm': '123456791', 'role': 'UI/UX Designer'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Kelompok')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) => ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(members[index]['nama']!),
          subtitle: Text(
            'NPM: ${members[index]['npm']!} - ${members[index]['role']!}',
          ),
        ),
      ),
    );
  }
}
