import 'package:chatbotbnn/service/app_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PotentialCustomers extends StatefulWidget {
  const PotentialCustomers({super.key});

  @override
  State<PotentialCustomers> createState() => _PotentialCustomersState();
}

class _PotentialCustomersState extends State<PotentialCustomers> {
  final ContactDataSource _dataSource = ContactDataSource();

  Future<Map<String, String?>> getChatbotInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('chatbot_name'),
      'picture': prefs.getString('chatbot_picture'),
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                FutureBuilder<Map<String, String?>>(
                  future: getChatbotInfo(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage:
                                AssetImage('resources/logo_smart.png'),
                            radius: 20,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'No Name',
                            style: GoogleFonts.robotoCondensed(
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      );
                    }

                    final chatbotName = snapshot.data?['name'] ?? 'No Name';
                    final chatbotPicture = snapshot.data?['picture'];

                    return Row(
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          padding: const EdgeInsets.only(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.white),
                            borderRadius: BorderRadius.circular(
                                25), // Adding rounded corners here
                          ),
                          child: CircleAvatar(
                            backgroundImage: chatbotPicture != null &&
                                    chatbotPicture.isNotEmpty
                                ? NetworkImage(
                                    "${ApiConfig.baseUrlBasic}$chatbotPicture")
                                : const AssetImage('resources/logo_smart.png')
                                    as ImageProvider,
                            radius: 20,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          chatbotName,
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          PaginatedDataTable(
            columns: [
              DataColumn(label: Text('STT')),
              DataColumn(label: Text('Họ và tên')),
              DataColumn(label: Text('Số điện thoại')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Địa chỉ')),
              DataColumn(label: Text('Tác vụ')),
            ],
            source: _dataSource,
            rowsPerPage: 5, // Số hàng hiển thị mỗi trang
          ),
        ],
      ),
    );
  }
}

class Contact {
  final int id;
  final String name;
  final String phone;
  final String email;
  final String address;

  Contact(this.id, this.name, this.phone, this.email, this.address);
}

class ContactDataSource extends DataTableSource {
  final List<Contact> contacts = [
    Contact(1, "Nguyễn Văn A", "0123456789", "a@gmail.com", "Hà Nội"),
    Contact(2, "Trần Thị B", "0987654321", "b@gmail.com", "Hồ Chí Minh"),
    Contact(3, "Phạm Văn C", "0345678912", "c@gmail.com", "Đà Nẵng"),
    Contact(4, "Lê Thị D", "0567891234", "d@gmail.com", "Hải Phòng"),
    Contact(5, "Hoàng Văn E", "0789123456", "e@gmail.com", "Cần Thơ"),
    Contact(6, "Vũ Thị F", "0891234567", "f@gmail.com", "Bắc Ninh"),
    Contact(7, "Đinh Văn G", "0912345678", "g@gmail.com", "Huế"),
    Contact(8, "Lý Thị H", "0908765432", "h@gmail.com", "Nha Trang"),
    Contact(9, "Bùi Văn I", "0998765432", "i@gmail.com", "Quảng Ninh"),
    Contact(10, "Tống Thị J", "0887654321", "j@gmail.com", "Bình Dương"),
  ];

  @override
  DataRow getRow(int index) {
    final contact = contacts[index];
    return DataRow(cells: [
      DataCell(Text('${contact.id}')),
      DataCell(Text(contact.name)),
      DataCell(Text(contact.phone)),
      DataCell(Text(contact.email)),
      DataCell(Text(contact.address)),
      DataCell(Icon(Icons.delete, color: Colors.red)),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => contacts.length;
  @override
  int get selectedRowCount => 0;
}
