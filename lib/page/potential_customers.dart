import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_chat/model/reponse_potential_customer.dart';
import 'package:smart_chat/model/utils/customer_utils.dart';

import 'package:smart_chat/service/app_config.dart';

import 'package:smart_chat/service/bot_config_service.dart';
import 'package:smart_chat/provider/chatbot_provider.dart';
import 'package:smart_chat/provider/provider_color.dart';
import 'package:smart_chat/service/potential_customer_sevice.dart';
import 'package:tabler_icons/tabler_icons.dart';

class PotentialCustomers extends StatefulWidget {
  const PotentialCustomers({super.key});

  @override
  State<PotentialCustomers> createState() => _PotentialCustomersState();
}

class _PotentialCustomersState extends State<PotentialCustomers> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _intentScrollController = ScrollController();

  // State variables
  List<DataPotentialCustomer> _customers = [];
  List<String> _dynamicColumns = [];
  List<Map<String, dynamic>> _intentSlots = [];
  bool _isLoading = false;
  bool _hasMoreData = true;

  // Filter variables
  String? _searchContent;
  String? _slotsStatus;
  String? _intentQueue = "Khách hàng";
  int _currentPage = 1;
  int _perPage = 10;

  // Constants
  static const _statusOptions = [
    'Tất cả trạng thái',
    'pending',
    'completed',
    'unreachable'
  ];
  static const _perPageOptions = [10, 20, 50, 100];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _intentScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() => _isLoading = true);

      await Future.wait([
        _fetchCustomers(),
        _loadChatbotConfig(),
      ]);

      _scrollToSelectedIntent();
    } catch (e) {
      _showErrorSnackbar('Không tải được dữ liệu: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchCustomers() async {
    try {
      final response = await fetchAllPotentialCustomer(
        context,
        _searchContent,
        _slotsStatus,
        _currentPage.toString(),
        _intentQueue,
        _perPage.toString(),
      );

      final columnsSet = <String>{};
      for (var customer in response) {
        columnsSet.addAll(customer.slotDetails.keys);
      }

      if (mounted) {
        setState(() {
          _customers = response;
          _dynamicColumns = columnsSet.toList();
          _hasMoreData = response.length >= _perPage;
        });
      }
    } catch (e) {
      _showErrorSnackbar('Lỗi khi tải khách hàng: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> _loadChatbotConfig() async {
    try {
      final chatbotCode = Provider.of<ChatbotProvider>(context, listen: false)
          .currentChatbotCode;
      final config = await fetchChatbotConfigPotential(chatbotCode!, "123");

      if (config.isNotEmpty && mounted) {
        setState(() {
          _intentSlots = config.first.getIntentSlotsWithCount();
        });
      }
    } catch (e) {
      _showErrorSnackbar('Lỗi khi tải cấu hình: ${e.toString()}');
      rethrow;
    }
  }

  void _scrollToSelectedIntent() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_intentScrollController.hasClients && _intentQueue != null) {
        final index = _intentSlots.indexWhere(
          (slot) => slot['intentSlot'] == _intentQueue,
        );

        if (index != -1) {
          _intentScrollController.animateTo(
            (index + 1) * 120.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _searchContent = null;
    _currentPage = 1;
    _fetchCustomers();
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Widget _buildHeader() {
    return FutureBuilder<Map<String, String?>>(
      future: _getChatbotInfo(),
      builder: (context, snapshot) {
        final chatbotName = snapshot.data?['name'] ?? 'No Name';
        final chatbotPicture = snapshot.data?['picture'];

        return Row(
          children: [
            Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(25),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                foregroundImage: chatbotPicture != null &&
                        chatbotPicture.isNotEmpty
                    ? NetworkImage("${ApiConfig.baseUrlBasic}$chatbotPicture")
                    : const AssetImage('resources/Smartchat.png')
                        as ImageProvider,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              chatbotName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIntentFilter() {
    return SizedBox(
      height: 50,
      child: _intentSlots.isEmpty
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            )
          : ListView.builder(
              controller: _intentScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _intentSlots.length + 2,
              itemBuilder: (context, index) {
                if (index == 0 || index == _intentSlots.length + 1) {
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width -
                            (_intentSlots.length * 100)) /
                        3,
                  );
                }

                final slot = _intentSlots[index - 1];
                final slotName = slot['intentSlot'];
                final count = slot['count'];

                return GestureDetector(
                  onTap: () {
                    setState(() => _intentQueue = slotName);
                    _currentPage = 1;
                    _fetchCustomers();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: _intentQueue == slotName
                            ? const Color(0xfffed5113)
                            : Colors.grey.shade400,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "$slotName ($count)",
                      style: TextStyle(
                        color: _intentQueue == slotName
                            ? const Color(0xfffed5113)
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _slotsStatus,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 23),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black,
          ),
          hint: Text(
            'Tất cả trạng thái',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          items: _statusOptions.map((String value) {
            return DropdownMenuItem<String>(
              value: value == 'Tất cả trạng thái' ? null : value,
              child: Text(
                value == 'Tất cả trạng thái'
                    ? value
                    : CustomerUtils.statusMapping[value] ?? value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _slotsStatus = newValue;
              _currentPage = 1;
            });
            _fetchCustomers();
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          hintText: 'Tìm kiếm tại đây...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 23),
                  onPressed: _clearSearch,
                )
              : const Icon(Icons.search, size: 23, color: Colors.grey),
        ),
        onChanged: (value) {
          setState(() {}); // Để cập nhật UI khi text thay đổi
        },
        onSubmitted: (value) {
          _searchContent = value;
          _currentPage = 1;
          _fetchCustomers();
        },
      ),
    );
  }

  Widget _buildDataTable() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_dynamicColumns.isEmpty || _customers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(TablerIcons.database_off, size: 50, color: Colors.grey),
            const SizedBox(height: 8),
            Text('Không có dữ liệu',
                style: GoogleFonts.inter(color: Colors.grey)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 12,
            dataRowMinHeight: 30,
            dataRowMaxHeight: 50,
            columns: [
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text(
                      "STT",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              ..._dynamicColumns.map(
                (col) => DataColumn(
                  label: Expanded(
                    child: Center(
                      child: Text(
                        col,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text(
                      "Kênh thông tin",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text(
                      "Thời gian tạo",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text(
                      "Cập nhật lần cuối",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              DataColumn(
                label: Expanded(
                  child: Center(
                    child: Text(
                      "Trạng thái",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            rows: _customers.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final customer = entry.value;

              return DataRow(
                cells: [
                  DataCell(
                    Center(
                      child: Text(
                        index.toString(),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  ..._dynamicColumns.map((col) {
                    final value =
                        customer.slotDetails[col]?.toString().trim() ?? "";

                    if (CustomerUtils.isImageUrl(value)) {
                      return DataCell(
                        Center(
                          child: Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: value,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.image_not_supported,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return DataCell(
                      Center(
                        child: Text(
                          value.isEmpty ? "-" : value,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                  DataCell(
                    Center(
                      child: Text(
                        CustomerUtils.platformMapping[customer.platform] ??
                            customer.platform ??
                            "-",
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        customer.createdAt ?? "-",
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        customer.updatedAt ?? "-",
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        CustomerUtils.statusMapping[customer.slotStatus] ??
                            customer.slotStatus ??
                            "-",
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    final selectedColor = Provider.of<Providercolor>(context).selectedColor;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Previous Page Button
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              size: 23,
            ),
            color: _currentPage > 1 ? theme.primaryColor : Colors.grey,
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _fetchCustomers();
                  }
                : null,
            tooltip: 'Trang trước',
          ),

          // Current Page Indicator
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
            decoration: BoxDecoration(
              border: Border.all(
                  color: selectedColor == Colors.white
                      ? const Color(0xfffed5113)
                      : selectedColor),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              '$_currentPage',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: selectedColor == Colors.white
                      ? const Color(0xfffed51123)
                      : selectedColor),
            ),
          ),

          // Next Page Button
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              size: 23,
            ),
            color: _hasMoreData ? theme.primaryColor : Colors.grey,
            onPressed: _hasMoreData
                ? () {
                    setState(() => _currentPage++);
                    _fetchCustomers();
                  }
                : null,
            tooltip: 'Trang sau',
          ),

          // Items Per Page Dropdown
          Container(
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 1, color: Colors.black12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _perPage,
                icon: const Icon(Icons.arrow_drop_down, size: 24),
                style: theme.textTheme.bodyMedium,
                items: _perPageOptions.map((value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text('$value/trang',
                          style: GoogleFonts.inter(fontSize: 14)),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _perPage = value;
                      _currentPage = 1;
                    });
                    _fetchCustomers();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          const Divider(),
          _buildIntentFilter(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 180, child: _buildStatusFilter()),
              const SizedBox(width: 10),
              Expanded(child: _buildSearchField()),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 2, color: Colors.grey),
              ),
              child: _buildDataTable(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: _buildPaginationControls(),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String?>> _getChatbotInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('chatbot_name'),
      'picture': prefs.getString('chatbot_picture'),
    };
  }
}
